// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INFTYieldOptimizer {
    function optimizeYield(uint256 _tokenId) external;
    function setOptimizationStrategy(address _strategy) external;
    function getOptimizationStrategy() external view returns (address);

    event YieldOptimized(uint256 indexed tokenId, address indexed strategy);
    event OptimizationStrategySet(address indexed strategy);

    error OptimizationFailed();
}