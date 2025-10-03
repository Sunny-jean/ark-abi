// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRiskExposureAnalyzer {
    event RiskAnalyzed(uint256 indexed riskScore, string indexed riskLevel, uint256 timestamp);

    error AnalysisFailed(string message);

    function analyzeRisk() external view returns (uint256 riskScore, string memory riskLevel);
    function getRiskThresholds() external view returns (uint256 low, uint256 medium, uint256 high);
}