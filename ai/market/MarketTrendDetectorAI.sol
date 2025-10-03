// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title MarketTrendDetectorAI - AI for detecting market trends
/// @notice This interface defines functions for an AI system that identifies and analyzes market trends.
interface MarketTrendDetectorAI {
    /// @notice Detects the current trend for a given asset or the overall market.
    /// @param assetIdentifier A string identifying the asset (e.g., "ETH", "DAO"). Use "overall" for general market trends.
    /// @param period The time period over which to detect the trend.
    /// @return trendType A string describing the detected trend (e.g., "bullish", "bearish", "sideways").
    /// @return trendStrength A numerical score indicating the strength of the trend.
    /// @return trendDetails A string providing details about the trend analysis.
    function detectTrend(
        string calldata assetIdentifier,
        uint256 period
    ) external view returns (string memory trendType, uint256 trendStrength, string memory trendDetails);

    /// @notice Predicts the continuation or reversal of a trend for a given asset.
    /// @param assetIdentifier The identifier of the asset.
    /// @param predictionHorizon The future time horizon for the prediction.
    /// @return predictedTrendType The predicted future trend type.
    /// @return predictionConfidence The confidence level of the prediction.
    function predictTrend(
        string calldata assetIdentifier,
        uint256 predictionHorizon
    ) external view returns (string memory predictedTrendType, uint256 predictionConfidence);

    /// @notice Event emitted when a market trend is detected.
    /// @param assetIdentifier The identifier of the asset.
    /// @param trendType The detected trend type.
    /// @param timestamp The timestamp of the detection.
    event MarketTrendDetected(
        string indexed assetIdentifier,
        string trendType,
        uint256 timestamp
    );

    /// @notice Error indicating that the asset identifier is invalid.
    error InvalidAssetIdentifier(string assetIdentifier);

    /// @notice Error indicating that trend data is insufficient or unavailable.
    error TrendDataNotAvailable();

    /// @notice Error indicating a failure in the trend detection process.
    error TrendDetectionFailed(string message);
}