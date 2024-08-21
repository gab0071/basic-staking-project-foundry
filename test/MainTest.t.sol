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

    uint256 public stakingTokenInitialSupply = 1_000_000;
    uint256 public rewardTokenInitialSupply = 1_000_000;

    // custom errors
    error Main_amountMustBeGreaterThanZero();
    error Main_stakingBalanceMustBeGreaterThanZero();

    event SuccessfulUnstake(address indexed user, uint256 amount);

    function setUp() public {
        stakingToken = new StakingToken(stakingTokenInitialSupply);
        rewardToken = new RewardToken(rewardTokenInitialSupply);
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
        uint256 amountToStakeUser1 = 555;
        // Let's approve the mainContract contract to stake the STK tokens
        stakingToken.approve(address(mainContract), amountToStakeUser1);
        // Let's stake the STK tokens
        mainContract.stake(amountToStakeUser1);
        vm.stopPrank();

        // Test that the mainContract contract receives the STK tokens
        assertEq(stakingToken.balanceOf(address(mainContract)), amountToStakeUser1);

        // Destructure the returned struct into individual variables for user1
        (uint256 stakedBalance, bool hasStaked, bool isStaking) = mainContract.Stakes(user1);
        // Test that the values of the Stakes struct are updated correctly user1
        assertEq(stakedBalance, amountToStakeUser1);
        assertEq(hasStaked, true);
        assertEq(isStaking, true);

        // Let's make user2 stake some STK tokens
        vm.startPrank(user2);
        uint256 amountToStakeUser2 = 4_000;
        stakingToken.approve(address(mainContract), amountToStakeUser2);
        mainContract.stake(amountToStakeUser2);
        vm.stopPrank();

        // check the new balance of STK tokens in the mainContract
        uint256 newStakedBalance = amountToStakeUser1 + amountToStakeUser2;
        assertEq(stakingToken.balanceOf(address(mainContract)), newStakedBalance);

        // verify that user2 was succefully added into the stakers array
        address staker = mainContract.stakers(1);
        assertEq(staker, user2, "Staker number 2 was not added to the array.");

        // check that user3 can not stake with 0 amount
        vm.startPrank(user3);
        uint256 amountToStakeUser3 = 0;
        stakingToken.approve(address(mainContract), amountToStakeUser3);
        vm.expectRevert(Main_amountMustBeGreaterThanZero.selector);
        mainContract.stake(amountToStakeUser3);
        vm.stopPrank();
    }

    /*/////////////////////////////////////////////////////////////////////////////////////////////////////////
                                            UNSTAKING TEST
    /////////////////////////////////////////////////////////////////////////////////////////////////////////*/

    function testUnstake() public {
        uint256 amountToUnstake = 555;
        // Let's call the function where users stake tokens
        testStakingToken();

        // Let's emit the event where the user unstakes
        vm.expectEmit();
        emit SuccessfulUnstake(user1, amountToUnstake);

        // User1 unstake the tokens
        vm.startPrank(user1);
        mainContract.unstake();
        vm.stopPrank();

        // Let's see if the user3 can unstake
        vm.startPrank(user3);
        vm.expectRevert(Main_stakingBalanceMustBeGreaterThanZero.selector);
        mainContract.unstake();
        vm.stopPrank();
    }

    /*/////////////////////////////////////////////////////////////////////////////////////////////////////////
                                            DISTRIBUTION REWARD TOKENS TEST
    /////////////////////////////////////////////////////////////////////////////////////////////////////////*/
    function testRewardTokensDistribution() public {
        // Let's create the enviroment where exist stakers
        testStakingToken();

        uint256 amountUser1Staked = 555;
        uint256 amountUser2Staked = 4_000;

        // Now lets make the distribution of the reward tokens to the stakers (In this case 1:1)
        // So if user1 staked 555 STK tokens he is going to receive 555 RWT tokens
        vm.startPrank(address(this));
        // We are going to send full supply to the mainContract contract to distribute the reward tokens to the stakers
        rewardToken.transfer(address(mainContract), rewardTokenInitialSupply);
        mainContract.rewardTokensDistribution();
        vm.stopPrank();

        // Let's check if the reward token balance is correct
        assertEq(rewardToken.balanceOf(user1), amountUser1Staked);
        assertEq(rewardToken.balanceOf(user2), amountUser2Staked);
    }
}
