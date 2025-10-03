// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRunwayPerformanceReporter {
    event PerformanceReported(uint256 indexed currentRunway, uint256 indexed projectedRunway, uint256 timestamp);

    function reportPerformance(uint256 _currentRunway, uint256 _projectedRunway) external;
    function getLastReport() external view returns (uint256 currentRunway, uint256 projectedRunway, uint256 timestamp);
}