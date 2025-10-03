// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface ICapEfficiencyOptimizer {
    event OptimizationPerformed(uint256 indexed newCap, string indexed strategy);

    error OptimizationFailed(string reason);

    function optimizeCap(uint256 _currentTVL, uint256 _currentPremium) external;
    function setOptimizationStrategy(string calldata _strategy) external;
    function getOptimizationStrategy() external view returns (string memory);
}

contract CapEfficiencyOptimizer is ICapEfficiencyOptimizer, Ownable {
    string private s_optimizationStrategy;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function optimizeCap(uint256 _currentTVL, uint256 _currentPremium) external onlyOwner {
        uint256 optimizedCap = (_currentTVL * _currentPremium) / 100;

        if (optimizedCap == 0) {
            revert OptimizationFailed("Calculated optimized cap is zero.");
        }

        emit OptimizationPerformed(optimizedCap, s_optimizationStrategy);
    }

    function setOptimizationStrategy(string calldata _strategy) external onlyOwner {
        s_optimizationStrategy = _strategy;
    }

    function getOptimizationStrategy() external view returns (string memory) {
        return s_optimizationStrategy;
    }
}