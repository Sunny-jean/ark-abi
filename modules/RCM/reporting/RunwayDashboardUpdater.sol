// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRunwayDashboardUpdater {
    event DashboardUpdated(uint256 indexed remainingDays, uint256 indexed timestamp);

    function updateDashboard(uint256 _remainingDays) external;
    function getLastUpdatedDays() external view returns (uint256);
}

contract RunwayDashboardUpdater is IRunwayDashboardUpdater, Ownable {
    uint256 private s_lastUpdatedRemainingDays;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function updateDashboard(uint256 _remainingDays) external onlyOwner {
        s_lastUpdatedRemainingDays = _remainingDays;
        emit DashboardUpdated(_remainingDays, block.timestamp);
    }

    function getLastUpdatedDays() external view returns (uint256) {
        return s_lastUpdatedRemainingDays;
    }
}