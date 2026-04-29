//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Raffle Smart Contract
 * @author Sahil Ghosh
 *
 */
contract Raffle {
    uint256 private immutable i_entrance_fees;

    constructor(uint256 ent_fees) {
        i_entrance_fees = ent_fees;
    }

    function enterRaffle() external payable {}

    function pickWinner() public returns (address) {}
}
