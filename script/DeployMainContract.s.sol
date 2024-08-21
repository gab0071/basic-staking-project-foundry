// SPDX-Lincese-Identifier: MIT
pragma solidity ^0.8.20;

import { Main } from "../src/Main.sol";
import { StakingToken } from "../src/StakingToken.sol";
import { RewardToken } from "../src/RewardToken.sol";
import { Script } from "forge-std/Script.sol";

contract DeployMainContract is Script {
    uint256 public constant INITIAL_SUPPLY = 1_000_000;

    function run() public returns(Main){
        vm.startBroadcast();
        StakingToken stakingToken = new StakingToken(INITIAL_SUPPLY);
        RewardToken rewardToken = new RewardToken(INITIAL_SUPPLY);
        Main mainContract = new Main(stakingToken, rewardToken);
        vm.stopBroadcast();
        return mainContract;
    }
}