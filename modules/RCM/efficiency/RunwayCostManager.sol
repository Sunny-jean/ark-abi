// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRunwayCostManager {
    event CostReduced(uint256 indexed oldCost, uint256 indexed newCost, uint256 timestamp);

    error CostManagementFailed(string message);

    function reduceCost(uint256 _currentCost, uint256 _reductionAmount) external;
    function getCurrentCost() external view returns (uint256);
}

contract RunwayCostManager is IRunwayCostManager, Ownable {
    uint256 private s_currentCost;

    constructor(address initialOwner, uint256 initialCost) Ownable(initialOwner) {
        s_currentCost = initialCost;
    }

    function reduceCost(uint256 _currentCost, uint256 _reductionAmount) external onlyOwner {
        require(_currentCost >= _reductionAmount, "Reduction amount exceeds current cost.");
        s_currentCost = _currentCost - _reductionAmount;
        emit CostReduced(_currentCost, s_currentCost, block.timestamp);
    }

    function getCurrentCost() external view returns (uint256) {
        return s_currentCost;
    }
}