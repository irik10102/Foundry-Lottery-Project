//SPDX-License-Identifier: MIT

//Entrance Fees is 5 ether

pragma solidity ^0.8.0;
import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Raffle} from "../../src/Raffle.sol";

contract TestRaffle is Test {
    DeployRaffle private deployRaffle;
    Raffle private raffle;
    HelperConfig private helperConfig;

    address DUMMY_PLAYER1 = makeAddr("DUMMY_PLAYER1");
    address DUMMY_PLAYER2 = makeAddr("DUMMY_PLAYER2");

    uint256 private constant STARTING_DUMMY_PLAYER_BALANCE = 100 ether;
    uint256 private constant ENT_FEES = 5 ether;

    function setUp() external {
        deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.run();

        HelperConfig.NetworkConfig memory networkConfig = helperConfig.getConfig(block.chainid);

        uint256 ent_fees = networkConfig.ent_fees;
        uint256 interval = networkConfig.interval;
        address vrfCoordinator = networkConfig.vrfCoordinator;
        uint64 subscription_id = networkConfig.subscription_id;
        bytes32 keyHash = networkConfig.keyHash;
        uint32 callbackGaslimit = networkConfig.callbackGaslimit;

        vm.deal(DUMMY_PLAYER1, STARTING_DUMMY_PLAYER_BALANCE);
        vm.deal(DUMMY_PLAYER2, STARTING_DUMMY_PLAYER_BALANCE);
    }

    function testRaffleInitialState() external {
        assertEq(uint256(raffle.getRaffleState()), 0); //Raffle States are OPEN -> 0 , CALCULATING -> 1
    }

    function testEnterRaffleWithLessFees() external {
        //ARRANGE
        vm.startPrank(DUMMY_PLAYER1);

        //ASSERT (Though if the order is straighten up then this statement is executed at last)
        vm.expectRevert(Raffle.Raffle_NotSufficientETH.selector);

        //ACT
        raffle.enterRaffle{value: 3 ether}();
        vm.stopPrank();
    }

    function testRegisterWithFees() external{

        //ARRANGE
        vm.startPrank(DUMMY_PLAYER1);
        

        //ACT
        raffle.enterRaffle{value:6 ether}();

        //ASSERT
        assertEq(raffle.getRafflePlayers(0), DUMMY_PLAYER1);
    }

    function testRegisterMultiplePlayers() external{

        for(uint160 i = 1; i<=10; i++){
        //ARRANGE
            hoax(address(i), STARTING_DUMMY_PLAYER_BALANCE);

        //ACT
            raffle.enterRaffle{value:10 ether}();
        }

        //ASSERT
        assert(raffle.getRafflePlayersLength() == 10);
        assert(address(raffle).balance == 10*(10 ether));                        //Total amount  till now

    }
}
