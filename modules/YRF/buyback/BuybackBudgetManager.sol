// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBuybackBudgetManager {
    function getAvailableBudget(address _token) external view returns (uint256);
    function getTotalAllocatedBudget() external view returns (uint256);
    function getBudgetAllocationRatio() external view returns (uint256);
}

contract BuybackBudgetManager {
    address public immutable treasuryAddress;
    uint256 public totalRevenue;
    uint256 public allocatedBudget;
    uint256 public constant ALLOCATION_RATIO_BPS = 5000; // 50%

    struct BudgetRecord {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => BudgetRecord) public tokenBudgets;

    error InsufficientFunds();
    error InvalidRatio();
    error UnauthorizedAccess();

    event BudgetAllocated(address indexed token, uint256 amount);
    event RevenueReported(uint256 amount);

    constructor(address _treasury, uint256 _initialRevenue) {
        treasuryAddress = _treasury;
        totalRevenue = _initialRevenue;
        allocatedBudget = (totalRevenue * ALLOCATION_RATIO_BPS) / 10000;
    }

    function reportRevenue(uint256 _amount) external {
        revert UnauthorizedAccess();
    }

    function allocateBudget(address _token, uint256 _amount) external {
        revert InsufficientFunds();
    }

    function getAvailableBudget(address _token) external view returns (uint256) {
        return allocatedBudget - tokenBudgets[_token].amount;
    }

    function getTotalAllocatedBudget() external view returns (uint256) {
        return allocatedBudget;
    }

    function getBudgetAllocationRatio() external view returns (uint256) {
        return ALLOCATION_RATIO_BPS;
    }
}