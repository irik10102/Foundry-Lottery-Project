//SPDX-License-Identifier: MIT

//Entrance Fees is 5 ether

pragma solidity ^0.8.0;
import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {Vm} from 'forge-std/Vm.sol';
import {VRFCoordinatorV2_5Mock} from '@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol';



contract TestRaffle is Test {
    //Events
    event EnteredRaffle(address indexed player);

    DeployRaffle private deployRaffle;
    Raffle private raffle;
    HelperConfig private helperConfig;

    address DUMMY_PLAYER1 = makeAddr("DUMMY_PLAYER1");
    address DUMMY_PLAYER2 = makeAddr("DUMMY_PLAYER2");

    uint256 private constant STARTING_DUMMY_PLAYER_BALANCE = 100 ether;
    uint256 private constant ENT_FEES = 5 ether;
    uint256 private constant RAFFLE_FUND_AMOUNT = 10 ether;
    uint256 ent_fees;
    uint256 interval;
    address vrfCoordinator;
    uint256 subscription_id;
    bytes32 keyHash;
    uint32 callbackGaslimit;

    function setUp() external {
        deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.run();

        HelperConfig.NetworkConfig memory networkConfig = helperConfig.getConfig();

        ent_fees = networkConfig.ent_fees;
        interval = networkConfig.interval;
        vrfCoordinator = networkConfig.vrfCoordinator;
        subscription_id = networkConfig.subscription_id;
        keyHash = networkConfig.keyHash;
        callbackGaslimit = networkConfig.callbackGaslimit;

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

    function testRegisterWithFees() external {
        //ARRANGE
        vm.startPrank(DUMMY_PLAYER1);

        //ACT
        raffle.enterRaffle{value: 6 ether}();

        //ASSERT
        assertEq(raffle.getRafflePlayers(0), DUMMY_PLAYER1);
    }

    function testRegisterMultiplePlayers() external {
        for (uint160 i = 1; i <= 10; i++) {
            //ARRANGE
            hoax(address(i), STARTING_DUMMY_PLAYER_BALANCE);

            //ACT
            raffle.enterRaffle{value: 10 ether}();
        }

        //ASSERT
        assert(raffle.getRafflePlayersLength() == 10);
        assert(address(raffle).balance == 10 * (10 ether)); //Total amount  till now
    }

    function testEventEnterRaffle() external {
        //Arrange
        vm.prank(DUMMY_PLAYER1);

        //Act & Assert
        vm.expectEmit(true, false, false, false, address(raffle));
        emit EnteredRaffle(DUMMY_PLAYER1);
        raffle.enterRaffle{value: 10 ether}();
    }
    //CheckUpkeep

    function testEnterRaffleWhileStateNotOpen() external allConditionTrueForCheckUpkeep{
        //Arrange

        //Condition for more than 2 players and balance greater than 0 has been fullfiled
       /* vm.prank(DUMMY_PLAYER1);
        raffle.enterRaffle{value: 10 ether}();

        vm.prank(DUMMY_PLAYER2);
        raffle.enterRaffle{value: 10 ether}();

        //Condtion for time greater than interval has been satisfied & the condition to be in state OPEN is also satisfied
        vm.warp(block.timestamp + interval + 1);*/

        //Act

        //The state has been changed
        raffle.performUpkeep();

        //Assert
        hoax(address(uint160(7890)), 10 ether);
        vm.expectRevert(Raffle.Raffle_StateNotOpen.selector);

        raffle.enterRaffle{value: 9 ether}();
    }

    function testEnterRaffleWith1Player() external {
        vm.prank(DUMMY_PLAYER1); //Only 1 player entered in Raffle
        // State is OPEN
        vm.warp(block.timestamp + interval + 1); //Time Passed Interval
        raffle.enterRaffle{value: 10 ether}(); // balance > 0

        vm.expectRevert();
        raffle.performUpkeep();
    }

    function testCheckUpkeepReturnsFalseIfTimeHasNotPassed() external{
        //More than 1 player , Balance is greater than 0 ETH , State is Open as PerformUpkeep is not called yet.

        

        //ACT
        (bool success,) = raffle.checkUpkeep("");

        //ASSERT
        assert(success == false);
    }

    function testCheckUpkeepReturnsTrueWhenParametersAreGood() external allConditionTrueForCheckUpkeep{
        //More than 1 player , Balance is greater than 0 ETH , State is Open as PerformUpkeep is not called yet.

        
        //ACT
        (bool success,) = raffle.checkUpkeep("");

        //ASSERT
        assert(success == true);
    }

    //PerformUpKeep

    function testPerformUpkeepRevertFailsCheckupkeepFalse() external {
        //Arrange
        //Performing no condition in order to checkUpKeep to be True
        Raffle.RaffleState rstate = raffle.getRaffleState();

        uint256 no_of_players = raffle.getRafflePlayersLength();

        uint256 balance = address(raffle).balance;
        vm.warp(block.timestamp + interval + 1);

        //ACT/assert
       

        vm.expectRevert(abi.encodeWithSelector(Raffle.Raffle_UpkeepNotYet.selector, rstate, balance, no_of_players));
        raffle.performUpkeep();
    }

    function testPerformUpkeepUpdatesStateAndEmitsRequestId() external allConditionTrueForCheckUpkeep{
        //Arrange
        vm.recordLogs();
        raffle.performUpkeep();

        //Act
        Vm.Log[] memory entries = vm.getRecordedLogs();

        //Assert
        assert(uint256(entries[1].topics[1]) == raffle.getRequestId() );

    }
    // FullFill random words

    function testIfFullFillRandomWordsCanGetOutputWithoutPerformUpkeep(uint256 requestId) external allConditionTrueForCheckUpkeep{ //Because performUpkeep gets requestId and fullfillRandomWords use it.
        vm.expectRevert(VRFCoordinatorV2_5Mock.InvalidRequest.selector);
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(requestId, address(raffle));
    }

    function testFullfillRandomWordsCanOnlyBeCalledAfterPerformUpkeep() external allConditionTrueForCheckUpkeep{
        //ARRANGE
        for(uint160 addr_i = 3; addr_i < 10; addr_i++)
        {
            hoax(address(addr_i), STARTING_DUMMY_PLAYER_BALANCE);
            raffle.enterRaffle{value:RAFFLE_FUND_AMOUNT}();

        }

        uint256 raffleBalanceBeforePickingWinner = address(raffle).balance;
        uint256 totalPlayers = raffle.getRafflePlayersLength();
        uint256 expectedDonationAmount = totalPlayers*RAFFLE_FUND_AMOUNT;


        vm.recordLogs();
        Vm.Log[] memory entries = vm.getRecordedLogs();


        //ACT

        //Starting Index for our event 1(RequestId)
        raffle.performUpkeep();

        //Here we are pretending to be a Chainlink Node
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(raffle.getRequestId(), address(raffle));

        //ASSERT
        uint256 winnerBalance = address(raffle.getRecentWinner()).balance;


        assert(Raffle.RaffleState.OPEN == raffle.getRaffleState());
        assert(winnerBalance == (STARTING_DUMMY_PLAYER_BALANCE-RAFFLE_FUND_AMOUNT + expectedDonationAmount));
        assert(raffleBalanceBeforePickingWinner == expectedDonationAmount);
    }

    modifier allConditionTrueForCheckUpkeep(){
        

        vm.prank(DUMMY_PLAYER1);
        raffle.enterRaffle{value: RAFFLE_FUND_AMOUNT}();

        vm.prank(DUMMY_PLAYER2);
        raffle.enterRaffle{value: RAFFLE_FUND_AMOUNT}();

        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        

        _;
    }
}
