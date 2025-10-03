// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title OperationalRiskAI - AI for operational risk monitoring
/// @notice This interface defines functions for an AI system that monitors and assesses operational risks within the system.
interface OperationalRiskAI {
    /// @notice Monitors the system for potential operational risks.
    /// @return riskScore A numerical score representing the current operational risk level.
    /// @return identifiedRisks An array of strings detailing identified operational risks.
    /// @return recommendations An array of strings with recommendations for mitigating risks.
    function monitorOperationalRisk(
    ) external view returns (uint256 riskScore, string[] memory identifiedRisks, string[] memory recommendations);

    /// @notice Assesses the impact of a simulated or potential operational incident.
    /// @param incidentType A string describing the type of incident (e.g., "network outage", "smart contract bug").
    /// @param severity The estimated severity of the incident.
    /// @return estimatedImpact A numerical value representing the estimated impact.
    /// @return impactDetails A string providing details about the impact assessment.
    function assessIncidentImpact(
        string calldata incidentType,
        uint256 severity
    ) external view returns (uint256 estimatedImpact, string memory impactDetails);

    /// @notice Event emitted when an operational risk is detected or assessed.
    /// @param riskScore The assessed operational risk score.
    /// @param timestamp The timestamp of the assessment.
    event OperationalRiskDetected(
        uint256 riskScore,
        uint256 timestamp
    );

    /// @notice Error indicating that operational data is insufficient or unavailable.
    error InsufficientOperationalData();

    /// @notice Error indicating a failure in the operational risk monitoring process.
    error OperationalRiskMonitoringFailed(string message);
}