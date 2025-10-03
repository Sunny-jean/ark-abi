// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title PriceForecastingAI - AI for price forecasting
/// @notice This interface defines functions for an AI system that forecasts asset prices.
interface PriceForecastingAI {
    /// @notice Forecasts the price of a given asset for a specified future timestamp.
    /// @param assetIdentifier A string identifying the asset (e.g., "ETH", "DAO").
    /// @param forecastTimestamp The future timestamp for which to forecast the price.
    /// @return forecastedPrice The predicted price of the asset.
    /// @return confidenceIntervalLower The lower bound of the confidence interval for the forecast.
    /// @return confidenceIntervalUpper The upper bound of the confidence interval for the forecast.
    function forecastPrice(
        string calldata assetIdentifier,
        uint256 forecastTimestamp
    ) external view returns (
        uint256 forecastedPrice,
        uint256 confidenceIntervalLower,
        uint256 confidenceIntervalUpper
    );

    /// @notice Retrieves a series of price forecasts for an asset over a period.
    /// @param assetIdentifier The identifier of the asset.
    /// @param startTimestamp The starting timestamp for the forecast series.
    /// @param endTimestamp The ending timestamp for the forecast series.
    /// @param interval The time interval between forecasts (e.g., 1 hour, 1 day).
    /// @return forecastSeries An array of forecasted prices.
    /// @return timestamps An array of timestamps corresponding to the forecasts.
    function getPriceForecastSeries(
        string calldata assetIdentifier,
        uint256 startTimestamp,
        uint256 endTimestamp,
        uint256 interval
    ) external view returns (uint256[] memory forecastSeries, uint256[] memory timestamps);

    /// @notice Event emitted when a price forecast is generated.
    /// @param assetIdentifier The identifier of the asset.
    /// @param forecastTimestamp The timestamp for which the price was forecasted.
    /// @param forecastedPrice The predicted price.
    event PriceForecasted(
        string indexed assetIdentifier,
        uint256 indexed forecastTimestamp,
        uint256 forecastedPrice
    );

    /// @notice Error indicating that the asset identifier is invalid.
    error InvalidAssetIdentifier(string assetIdentifier);

    /// @notice Error indicating that forecasting data is insufficient or unavailable.
    error InsufficientForecastingData();

    /// @notice Error indicating a failure in the price forecasting process.
    error PriceForecastingFailed(string message);
}