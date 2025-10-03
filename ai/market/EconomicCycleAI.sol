// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title EconomicCycleAI - AI for detecting economic cycles
/// @notice This interface defines functions for an AI system that identifies and analyzes economic cycles.
interface EconomicCycleAI {
    /// @notice Detects the current phase of the economic cycle.
    /// @return cyclePhase A string describing the detected economic cycle phase (e.g., "expansion", "peak", "contraction", "trough").
    /// @return confidenceScore A numerical score indicating the confidence of the detection.
    /// @return details A string providing details about the economic cycle analysis.
    function detectEconomicCyclePhase(
    ) external view returns (string memory cyclePhase, uint256 confidenceScore, string memory details);

    /// @notice Predicts the next phase of the economic cycle.
    /// @param predictionHorizon The future time horizon for the prediction.
    /// @return predictedNextPhase The predicted next economic cycle phase.
    /// @return predictionConfidence The confidence level of the prediction.
    function predictNextEconomicCyclePhase(
        uint256 predictionHorizon
    ) external view returns (string memory predictedNextPhase, uint256 predictionConfidence);

    /// @notice Event emitted when an economic cycle phase is detected.
    /// @param cyclePhase The detected economic cycle phase.
    /// @param timestamp The timestamp of the detection.
    event EconomicCyclePhaseDetected(
        string cyclePhase,
        uint256 timestamp
    );

    /// @notice Error indicating that economic data is insufficient or unavailable.
    error InsufficientEconomicData();

    /// @notice Error indicating a failure in the economic cycle detection process.
    error EconomicCycleDetectionFailed(string message);
}