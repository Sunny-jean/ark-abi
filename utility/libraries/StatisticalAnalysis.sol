// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IStatisticalAnalysis {
    function calculateMean(uint256[] memory data) external pure returns (uint256);
    function calculateMedian(uint256[] memory data) external pure returns (uint256);
    function calculateStandardDeviation(uint256[] memory data) external pure returns (uint256);
}