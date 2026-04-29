//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*Errors*/
error NotEnoughETHToEnterRaffle();

/**
 * @title Raffle Smart Contract
 * @author Sahil Ghosh
 * @notice A simple raffle creation
 * @dev It implements Chainlink VRFv2.5
 */

contract Raffle {
    uint256 private immutable i_entranceFees;
    address[] private s_players;

    /*Events*/
    event EnteredRaffle(address indexed player);

    constructor(uint256 ent_fees) {
        i_entranceFees = ent_fees;
    }

    function enterRaffle() public payable {
        if (msg.value < i_entranceFees) {
            revert NotEnoughETHToEnterRaffle();
        }
        s_players.push(payable(msg.sender));
        emit EnteredRaffle(msg.sender);
    }

    function pickWinner() public returns (address) {}

    /* Getter Functions*/

    function getEntraceFees() external view returns (uint256) {
        return i_entranceFees;
    }
}
