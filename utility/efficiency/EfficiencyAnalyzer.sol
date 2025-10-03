// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEfficiencyAnalyzer {
    event AnalysisReport(string indexed metric, uint256 value);

    function analyzeGasUsage(address _contractAddress) external view returns (uint256);
    function analyzeStorageUsage(address _contractAddress) external view returns (uint256);
}