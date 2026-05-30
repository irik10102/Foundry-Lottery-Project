//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/*Type declaration*/
enum RaffleState {
    OPEN,
    CALCULATING
}

/**
 * @title Raffle Smart Contract
 * @author Sahil Ghosh
 * @notice A simple raffle creation
 * @dev It implements Chainlink VRFv2.5
 */

contract Raffle is VRFConsumerBaseV2Plus {
    /*Errors*/
    error  Raffle_NotSufficientETH();
    error  Raffle_WinnerTransferNotDone();
    error  Raffle_UpkeepNotYet(RaffleState raffleState, uint256 balance, uint256 s_players_length);
    /*Events*/
    event EnteredRaffle(address indexed player);
    event PickedWinner(address indexed player);

    uint256 private immutable i_entranceFees;
    address payable[] private s_players;
    uint256 private immutable i_interval;
    uint256 private s_lastBlockStamp;
    RaffleState private s_raffle_state;

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
        s_lastBlockStamp = block.timestamp;
        i_interval = interval;
        i_subscriptionId = subscription_id;
        i_keyHash = keyHash;
        i_callbackGaslimit = callbackGaslimit;
    }

    function enterRaffle() public payable openState {
        if (msg.value <= i_entranceFees) {
            revert Raffle_NotSufficientETH();
        }
        /*boolean res = payable(msg.sender).call{value: msg.value}();

        if (!res) revert();*/

        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }

    /**
     * @dev This function checks if this is right time to pick winner by fullfilling the follwing criteria:-
     * 1> The interval need to be completed
     * 2>The state raffle is open.
     * 3> Contract must have balance (ETH)
     * 4> Atleast 2 players must have entered the raffle.
     */

    function checkUpkeep(bytes memory checkData)
        public
        view
        returns (
            bool upkeepNeeded,
            bytes memory /* performData */
        )
    {
        bool isIntervalCompleted = (block.timestamp - s_lastBlockStamp) >= i_interval;
        bool isRaffleOpen = s_raffle_state == RaffleState.OPEN;
        bool isBalance = address(this).balance > 0;
        bool isPlayerEntered = s_players.length > 1; // Atleast two players

        upkeepNeeded = isIntervalCompleted && isRaffleOpen && isBalance && isPlayerEntered;

        return (upkeepNeeded, "");
    }

    function performUpkeep() public {
        if ((block.timestamp - s_lastBlockStamp) < i_interval) revert();

        (bool upKeepNeeded,) = checkUpkeep("");

        if (!upKeepNeeded) {
            revert Raffle_UpkeepNotYet(s_raffle_state, address(this).balance, s_players.length);
        }

        s_raffle_state = RaffleState.CALCULATING;

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

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        uint256 randomNumber = randomWords[0];
        uint256 winnerIndex = randomNumber % s_players.length;
        address winnerAddress = s_players[winnerIndex];

        s_raffle_state = RaffleState.OPEN;

        (bool success,) = winnerAddress.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle_WinnerTransferNotDone();
        }

        s_players = new address payable[](0);
        emit PickedWinner(winnerAddress);
    }

    /* Getter Functions*/

    function getEntraceFees() external view returns (uint256) {
        return i_entranceFees;
    }

    function getRaffleState() external view returns (RaffleState) {
        return s_raffle_state;
    }

    function getRafflePlayers(uint256 index) external view returns(address){
        return s_players[index];
    }

    function getRafflePlayersLength() external view returns(uint256){
        return s_players.length;
    }

    modifier openState() {
        if (s_raffle_state != RaffleState.OPEN) {
            revert();
        }

        _;
    }
}
