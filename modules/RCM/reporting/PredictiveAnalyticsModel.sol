// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IPredictiveAnalyticsModel {
    event PredictionMade(uint256 indexed timestamp, uint256 indexed predictedValue, string indexed metric);

    error PredictionFailed(string message);

    function makePrediction(uint256[] calldata _historicalData, string calldata _metric) external;
    function getLastPrediction(string calldata _metric) external view returns (uint256);
}

contract PredictiveAnalyticsModel is IPredictiveAnalyticsModel, Ownable {
    mapping(string => uint256) private s_lastPredictions;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function makePrediction(uint256[] calldata _historicalData, string calldata _metric) external onlyOwner {
        require(_historicalData.length > 0, "Historical data cannot be empty.");


        // This would involve complex mathematical operations based on historical data.
        uint256 predictedValue = _historicalData[_historicalData.length - 1] + 10; // Simple example: last value + 10

        s_lastPredictions[_metric] = predictedValue;
        emit PredictionMade(block.timestamp, predictedValue, _metric);
    }

    function getLastPrediction(string calldata _metric) external view returns (uint256) {
        return s_lastPredictions[_metric];
    }
}