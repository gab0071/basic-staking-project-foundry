// SPDX-Lincese-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title RewardToken
/// @author Gabi Maverick from catellatech
/// @notice This is the reward token contract that users will receive
/// @dev Basic ERC20 token implementation from OpenZeppelin
contract RewardToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("RewardToken", "RWT") {
        _mint(msg.sender, initialSupply);
    }
}
