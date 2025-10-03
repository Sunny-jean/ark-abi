// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRebondingStrategyManager {
    event RebondingStrategyApplied(string indexed strategyName, uint256 indexed amount, uint256 timestamp);

    error StrategyApplicationFailed(string message);

    function applyRebondingStrategy(string calldata _strategyName, uint256 _amount) external;
    function getAvailableStrategies() external view returns (string[] memory);
}