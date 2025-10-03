// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPerformanceLogManager {
    event PerformanceLog(string indexed metricName, uint256 value, uint256 timestamp);

    function logPerformanceMetric(string memory _metricName, uint256 _value) external;
}