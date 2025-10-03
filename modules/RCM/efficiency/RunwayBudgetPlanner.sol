// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRunwayBudgetPlanner {
    event BudgetPlanned(uint256 indexed periodInDays, uint256 indexed estimatedCost, uint256 timestamp);

    error PlanningFailed(string message);

    function planBudget(uint256 _periodInDays, uint256 _estimatedCost) external;
    function getPlannedBudget(uint256 _periodInDays) external view returns (uint256);
}

contract RunwayBudgetPlanner is IRunwayBudgetPlanner, Ownable {
    mapping(uint256 => uint256) private s_plannedBudgets;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function planBudget(uint256 _periodInDays, uint256 _estimatedCost) external onlyOwner {
        require(_periodInDays > 0, "Period must be greater than zero.");
        s_plannedBudgets[_periodInDays] = _estimatedCost;
        emit BudgetPlanned(_periodInDays, _estimatedCost, block.timestamp);
    }

    function getPlannedBudget(uint256 _periodInDays) external view returns (uint256) {
        return s_plannedBudgets[_periodInDays];
    }
}