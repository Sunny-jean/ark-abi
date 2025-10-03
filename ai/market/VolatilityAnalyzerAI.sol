// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title VolatilityAnalyzerAI - AI for analyzing market volatility
/// @notice This interface defines functions for an AI system that analyzes and predicts market volatility.
interface VolatilityAnalyzerAI {
    /// @notice Analyzes the current volatility of a given asset or the overall market.
    /// @param assetIdentifier A string identifying the asset (e.g., "ETH", "DAO"). Use "overall" for general market volatility.
    /// @param period The time period over which to calculate volatility (e.g., 1 day, 7 days).
    /// @return volatilityScore A numerical score representing volatility (higher score means higher volatility).
    /// @return volatilityDetails A string providing details about the volatility analysis.
    function analyzeVolatility(
        string calldata assetIdentifier,
        uint256 period
    ) external view returns (uint256 volatilityScore, string memory volatilityDetails);

    /// @notice Predicts future volatility for a given asset.
    /// @param assetIdentifier The identifier of the asset.
    /// @param predictionPeriod The future time period for which to predict volatility.
    /// @return predictedVolatility The predicted volatility score.
    /// @return predictionConfidence The confidence level of the prediction.
    function predictVolatility(
        string calldata assetIdentifier,
        uint256 predictionPeriod
    ) external view returns (uint256 predictedVolatility, uint256 predictionConfidence);

    /// @notice Event emitted when market volatility is analyzed.
    /// @param assetIdentifier The identifier of the asset.
    /// @param volatilityScore The calculated volatility score.
    /// @param timestamp The timestamp of the analysis.
    event VolatilityAnalyzed(
        string indexed assetIdentifier,
        uint256 volatilityScore,
        uint256 timestamp
    );

    /// @notice Error indicating that the asset identifier is invalid.
    error InvalidAssetIdentifier(string assetIdentifier);

    /// @notice Error indicating that volatility data is not available for the specified period.
    error VolatilityDataNotAvailable();

    /// @notice Error indicating a failure in the volatility analysis process.
    error VolatilityAnalysisFailed(string message);
}