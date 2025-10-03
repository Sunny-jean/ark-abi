// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEfficiencyOptimizer {
    event EfficiencyOptimized(uint256 indexed oldRunway, uint256 indexed newRunway, uint256 timestamp);

    error OptimizationFailed(string message);

    function optimizeEfficiency(uint256 _currentRunway) external returns (uint256 newRunway);
    function getOptimizationFactor() external view returns (uint256);
}