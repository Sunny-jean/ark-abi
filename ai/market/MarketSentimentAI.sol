// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title MarketSentimentAI - AI for market sentiment analysis
/// @notice This interface defines functions for an AI system that analyzes market sentiment from various data sources.
interface MarketSentimentAI {
    /// @notice Analyzes current market sentiment for a given asset or the overall market.
    /// @param assetIdentifier A string identifying the asset (e.g., "ETH", "DAO"). Use "overall" for general market sentiment.
    /// @return sentimentScore A numerical score representing sentiment (e.g., -100 to 100, where 0 is neutral).
    /// @return sentimentDetails A string providing details about the sentiment analysis.
    function analyzeSentiment(
        string calldata assetIdentifier
    ) external view returns (int256 sentimentScore, string memory sentimentDetails);

    /// @notice Retrieves historical sentiment data for a given asset over a period.
    /// @param assetIdentifier The identifier of the asset.
    /// @param startTime The start timestamp for the historical data.
    /// @param endTime The end timestamp for the historical data.
    /// @return historicalScores An array of sentiment scores.
    /// @return timestamps An array of timestamps corresponding to the scores.
    function getHistoricalSentiment(
        string calldata assetIdentifier,
        uint256 startTime,
        uint256 endTime
    ) external view returns (int256[] memory historicalScores, uint256[] memory timestamps);

    /// @notice Event emitted when market sentiment is analyzed.
    /// @param assetIdentifier The identifier of the asset.
    /// @param sentimentScore The calculated sentiment score.
    /// @param timestamp The timestamp of the analysis.
    event MarketSentimentAnalyzed(
        string indexed assetIdentifier,
        int256 sentimentScore,
        uint256 timestamp
    );

    /// @notice Error indicating that the asset identifier is invalid.
    error InvalidAssetIdentifier(string assetIdentifier);

    /// @notice Error indicating that sentiment data is not available for the specified period.
    error SentimentDataNotAvailable();

    /// @notice Error indicating a failure in the sentiment analysis process.
    error SentimentAnalysisFailed(string message);
}