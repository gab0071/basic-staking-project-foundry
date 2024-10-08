// SPDX-Lincese-Identifier: MIT
pragma solidity ^0.8.20;

import { StakingToken } from "../src/StakingToken.sol"; 
import { RewardToken } from "../src/RewardToken.sol";
import { Main } from "../src/Main.sol";
import { Test } from "forge-std/Test.sol";


contract MainTest is Test {
    // call it all the contract that i need
    StakingToken public stakingToken;
    RewardToken public rewardToken;
    Main public mainContract;

    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");
    address public user3 = makeAddr("user3");

    uint256 public constant TokensInitialSupply = 1_000_000;
    uint256 constant amountToStakeUser1 = 555;
    uint256 constant amountToStakeUser2 = 4_000;

    event SuccessfulUnstake(address indexed user, uint256 amount);

    function setUp() public {
        stakingToken = new StakingToken(TokensInitialSupply);
        rewardToken = new RewardToken(TokensInitialSupply);
        mainContract = new Main(stakingToken, rewardToken);

        vm.prank(address(this));
        stakingToken.transfer(user1, 1_000);
        stakingToken.transfer(user2, 5_000);
    }

    /*/////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                   CHECK OWNER TEST
    /////////////////////////////////////////////////////////////////////////////////////////////////////////*/
    function testmainContractContractOwner() public view {
        assertEq(mainContract.owner(), address(this));
    }

    /*/////////////////////////////////////////////////////////////////////////////////////////////////////////
                                            STAKING TOKEN TEST
    /////////////////////////////////////////////////////////////////////////////////////////////////////////*/
    function testStakingToken() public {
        vm.startPrank(user1);
        // Let's approve the mainContract to stake the STK tokens
        stakingToken.approve(address(mainContract), amountToStakeUser1);
        // Let's stake the STK tokens
        mainContract.stake(amountToStakeUser1);
        vm.stopPrank();

        uint256 stakingTokenBalanceOfMainContract = stakingToken.balanceOf(address(mainContract));

        // Test that the mainContract receives the STK tokens
        assertEq(stakingTokenBalanceOfMainContract, amountToStakeUser1);

        // Destructure the returned struct into individual variables for user1
        (uint256 stakedBalance, bool hasStaked, bool isStaking) = mainContract.Stakes(user1);
        // Test that the values of the Stakes struct are updated correctly user1
        assertEq(stakedBalance, amountToStakeUser1);
        assertEq(hasStaked, true);
        assertEq(isStaking, true);

        // Let's make user2 stake some STK tokens
        vm.startPrank(user2);
        stakingToken.approve(address(mainContract), amountToStakeUser2);
        mainContract.stake(amountToStakeUser2);
        vm.stopPrank();

        // let's sum the staked balance of user1 and user2
        uint256 newStakedBalance = amountToStakeUser1 + amountToStakeUser2;
        // check the new balance of STK tokens in the mainContract
        uint256 stakingTokenBalanceOfMainContractNew = stakingToken.balanceOf(address(mainContract));
        
        assertEq(stakingTokenBalanceOfMainContractNew, newStakedBalance);

        // verify that user2 was succefully added into the stakers array
        address staker = mainContract.stakers(1);
        assertEq(staker, user2, "Staker number 2 was not added to the array.");


        // check that user3 can not stake with 0 amount
        vm.startPrank(user3);
        // No amount is assigned to `amountToStakeUser3` because `uint256` is initialized to 0 by default.
        uint256 amountToStakeUser3;
        stakingToken.approve(address(mainContract), amountToStakeUser3);
        vm.expectRevert(Main.Main__amountMustBeGreaterThanZero.selector);
        mainContract.stake(amountToStakeUser3);
        vm.stopPrank();
    }

    /*/////////////////////////////////////////////////////////////////////////////////////////////////////////
                                            UNSTAKING TEST
    /////////////////////////////////////////////////////////////////////////////////////////////////////////*/

    function testUnstake() public {
        // Let's call the function where users stake tokens
        testStakingToken();
        // Let's get the staked balance of user1 
        (uint256 amountToUnstake, , ) = mainContract.Stakes(user1);

        // Let's emit the event when the user unstakes successfully
        vm.expectEmit();
        emit SuccessfulUnstake(user1, amountToUnstake);

        // User1 unstake the tokens
        vm.startPrank(user1);
        mainContract.unstake();
        vm.stopPrank();

        // Let's see if the user3 can unstake if he is not staking
        vm.startPrank(user3);
        vm.expectRevert(Main.Main__stakingBalanceMustBeGreaterThanZero.selector);
        mainContract.unstake();
        vm.stopPrank();
    }

    /*/////////////////////////////////////////////////////////////////////////////////////////////////////////
                                            DISTRIBUTION REWARD TOKENS TEST
    /////////////////////////////////////////////////////////////////////////////////////////////////////////*/
    function testRewardTokensDistribution() public {
        // Let's create the enviroment where exist stakers
        testStakingToken();
        
        // Access the struct containing the staked balance of the stakers
        (uint256 amountUser1Staked, , ) = mainContract.Stakes(user1);
        (uint256 amountUser2Staked, , ) = mainContract.Stakes(user2);

        // Now lets make the distribution of the reward tokens to the stakers (In this case 1:1)
        // So if user1 staked 555 STK tokens he is going to receive 555 RWT tokens
        vm.startPrank(address(this));
        // We are going to send full supply to the mainContract to distribute the reward tokens to the stakers
        rewardToken.transfer(address(mainContract), TokensInitialSupply);
        mainContract.rewardTokensDistribution();
        vm.stopPrank();

        uint256 rewardTokenBalanceOfUser1 = rewardToken.balanceOf(address(user1));
        uint256 rewardTokenBalanceOfUser2 = rewardToken.balanceOf(address(user2));

        // Let's check if the reward token balance is correct
        assertEq(rewardTokenBalanceOfUser1, amountUser1Staked);
        assertEq(rewardTokenBalanceOfUser2, amountUser2Staked);
    }
}
