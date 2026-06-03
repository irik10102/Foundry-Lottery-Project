//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;
import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "test/mocks/LinkToken.sol";
import {CreateSubscriptionContract} from "./Integration.s.sol";

error HelperConfig_Chain_not_found();

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 ent_fees;
        uint256 interval;
        address vrfCoordinator;
        uint256 subscription_id;
        bytes32 keyHash;
        uint32 callbackGaslimit;
        address link;
    }

    mapping(uint256 chainid => NetworkConfig) private networkConfigs;

    uint32 public constant SEPOLIA_ETH_CHAIN_ID = 11155111;
    uint32 public constant ANVIL_LOCAL_CHAIN_ID = 31337;

    /*VRF MOCK VARIABLES*/
    uint96 private constant MOCK_BASE_FEE = 0.001 ether;
    uint32 private constant MOCK_GASE_PRICE_LINK = 4e5;
    int256 private constant MOCK_WEI_PER_UNIT_LINK = 1000 ether;

    constructor() {
        networkConfigs[SEPOLIA_ETH_CHAIN_ID] = getSepoliaTestnet();
        networkConfigs[ANVIL_LOCAL_CHAIN_ID] = getAnvilTestnet();
    }

    function getSepoliaTestnet() internal pure returns (NetworkConfig memory) {
        return NetworkConfig({
            ent_fees: 0.000001 ether,
            interval: 30,
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            subscription_id: 59490573993633328272917746973052082465255066811621324857065457168831401016251,
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callbackGaslimit: 500000,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789
        });
    }

    function getAnvilTestnet() internal returns (NetworkConfig memory) {
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorMock =
            new VRFCoordinatorV2_5Mock(MOCK_BASE_FEE, MOCK_GASE_PRICE_LINK, MOCK_WEI_PER_UNIT_LINK);
        LinkToken linkToken = new LinkToken();

        uint256 subId = vrfCoordinatorMock.createSubscription();
        vm.stopBroadcast();

        return NetworkConfig({
            ent_fees: 5 ether,
            interval: 30,
            vrfCoordinator: address(vrfCoordinatorMock),
            subscription_id: subId, //for now
            //Doesnot require
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callbackGaslimit: 4294967295,
            link: address(linkToken)
        });
    }

    function getConfig() external view returns (NetworkConfig memory) {
        uint256 chainId = block.chainid;
        if (networkConfigs[chainId].vrfCoordinator == address(0)) {
            revert HelperConfig_Chain_not_found();
        } else {
            return networkConfigs[chainId];
        }
    }
}
