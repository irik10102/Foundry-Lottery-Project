//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
/*Errors*/
error NotEnoughETHToEnterRaffle();

/**
 * @title Raffle Smart Contract
 * @author Sahil Ghosh
 * @notice A simple raffle creation
 * @dev It implements Chainlink VRFv2.5
 */

contract Raffle is VRFConsumerBaseV2Plus {
    uint256 private immutable i_entranceFees;
    address[] private s_players;
    uint256 private immutable i_interval;
    uint256 private i_lastBlockStamp;

    /*Events*/
    event EnteredRaffle(address indexed player);

    /*ChainLink VRF state-variables*/
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_keyHash;
    uint16 constant REQUEST_CONFIMATION = 3;
    uint32 immutable i_callbackGaslimit;
    uint32 constant NUM_WORDS = 1;

    constructor(
        uint256 ent_fees,
        uint256 interval,
        address vrfCoordinator,
        uint64 subscription_id,
        bytes32 keyHash,
        uint32 callbackGaslimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFees = ent_fees;
        i_lastBlockStamp = block.timestamp;
        i_interval = interval;
        i_subscriptionId = subscription_id;
        i_keyHash = keyHash;
        i_callbackGaslimit = callbackGaslimit;
    }

    function enterRaffle() public payable {
        if (msg.value < i_entranceFees) {
            revert NotEnoughETHToEnterRaffle();
        }
        /*boolean res = payable(msg.sender).call{value: msg.value}();

        if (!res) revert();*/

        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }

    function pickWinner() public returns (address) {
        if ((block.timestamp - i_lastBlockStamp) < i_interval) revert();

        uint256 requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIMATION,
                callbackGasLimit: i_callbackGaslimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
    }

    /* Getter Functions*/

    function getEntraceFees() external view returns (uint256) {
        return i_entranceFees;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWors) internal override {}
}
