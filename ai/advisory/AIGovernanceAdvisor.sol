// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title AIGovernanceAdvisor - AI-powered governance advisor interface
/// @notice This interface defines the functions for an AI system that provides advice and recommendations for governance decisions.
interface AIGovernanceAdvisor {
    /// @notice Provides a governance recommendation based on a given proposal.
    /// @param proposalId The ID of the proposal for which to provide a recommendation.
    /// @param proposalData The data associated with the proposal (e.g., calldata, description).
    /// @return recommendation A string containing the AI's recommendation.
    /// @return confidence A value indicating the AI's confidence in its recommendation (e.g., a percentage).
    function getRecommendation(
        uint256 proposalId,
        bytes calldata proposalData
    ) external view returns (string memory recommendation, uint256 confidence);

    /// @notice Analyzes the potential impact of a proposal.
    /// @param proposalId The ID of the proposal to analyze.
    /// @param proposalData The data associated with the proposal.
    /// @return impactAnalysis A string detailing the AI's analysis of the proposal's potential impact.
    function analyzeImpact(
        uint256 proposalId,
        bytes calldata proposalData
    ) external view returns (string memory impactAnalysis);

    /// @notice Simulates the outcome of a vote based on current conditions and AI models.
    /// @param proposalId The ID of the proposal to simulate.
    /// @param proposalData The data associated with the proposal.
    /// @return simulatedOutcome A string describing the AI's simulated vote outcome.
    /// @return probability The probability of the simulated outcome.
    function simulateVoteOutcome(
        uint256 proposalId,
        bytes calldata proposalData
    ) external view returns (string memory simulatedOutcome, uint256 probability);

    /// @notice Provides a risk assessment for a given governance action.
    /// @param actionData The data describing the governance action.
    /// @return riskScore A numerical score indicating the assessed risk.
    /// @return riskDetails A string providing details about the identified risks.
    function assessRisk(
        bytes calldata actionData
    ) external view returns (uint256 riskScore, string memory riskDetails);

    /// @notice Event emitted when a governance recommendation is provided.
    /// @param proposalId The ID of the proposal.
    /// @param recommendation The AI's recommendation.
    /// @param confidence The AI's confidence level.
    event GovernanceRecommendationProvided(
        uint256 indexed proposalId,
        string recommendation,
        uint256 confidence
    );

    /// @notice Event emitted when a proposal impact analysis is completed.
    /// @param proposalId The ID of the proposal.
    /// @param impactAnalysis The AI's impact analysis.
    event ProposalImpactAnalyzed(
        uint256 indexed proposalId,
        string impactAnalysis
    );

    /// @notice Event emitted when a vote outcome simulation is completed.
    /// @param proposalId The ID of the proposal.
    /// @param simulatedOutcome The AI's simulated outcome.
    /// @param probability The probability of the simulated outcome.
    event VoteOutcomeSimulated(
        uint256 indexed proposalId,
        string simulatedOutcome,
        uint256 probability
    );

    /// @notice Event emitted when a risk assessment is completed.
    /// @param actionHash A hash of the action data.
    /// @param riskScore The assessed risk score.
    /// @param riskDetails Details about the risks.
    event RiskAssessmentCompleted(
        bytes32 indexed actionHash,
        uint256 riskScore,
        string riskDetails
    );

    /// @notice Error indicating that the proposal ID is invalid.
    error InvalidProposalId(uint256 proposalId);

    /// @notice Error indicating that the AI model is not available or not configured.
    error AIModelNotAvailable();

    /// @notice Error indicating that the input data is malformed or insufficient.
    error InvalidInputData(string message);
}