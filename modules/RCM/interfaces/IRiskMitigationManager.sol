// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRiskMitigationManager {
    event MitigationStrategyTriggered(string indexed strategyName, uint256 timestamp);

    error MitigationFailed(string message);

    function triggerMitigation(string calldata _strategyName) external;
    function getMitigationStrategies() external view returns (string[] memory);
}