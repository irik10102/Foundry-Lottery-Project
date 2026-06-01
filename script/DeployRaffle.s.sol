//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscriptionContract, FundSubscriptionContract, AddConsumerContract} from "./Integration.s.sol";

/**
 * @title Deployment of Raffle contract such that upon detecting the chainId it will be automatically deploy into Sepolia or Local testnet(Anvil).
 * @author Sahil Ghosh
 */
contract DeployRaffle is Script {
    function run() external returns (Raffle, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();

        HelperConfig.NetworkConfig memory activeChainConfig = helperConfig.getConfig();

        /*Fund Subscription*/
        FundSubscriptionContract fundSubscriptionContract = new FundSubscriptionContract();
        fundSubscriptionContract.fundSubscription(address(helperConfig));

        vm.startBroadcast();
        /*Our Raffle Contract is the consumer*/
        Raffle raffle = new Raffle(
            activeChainConfig.ent_fees,
            activeChainConfig.interval,
            activeChainConfig.vrfCoordinator,
            activeChainConfig.subscription_id,
            activeChainConfig.keyHash,
            activeChainConfig.callbackGaslimit
        );
        vm.stopBroadcast();

        /*Add Consumer*/
        AddConsumerContract addConsumerContract = new AddConsumerContract();
        addConsumerContract.addConsumer(address(helperConfig), address(raffle), activeChainConfig.subscription_id);

        return (raffle, helperConfig);
    }
}
