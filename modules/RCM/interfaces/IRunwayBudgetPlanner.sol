// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRunwayBudgetPlanner {
    event BudgetPlanned(uint256 indexed budgetId, uint256 indexed amount, uint256 indexed duration, uint256 timestamp);

    error InvalidBudget(uint256 providedAmount, uint256 providedDuration);

    function planBudget(uint256 _amount, uint256 _duration) external returns (uint256 budgetId);
    function getBudget(uint256 _budgetId) external view returns (uint256 amount, uint256 duration);
}