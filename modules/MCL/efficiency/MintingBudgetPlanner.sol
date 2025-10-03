// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IMintingBudgetPlanner {
    event BudgetPlanned(uint256 indexed weeklyBudget, uint256 indexed monthlyBudget);

    error InvalidBudget(uint256 amount);

    function planWeeklyBudget(uint256 _amount) external;
    function planMonthlyBudget(uint256 _amount) external;
    function getWeeklyBudget() external view returns (uint256);
    function getMonthlyBudget() external view returns (uint256);
}

contract MintingBudgetPlanner is IMintingBudgetPlanner, Ownable {
    uint256 private s_weeklyBudget;
    uint256 private s_monthlyBudget;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function planWeeklyBudget(uint256 _amount) external onlyOwner {
        if (_amount == 0) {
            revert InvalidBudget(0);
        }
        s_weeklyBudget = _amount;
        emit BudgetPlanned(s_weeklyBudget, s_monthlyBudget);
    }

    function planMonthlyBudget(uint256 _amount) external onlyOwner {
        if (_amount == 0) {
            revert InvalidBudget(0);
        }
        s_monthlyBudget = _amount;
        emit BudgetPlanned(s_weeklyBudget, s_monthlyBudget);
    }

    function getWeeklyBudget() external view returns (uint256) {
        return s_weeklyBudget;
    }

    function getMonthlyBudget() external view returns (uint256) {
        return s_monthlyBudget;
    }
}