// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPerformanceOptimizer {
    event OptimizationApplied(string indexed optimizationType, address indexed targetContract);

    function applyGasOptimization(address _targetContract) external;
    function applyStorageOptimization(address _targetContract) external;
}