// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface ICrisisManagementStrategy {
    event StrategyActivated(string indexed strategyName, uint256 timestamp);

    error StrategyNotFound(string message);
    error StrategyExecutionFailed(string message);

    function activateStrategy(string calldata _strategyName) external;
    function addStrategy(string calldata _strategyName, bytes calldata _strategyData) external;
    function getStrategyData(string calldata _strategyName) external view returns (bytes memory);
}

contract CrisisManagementStrategy is ICrisisManagementStrategy, Ownable {
    mapping(string => bytes) private s_strategies;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function activateStrategy(string calldata _strategyName) external onlyOwner {
        require(s_strategies[_strategyName].length > 0, "Strategy not found.");
        bool success = true; // Simulate strategy execution
        if (!success) {
            revert StrategyExecutionFailed("Failed to execute strategy.");
        }
        emit StrategyActivated(_strategyName, block.timestamp);
    }

    function addStrategy(string calldata _strategyName, bytes calldata _strategyData) external onlyOwner {
        s_strategies[_strategyName] = _strategyData;
    }

    function getStrategyData(string calldata _strategyName) external view returns (bytes memory) {
        return s_strategies[_strategyName];
    }
}