//SPDX-License-Identifier : MIT

pragma solidity ^0.8.0;
import {Script, console} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

import {HelperConfig} from "./HelperConfig.s.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscriptionContract is Script {
    HelperConfig internal helperConfig;

  

    function run() public {
        makeSubscription();
    }

    function makeSubscription() public returns (uint256, address) {
        helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;

        console.log("Creating Subscription ....");

        vm.startBroadcast();
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();

        return (subId, vrfCoordinator);
    }
}

contract FundSubscriptionContract is Script {
    HelperConfig internal helperConfig;
    uint256 internal constant FUND_AMOUNT = 10 ether;
    address internal vrfCoordinator;
    address internal linkToken;
    uint256 internal subscription_id;
    uint32 internal constant ANVIL_LOCAL_CHAIN_ID = 31337;

    

    function run() public {
        fundSubscription();
    }

    function fundSubscription() public {
        helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory netConfig = helperConfig.getConfig();

        vrfCoordinator = netConfig.vrfCoordinator;
        linkToken = netConfig.link;
        subscription_id = netConfig.subscription_id;

        console.log("Funding Subscription with id", subscription_id);
        console.log("10 ether is going to be funded");

        if (block.chainid == ANVIL_LOCAL_CHAIN_ID) {
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subscription_id, FUND_AMOUNT);
            vm.stopBroadcast();
        }

        else{
            vm.startBroadcast();
                LinkToken(linkToken).transferAndCall(vrfCoordinator, 0.0001 ether, abi.encode(subscription_id));
            vm.stopBroadcast();
        }
    }
}
/***
 * This contract adds the address of the consumer contract to subscription in order to use the Mock the VRF Coordinator services
 * 
 */
contract AddConsumerContract is Script{
    function run() external{
        
        
        addConsumer();
    }

    function addConsumer() public{
        address consumerAddress = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        uint256 subId = helperConfig.getConfig().subscription_id;

        vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(subId, consumerAddress);
        vm.stopBroadcast();
    }
}
