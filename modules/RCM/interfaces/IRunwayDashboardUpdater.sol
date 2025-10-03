// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRunwayDashboardUpdater {
    event DashboardUpdated(uint256 indexed timestamp, bytes data);

    function updateDashboard(bytes calldata _data) external;
    function getLastUpdate() external view returns (uint256 timestamp, bytes memory data);
}