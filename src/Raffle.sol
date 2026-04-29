//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Raffle Smart Contract
 * @author Sahil Ghosh
 * @notice A simple raffle creation
 * @dev It implements Chainlink VRFv2.5
 *
 */
contract Raffle {
    /*Errors*/
    error NotEnoughETHToEnterRaffle();

    uint256 private immutable i_entranceFees;

    constructor(uint256 ent_fees) {
        i_entranceFees = ent_fees;
    }

    function enterRaffle() public payable {
        if (msg.value < i_entranceFees) {
            revert NotEnoughETHToEnterRaffle();
        }
    }

    function pickWinner() public returns (address) {}

    /* Getter Functions*/

    function getEntraceFees() external view returns (uint256) {
        return i_entranceFees;
    }
}
