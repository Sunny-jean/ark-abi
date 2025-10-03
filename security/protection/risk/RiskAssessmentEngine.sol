// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRiskAssessmentEngine {
    event RiskAssessed(bytes32 indexed assessmentId, uint256 riskScore, string details);

    error UnauthorizedAccess(address caller);
    error InvalidInputData(bytes data);

    function assessRisk(bytes calldata _data) external returns (uint256 riskScore, string memory details);
    function getRiskScore(bytes32 _assessmentId) external view returns (uint256);
}