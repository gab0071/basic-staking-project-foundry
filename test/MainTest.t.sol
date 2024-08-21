// SPDX-Lincese-Identifier: MIT
pragma solidity ^0.8.20;

import {StakingToken} from "../src/StakingToken.sol";
import {RewardToken} from "../src/RewardToken.sol";
import {Main} from "../src/Main.sol";
import {Test, console} from "forge-std/Test.sol";

/**
1. So i need to deploy the staking contract and fund with some STK tokens to 2 users
2. So the main token deploy reward token to use the rewardTokensDistribution function 
*/

contract MainTest is Test {
    // custom errors
    error Main_amountMustBeGreaterThanZero();
    error Main_stakingBalanceMustBeGreaterThanZero();

    // call it all the contract that i need
    StakingToken public stakingToken;
    RewardToken public rewardToken;
    Main public main;
    
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");
    address public user3 = makeAddr("user3");

    uint256 public stakingTokenInitialSupply = 1_000_000;
    uint256 public rewardTokenInitialSupply = 1_000_000;

    function setUp() public {
        stakingToken = new StakingToken(stakingTokenInitialSupply);
        rewardToken = new RewardToken(rewardTokenInitialSupply);
        main = new Main(stakingToken, rewardToken);

        vm.prank(address(this));
        stakingToken.transfer(user1, 1_000);
        stakingToken.transfer(user2, 5_000);
    }

    function testMainContractOwner() public view {
        assertEq(main.owner(), address(this));
    }

    // Test the staking function of the Main contract
    // user1 and user2 stake some STK tokens correctly
    function testStakingToken() public  {
        vm.startPrank(user1);
        uint256 amountToStake = 555;
        // Let's approve the Main contract to stake the STK tokens
        stakingToken.approve(address(main), amountToStake);
        // Let's stake the STK tokens
        main.stake(amountToStake);
        vm.stopPrank();

        // verify that user1 was succefully added into the stakers array
        address staker = main.stakers(0);
        assertEq(staker, user1, "Staker was not added to the array.");
        
        // Test that the Main contract receives the STK tokens
        assertEq(stakingToken.balanceOf(address(main)), amountToStake);
        
        // Destructure the returned struct into individual variables for user1
        (uint256 stakedBalance, bool hasStaked, bool isStaking) = main.Stakes(user1);
        // Test that the values of the Stakes struct are updated correctly user1
        assertEq(stakedBalance, amountToStake);
        assertEq(isStaking, true);
        assertEq(hasStaked, true);

        // Let's make user2 stake some STK tokens
        vm.startPrank(user2);
        uint256 amountToStakeUser2 = 4_000;
        stakingToken.approve(address(main), amountToStakeUser2);
        main.stake(amountToStakeUser2);
        vm.stopPrank();
        
        
        uint256 newStakedBalance = amountToStake + amountToStakeUser2;
        assertEq(stakingToken.balanceOf(address(main)), newStakedBalance);

        // Destructure the returned struct into individual variables for user2
        (uint256 stakedBalanceUser2, bool hasStakedUser2, bool isStakingUser2) = main.Stakes(user2);
        // Test that the values of the Stakes struct are updated correctly user2
        assertEq(stakedBalanceUser2, amountToStakeUser2);
        assertEq(isStakingUser2, true);
        assertEq(hasStakedUser2, true);

    }

    function testStaingFailure() public {
        vm.startPrank(user3);
        uint256 amountToStake = 0;
        stakingToken.approve(address(main), amountToStake);
        vm.expectRevert(Main_amountMustBeGreaterThanZero.selector);
        main.stake(amountToStake);
        vm.stopPrank();
    }

    
    
}