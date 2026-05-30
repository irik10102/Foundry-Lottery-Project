//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Raffle} from "../../src/Raffle.sol";

contract TestRaffle is Test {
    DeployRaffle private deployRaffle;
    Raffle private raffle;
    HelperConfig private helperConfig;

    function setUp() external {
        deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.run();

        HelperConfig.NetworkConfig memory networkConfig = helperConfig.getConfig(block.chainid);
    }
}
