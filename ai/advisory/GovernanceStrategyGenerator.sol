// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title GovernanceStrategyGenerator - AI-powered governance strategy generator interface
/// @notice This interface defines the functions for an AI system that generates optimal governance strategies.
interface GovernanceStrategyGenerator {
    /// @notice Generates a new governance strategy based on current system state and goals.
    /// @param currentSystemState A bytes array representing the current state of the governance system.
    /// @param desiredGoals A string array outlining the desired outcomes or goals.
    /// @return strategyId A unique identifier for the generated strategy.
    /// @return strategyDetails A string containing the details of the generated strategy.
    function generateStrategy(
        bytes calldata currentSystemState,
        string[] calldata desiredGoals
    ) external view returns (uint256 strategyId, string memory strategyDetails);

    /// @notice Evaluates the effectiveness of a given governance strategy.
    /// @param strategyId The ID of the strategy to evaluate.
    /// @param strategyDetails The details of the strategy.
    /// @return effectivenessScore A numerical score indicating the strategy's effectiveness.
    /// @return evaluationReport A string containing a detailed report of the evaluation.
    function evaluateStrategy(
        uint256 strategyId,
        string calldata strategyDetails
    ) external view returns (uint256 effectivenessScore, string memory evaluationReport);

    /// @notice Recommends adjustments to an existing strategy based on new data or performance.
    /// @param strategyId The ID of the strategy to adjust.
    /// @param performanceData New data or performance metrics.
    /// @return adjustments A string detailing the recommended adjustments.
    function recommendAdjustments(
        uint256 strategyId,
        bytes calldata performanceData
    ) external view returns (string memory adjustments);

    /// @notice Event emitted when a new governance strategy is generated.
    /// @param strategyId The unique identifier of the strategy.
    /// @param strategyDetails The details of the generated strategy.
    /// @param generatedAt The timestamp of generation.
    event GovernanceStrategyGenerated(
        uint256 indexed strategyId,
        string strategyDetails,
        uint256 generatedAt
    );

    /// @notice Event emitted when a governance strategy is evaluated.
    /// @param strategyId The unique identifier of the strategy.
    /// @param effectivenessScore The effectiveness score.
    /// @param evaluationReport The evaluation report.
    event GovernanceStrategyEvaluated(
        uint256 indexed strategyId,
        uint256 effectivenessScore,
        string evaluationReport
    );

    /// @notice Event emitted when adjustments to a strategy are recommended.
    /// @param strategyId The unique identifier of the strategy.
    /// @param adjustments The recommended adjustments.
    event StrategyAdjustmentsRecommended(
        uint256 indexed strategyId,
        string adjustments
    );

    /// @notice Error indicating that strategy generation failed.
    error StrategyGenerationFailed(string message);

    /// @notice Error indicating that the strategy ID is invalid.
    error InvalidStrategyId(uint256 strategyId);

    /// @notice Error indicating that the input data for strategy generation is invalid.
    error InvalidStrategyInput(string message);
}