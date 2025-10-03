// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRealTimeRunwayMonitor {
    event RunwayStatusUpdated(uint256 indexed currentRunway, uint256 timestamp);

    function updateRunwayStatus(uint256 _currentRunway) external;
    function getCurrentRunway() external view returns (uint256);
}