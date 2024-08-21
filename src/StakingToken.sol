// SPDX-Lincese-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title StakingToken
/// @author Gabi Maverick from catellatech
/// @notice This is the staking token contract that users need to stake to get rewards
/// @dev Basic ERC20 token implementation from OpenZeppelin
contract StakingToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("StakingToken", "STK") {
        _mint(msg.sender, initialSupply);
    }
}
