// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title AIDecisionEngine - AI-powered decision engine interface
/// @notice This interface defines the functions for an AI system that makes or assists in making decisions.
interface AIDecisionEngine {
    /// @notice Requests a decision from the AI engine based on provided context.
    /// @param contextData The data relevant to the decision (e.g., proposal details, market data).
    /// @return decision A string representing the AI's decision or recommendation.
    /// @return confidence A value indicating the AI's confidence in its decision.
    function requestDecision(
        bytes calldata contextData
    ) external view returns (string memory decision, uint256 confidence);

    /// @notice Evaluates a proposed action and provides a score or assessment.
    /// @param actionData The data describing the action to be evaluated.
    /// @return evaluationScore A numerical score for the action.
    /// @return evaluationDetails A string providing details about the evaluation.
    function evaluateAction(
        bytes calldata actionData
    ) external view returns (uint256 evaluationScore, string memory evaluationDetails);

    /// @notice Predicts the outcome of a specific event based on historical data and current context.
    /// @param eventData The data describing the event.
    /// @return predictedOutcome A string describing the predicted outcome.
    /// @return probability The probability of the predicted outcome.
    function predictOutcome(
        bytes calldata eventData
    ) external view returns (string memory predictedOutcome, uint256 probability);

    /// @notice Event emitted when a decision is made or recommended by the AI engine.
    /// @param decisionId A unique identifier for the decision.
    /// @param contextHash A hash of the context data.
    /// @param decision The AI's decision.
    /// @param confidence The AI's confidence level.
    event DecisionMade(
        uint256 indexed decisionId,
        bytes32 indexed contextHash,
        string decision,
        uint256 confidence
    );

    /// @notice Event emitted when an action evaluation is completed.
    /// @param actionHash A hash of the action data.
    /// @param evaluationScore The score of the action.
    /// @param evaluationDetails Details about the evaluation.
    event ActionEvaluated(
        bytes32 indexed actionHash,
        uint256 evaluationScore,
        string evaluationDetails
    );

    /// @notice Event emitted when an outcome prediction is made.
    /// @param eventHash A hash of the event data.
    /// @param predictedOutcome The predicted outcome.
    /// @param probability The probability of the predicted outcome.
    event OutcomePredicted(
        bytes32 indexed eventHash,
        string predictedOutcome,
        uint256 probability
    );

    /// @notice Error indicating that the decision context is invalid or insufficient.
    error InvalidDecisionContext(string message);

    /// @notice Error indicating that the AI model for decision making is not ready.
    error DecisionModelNotReady();

    /// @notice Error indicating a failure in the decision-making process.
    error DecisionProcessFailed(string message);
}