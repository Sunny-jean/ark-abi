// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title LiquidityRiskAI - AI for liquidity risk analysis
/// @notice This interface defines functions for an AI system that analyzes and predicts liquidity risks.
interface LiquidityRiskAI {
    /// @notice Analyzes the liquidity risk of a specific asset or pool.
    /// @param assetOrPoolIdentifier A string identifying the asset or liquidity pool.
    /// @return liquidityScore A numerical score representing liquidity (higher is better).
    /// @return riskLevel A string describing the liquidity risk level (e.g., "low", "medium", "high").
    /// @return analysisDetails A string providing details about the liquidity analysis.
    function analyzeLiquidityRisk(
        string calldata assetOrPoolIdentifier
    ) external view returns (uint256 liquidityScore, string memory riskLevel, string memory analysisDetails);

    /// @notice Predicts potential liquidity crunches or opportunities.
    /// @param assetOrPoolIdentifier The identifier of the asset or pool.
    /// @param predictionHorizon The future time horizon for the prediction.
    /// @return predictedLiquidityLevel The predicted future liquidity level.
    /// @return predictionConfidence The confidence level of the prediction.
    function predictLiquidityEvents(
        string calldata assetOrPoolIdentifier,
        uint256 predictionHorizon
    ) external view returns (uint256 predictedLiquidityLevel, uint256 predictionConfidence);

    /// @notice Event emitted when liquidity risk is analyzed.
    /// @param assetOrPoolIdentifier The identifier of the asset or pool.
    /// @param liquidityScore The calculated liquidity score.
    /// @param timestamp The timestamp of the analysis.
    event LiquidityRiskAnalyzed(
        string indexed assetOrPoolIdentifier,
        uint256 liquidityScore,
        uint256 timestamp
    );

    /// @notice Error indicating that the asset or pool identifier is invalid.
    error InvalidAssetOrPoolIdentifier(string assetOrPoolIdentifier);

    /// @notice Error indicating that liquidity data is insufficient or unavailable.
    error InsufficientLiquidityData();

    /// @notice Error indicating a failure in the liquidity risk analysis process.
    error LiquidityRiskAnalysisFailed(string message);
}