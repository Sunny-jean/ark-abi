// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title DemandForecastAI - AI for demand forecasting
/// @notice This interface defines functions for an AI system that forecasts demand for assets or services.
interface DemandForecastAI {
    /// @notice Forecasts the demand for a specific asset or service for a given future period.
    /// @param assetOrServiceIdentifier A string identifying the asset or service.
    /// @param forecastPeriodStart The start timestamp of the forecast period.
    /// @param forecastPeriodEnd The end timestamp of the forecast period.
    /// @return forecastedDemand The predicted demand quantity.
    /// @return demandUnit The unit of demand (e.g., "tokens", "users", "transactions").
    function forecastDemand(
        string calldata assetOrServiceIdentifier,
        uint256 forecastPeriodStart,
        uint256 forecastPeriodEnd
    ) external view returns (uint256 forecastedDemand, string memory demandUnit);

    /// @notice Retrieves historical demand data for an asset or service.
    /// @param assetOrServiceIdentifier The identifier of the asset or service.
    /// @param startTime The start timestamp for the historical data.
    /// @param endTime The end timestamp for the historical data.
    /// @return historicalDemands An array of historical demand quantities.
    /// @return timestamps An array of timestamps corresponding to the demands.
    function getHistoricalDemand(
        string calldata assetOrServiceIdentifier,
        uint256 startTime,
        uint256 endTime
    ) external view returns (uint256[] memory historicalDemands, uint256[] memory timestamps);

    /// @notice Event emitted when demand is forecasted.
    /// @param assetOrServiceIdentifier The identifier of the asset or service.
    /// @param forecastedDemand The predicted demand quantity.
    /// @param forecastPeriodEnd The end timestamp of the forecast period.
    event DemandForecasted(
        string indexed assetOrServiceIdentifier,
        uint256 forecastedDemand,
        uint256 indexed forecastPeriodEnd
    );

    /// @notice Error indicating that the asset or service identifier is invalid.
    error InvalidAssetOrServiceIdentifier(string assetOrServiceIdentifier);

    /// @notice Error indicating that demand data is insufficient or unavailable.
    error InsufficientDemandData();

    /// @notice Error indicating a failure in the demand forecasting process.
    error DemandForecastingFailed(string message);
}