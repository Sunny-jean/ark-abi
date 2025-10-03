// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IRiskExposureAnalyzer {
    event RiskAnalyzed(string indexed riskLevel, string indexed message, uint256 timestamp);

    error AnalysisFailed(string message);

    function analyzeRisk(uint256 _currentRunwayDays, uint256 _criticalThreshold) external;
    function getRiskLevel() external view returns (string memory);
}

contract RiskExposureAnalyzer is IRiskExposureAnalyzer, Ownable {
    string private s_riskLevel;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function analyzeRisk(uint256 _currentRunwayDays, uint256 _criticalThreshold) external onlyOwner {
        if (_currentRunwayDays < _criticalThreshold) {
            s_riskLevel = "Critical";
            emit RiskAnalyzed(s_riskLevel, "Runway is critically low, high systemic risk.", block.timestamp);
        } else if (_currentRunwayDays < _criticalThreshold * 2) {
            s_riskLevel = "High";
            emit RiskAnalyzed(s_riskLevel, "Runway is low, elevated systemic risk.", block.timestamp);
        } else {
            s_riskLevel = "Low";
            emit RiskAnalyzed(s_riskLevel, "Runway is healthy, low systemic risk.", block.timestamp);
        }
    }

    function getRiskLevel() external view returns (string memory) {
        return s_riskLevel;
    }
}