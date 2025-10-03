// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPredictiveAnalyticsModel {
    event ForecastGenerated(uint256 indexed forecastId, uint256 indexed predictedValue, uint256 timestamp);

    error PredictionFailed(string message);

    function generateForecast(bytes calldata _inputData) external returns (uint256 predictedValue);
    function getForecast(uint256 _forecastId) external view returns (uint256 predictedValue, uint256 timestamp);
}