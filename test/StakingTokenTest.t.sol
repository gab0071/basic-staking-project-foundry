// SPDX-Lincese-Identifier: MIT
pragma solidity ^0.8.20;

import { StakingToken } from "../src/StakingToken.sol";
import { Test } from "forge-std/Test.sol";

contract StakingTokenTest is Test {
    StakingToken stakingToken;
    uint256 initialStakingSupply = 1_000_000;

    function setUp() public {
        stakingToken = new StakingToken(initialStakingSupply);
    }

    function testSupply() public view {
        assertEq(stakingToken.totalSupply(), initialStakingSupply);
    }
}
