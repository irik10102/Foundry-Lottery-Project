//SPDX-License-Identifier : MIT

pragma solidity ^0.8.0;
import {Script, console} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

import {HelperConfig} from "./HelperConfig.s.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";

contract CreateSubscriptionContract is Script {
    HelperConfig internal helperConfig;

    constructor(address _helperconfig) {
        helperConfig = HelperConfig(_helperconfig);
    }

    function run() external returns (uint256, address) {
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;

        console.log("Creating Subscription ....");

        vm.startBroadcast();
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();

        return (subId, vrfCoordinator);
    }
}

contract FundSubscription is Script {
    HelperConfig internal helperConfig;

    constructor(address _helperconfig) {
        helperConfig = HelperConfig(_helperconfig);
    }

    function run() external {
        HelperConfig.NetworkConfig memory netConfig = helperConfig.getConfig();

        console.log("Funding subscription....");
        if (block.chainid == helperConfig.ANVIL_LOCAL_CHAIN_ID()) {
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(netConfig.vrfCoordinator).fundSubscription(netConfig.subscription_id, 1 ether);
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
            LinkToken(netConfig.link)
                .transferAndCall(netConfig.vrfCoordinator, 0.01 ether, abi.encode(netConfig.subscription_id));
            vm.stopBroadcast();
        }
    }
}
