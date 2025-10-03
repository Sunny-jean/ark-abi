// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICostManagementSystem {
    event CostOptimized(address indexed transactionOrigin, uint256 originalCost, uint256 optimizedCost);

    function getOptimizedTransactionCost(bytes memory _transactionData) external view returns (uint256);
    function applyCostOptimization(bytes memory _transactionData) external returns (bytes memory);
}