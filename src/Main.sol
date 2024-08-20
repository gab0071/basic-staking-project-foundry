// SPDX-LINCENSE-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {StakingToken} from "./StakingToken.sol";
import {RewardToken} from "./RewardToken.sol";

/// @title Main Contract
/// @author Gabi Maverick from catellatech
/// @notice This is the main contract that manages the staking and unstaking logic
/// @dev This contract extends the Ownable contract from OpenZeppelin
/// @dev This contract is used just as a educational purpose dont use it in production

contract Main is Ownable {
    // custom errors
    error Main_amountMustBeGreaterThanZero();
    error Main_stakingBalanceMustBeGreaterThanZero();

    event SuccessfulStaked(address indexed user, uint256 amount);
    event SuccessfulUnstake(address indexed user, uint256 amount);

    StakingToken public immutable i_stakingToken;
    RewardToken public immutable i_rewardToken;

    address[] public stakers;
    /// @dev I decide to use an struct here to store the staked balance and whether the user is staking or not to adding into the mapping and save some gas but also to work more with stuct

    struct StakeInfo {
        uint256 StakedBalance;
        bool hasStaked;
        bool isStaking;
    }

    mapping(address user => StakeInfo) public Stakes;

    constructor(StakingToken _stakingToken, RewardToken _rewardToken) Ownable(msg.sender) {
        i_stakingToken = _stakingToken;
        i_rewardToken = _rewardToken;
    }

    /// @notice This function is used to stake (STK) tokens
    /// @param _amountToStake amount of STK tokens to stake
    /// @dev If the amount to stake is good lets transfer StakingToken (STK) to the contract
    /// @dev and update the staked balance
    /// @dev and lets add to the array the staker address if they are not already there
    /// @dev and lets update the staking status
    /// @dev if the amount to stake is not good throw an error
    function stake(uint256 _amountToStake) public {
        if (_amountToStake <= 0) {
            revert Main_amountMustBeGreaterThanZero();
        }
        // If the amount to stake is good lets transfer StakingToken (STK) to the Main contract
        i_stakingToken.transferFrom(msg.sender, address(this), _amountToStake);
        // update the staked balance
        Stakes[msg.sender].StakedBalance += _amountToStake;
        // And let's add the staker's address to the array if that user is not already there
        if (!Stakes[msg.sender].hasStaked) {
            stakers.push(msg.sender);
        }
        // and lets update the staking status
        Stakes[msg.sender].hasStaked = true;
        Stakes[msg.sender].isStaking = true;
        emit SuccessfulStaked(msg.sender, _amountToStake);
    }

    /// @notice This function is used to unstake
    /// @dev lets check the balance to unstake
    /// @dev lets transfer to the user the StakingToken (STK) that they staked previously
    /// @dev and lets update the staked balance
    /// @dev and lets update the staking status
    /// @dev if the amount to unstake is not good throw an error
    function unstake() public {
        // lets check the balance to unstake
        uint256 amountToUnstake = Stakes[msg.sender].StakedBalance;
        if (balance <= 0) {
            revert Main_stakingBalanceMustBeGreaterThanZero();
        }
        // lets transfer to the user the StakingToken (STK) that they staked
        i_stakingToken.transfer(msg.sender, amountToUnstake);
        // and lets update the staked balance
        Stakes[msg.sender].StakedBalance = 0;
        // and lets update the staking status
        Stakes[msg.sender].isStaking = false;
        emit SuccessfulUnstake(msg.sender, amountToUnstake);
    }

    /// @notice This function is used to distribute the reward token (RWT) to the users who currently staking in the platform
    /// @dev We iterate through the stakers array and transfer the reward token (RWT) to each user
    /// 🚨 this function is for educational purpuse but it can be better tbh, this can maybe in production can cause DoS
    /// if a lot of users stake and the array is big enough to cause DoS, if u want to apply this in production consider Consider limiting the number of iterations in for-loops that make external calls
    function rewardTokensDistribution() public onlyOwner {
        uint256 length = stakers.length;
        for (uint256 i; i < length; i++) {
            address receipient = stakers[i];
            uint256 balance = Stakes[receipient].StakedBalance;
            if (balance > 0) {
                i_rewardToken.transfer(receipient, balance);
            }
        }
    }
}
