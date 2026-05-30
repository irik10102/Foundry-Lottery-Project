//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;
import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

error HelperConfig_Chain_not_found();

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 ent_fees;
        uint256 interval;
        address vrfCoordinator;
        uint64 subscription_id;
        bytes32 keyHash;
        uint32 callbackGaslimit;
    }

    mapping(uint256 chainid => NetworkConfig) private networkConfigs;

    uint32 private constant SEPOLIA_ETH_CHAIN_ID = 11155111;
    uint32 private constant ANVIL_LOCAL_CHAIN_ID = 31337;

    /*VRF MOCK VARIABLES*/
    uint96 private constant MOCK_BASE_FEE = 0.001 ether;
    uint32 private constant MOCK_GASE_PRICE_LINK = 4e5;
    int96 private constant MOCK_WEI_PER_UNIT_LINK = 1e14;

    constructor() {
        networkConfigs[SEPOLIA_ETH_CHAIN_ID] = getSepoliaTestnet();
        networkConfigs[ANVIL_LOCAL_CHAIN_ID] = getAnvilTestnet();
    }

    function getSepoliaTestnet() internal pure returns (NetworkConfig memory) {
        return NetworkConfig({
            ent_fees: 5 ether,
            interval: 30,
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            subscription_id: 0, //for now
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callbackGaslimit: 500000
        });
    }

    function getAnvilTestnet() internal returns (NetworkConfig memory) {
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorMock =
            new VRFCoordinatorV2_5Mock(MOCK_BASE_FEE, MOCK_GASE_PRICE_LINK, MOCK_WEI_PER_UNIT_LINK);
        vm.stopBroadcast();

        return NetworkConfig({
            ent_fees: 5 ether,
            interval: 30,
            vrfCoordinator: address(vrfCoordinatorMock),
            subscription_id: 0, //for now
            //Doesnot require
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callbackGaslimit: 500000
        });
    }

    function getConfig(uint256 chainId) external view returns (NetworkConfig memory) {
        if (networkConfigs[chainId].vrfCoordinator == address(0)) {
            revert HelperConfig_Chain_not_found();
        } else {
            return networkConfigs[chainId];
        }
    }
}
