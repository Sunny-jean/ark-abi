// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title GovernanceRiskAI - AI for governance risk assessment
/// @notice This interface defines functions for an AI system that assesses risks related to governance proposals and decisions.
interface GovernanceRiskAI {
    /// @notice Assesses the risk of a given governance proposal.
    /// @param proposalId The unique identifier of the governance proposal.
    /// @param proposalHash A hash of the proposal's content.
    /// @return riskScore A numerical score representing the assessed risk (e.g., 0-100, higher is riskier).
    /// @return riskFactors A string detailing the identified risk factors.
    function assessProposalRisk(
        uint256 proposalId,
        bytes32 proposalHash
    ) external view returns (uint256 riskScore, string memory riskFactors);

    /// @notice Monitors and reports on the overall governance risk posture of the DAO.
    /// @return overallRiskScore The aggregated risk score for the DAO's governance.
    /// @return riskReport A comprehensive report on governance risks.
    function getOverallGovernanceRisk(
    ) external view returns (uint256 overallRiskScore, string memory riskReport);

    /// @notice Event emitted when a governance proposal's risk is assessed.
    /// @param proposalId The unique identifier of the proposal.
    /// @param riskScore The assessed risk score.
    /// @param timestamp The timestamp of the assessment.
    event ProposalRiskAssessed(
        uint256 indexed proposalId,
        uint256 riskScore,
        uint256 timestamp
    );

    /// @notice Error indicating that the proposal ID is invalid.
    error InvalidProposalId(uint256 proposalId);

    /// @notice Error indicating that proposal content is not found or invalid.
    error ProposalContentNotFound(bytes32 proposalHash);

    /// @notice Error indicating a failure in the governance risk assessment process.
    error GovernanceRiskAssessmentFailed(string message);
}