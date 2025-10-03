// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title CybersecurityRiskAI - AI for cybersecurity risk assessment
/// @notice This interface defines functions for an AI system that assesses and monitors cybersecurity risks.
interface CybersecurityRiskAI {
    /// @notice Assesses the current cybersecurity posture of the system.
    /// @return riskScore A numerical score representing the cybersecurity risk level.
    /// @return vulnerabilities An array of strings detailing identified vulnerabilities.
    /// @return recommendations An array of strings with recommendations for improving security.
    function assessCybersecurityRisk(
    ) external view returns (uint256 riskScore, string[] memory vulnerabilities, string[] memory recommendations);

    /// @notice Detects potential cyber threats or attacks.
    /// @return threatDetected A boolean indicating if a threat was detected.
    /// @return threatType A string describing the type of threat (e.g., "phishing", "DDoS", "exploit").
    /// @return threatDetails A string providing details about the detected threat.
    function detectCyberThreat(
    ) external view returns (bool threatDetected, string memory threatType, string memory threatDetails);

    /// @notice Event emitted when a cybersecurity risk is assessed or a threat is detected.
    /// @param riskScore The assessed cybersecurity risk score.
    /// @param threatDetected True if a threat was detected, false otherwise.
    /// @param timestamp The timestamp of the assessment or detection.
    event CybersecurityEvent(
        uint256 riskScore,
        bool threatDetected,
        uint256 timestamp
    );

    /// @notice Error indicating that cybersecurity data is insufficient or unavailable.
    error InsufficientCybersecurityData();

    /// @notice Error indicating a failure in the cybersecurity risk assessment process.
    error CybersecurityAssessmentFailed(string message);
}