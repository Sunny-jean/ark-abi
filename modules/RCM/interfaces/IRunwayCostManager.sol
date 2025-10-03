// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRunwayCostManager {
    event CostReduced(uint256 indexed oldCost, uint256 indexed newCost, uint256 timestamp);

    error CostManagementFailed(string message);

    function reduceCost(uint256 _currentCost) external returns (uint256 newCost);
    function getCostReductionFactor() external view returns (uint256);
}