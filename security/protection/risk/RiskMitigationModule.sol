// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRiskMitigationModule {
    event RiskMitigated(bytes32 indexed riskId, string strategyApplied);

    error UnauthorizedAccess(address caller);
    error InvalidRiskId(bytes32 riskId);

    function applyMitigationStrategy(bytes32 _riskId, string memory _strategy) external;
    function getMitigationStrategy(bytes32 _riskId) external view returns (string memory);
}