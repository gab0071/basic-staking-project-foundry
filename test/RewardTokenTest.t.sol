// SPDX-Lincese-Identifier: MIT
pragma solidity ^0.8.20;

import { RewardToken } from "../src/RewardToken.sol";
import { Test } from "forge-std/Test.sol";

contract RewardTokenTest is Test {
    RewardToken rewardToken;
    uint256 initialSupply = 8_000_000;

    function setUp() public {
        rewardToken = new RewardToken(initialSupply);
    }

    function testRewardTokenSupply() public view {
        assertEq(rewardToken.totalSupply(), initialSupply);
    }
}
