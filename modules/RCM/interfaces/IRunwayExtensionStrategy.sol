// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRunwayExtensionStrategy {
    event StrategyExecuted(string indexed strategyName, uint256 indexed extendedDays, uint256 timestamp);

    error StrategyFailed(string message);

    function executeStrategy(string calldata _strategyName, uint256 _currentRunwayDays) external;
    function setStrategyParameters(string calldata _strategyName, bytes calldata _parameters) external;
}