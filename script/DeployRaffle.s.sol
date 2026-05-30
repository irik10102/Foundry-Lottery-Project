//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

/**
 * @title Deployment of Raffle contract such that upon detecting the chainId it will be automatically deploy into Sepolia or Local testnet(Anvil).
 * @author Sahil Ghosh
 */
contract DeployRaffle is Script {
    function run() external returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();

        HelperConfig.NetworkConfig memory activeChainConfig = helperConfig.getConfig(block.chainid);

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            activeChainConfig.ent_fees,
            activeChainConfig.interval,
            activeChainConfig.vrfCoordinator,
            activeChainConfig.subscription_id,
            activeChainConfig.keyHash,
            activeChainConfig.callbackGaslimit
        );
        vm.stopBroadcast();

        return (raffle, helperConfig);
    }
}
