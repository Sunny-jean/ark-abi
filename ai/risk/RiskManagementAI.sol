// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title RiskManagementAI - AI for system risk management
/// @notice This interface defines functions for an AI system that monitors, assesses, and manages overall system risks.
interface RiskManagementAI {
    /// @notice Assesses the current overall risk level of the system.
    /// @return riskLevel A string describing the current risk level (e.g., "low", "medium", "high", "critical").
    /// @return riskScore A numerical score representing the aggregated system risk.
    /// @return riskReport A detailed report on identified risks and their potential impact.
    function assessSystemRisk(
    ) external view returns (string memory riskLevel, uint256 riskScore, string memory riskReport);

    /// @notice Recommends mitigation strategies for identified risks.
    /// @param riskId The identifier of the risk to mitigate.
    /// @return mitigationStrategy A string describing the recommended strategy.
    /// @return estimatedImpactReduction The estimated reduction in risk impact after mitigation.
    function recommendMitigationStrategy(
        bytes32 riskId
    ) external view returns (string memory mitigationStrategy, uint256 estimatedImpactReduction);

    /// @notice Event emitted when the system risk is assessed.
    /// @param riskLevel The assessed risk level.
    /// @param riskScore The aggregated risk score.
    /// @param timestamp The timestamp of the assessment.
    event SystemRiskAssessed(
        string riskLevel,
        uint256 riskScore,
        uint256 timestamp
    );

    /// @notice Error indicating that risk data is insufficient or unavailable.
    error InsufficientRiskData();

    /// @notice Error indicating a failure in the risk management process.
    error RiskManagementFailed(string message);
}