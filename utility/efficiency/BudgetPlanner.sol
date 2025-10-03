// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBudgetPlanner {
    event BudgetSet(address indexed category, uint256 amount);
    event BudgetExceeded(address indexed category, uint256 currentUsage, uint256 budgetLimit);

    error BudgetNotFound(address category);

    function setBudget(address _category, uint256 _amount) external;
    function getBudget(address _category) external view returns (uint256);
    function getCurrentUsage(address _category) external view returns (uint256);
    function isBudgetExceeded(address _category) external view returns (bool);
}