// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface ICapForecastingModel {
    event CapForecasted(uint256 indexed forecastedCap, uint256 indexed timestamp, string indexed modelUsed);

    error ForecastFailed(string reason);

    function forecastCap(uint256 _supportingQuantity, uint256 _marketSentiment) external;
    function setForecastingModel(string calldata _model) external;
    function getForecastingModel() external view returns (string memory);
}

contract CapForecastingModel is ICapForecastingModel, Ownable {
    string private s_forecastingModel;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function forecastCap(uint256 _supportingQuantity, uint256 _marketSentiment) external onlyOwner {

        // This would involve calculations based on supporting quantity, market sentiment,
        // and other factors to predict future minting caps.
        uint256 forecastedCap = (_supportingQuantity * _marketSentiment) / 100; // Example calculation

        if (forecastedCap == 0) {
            revert ForecastFailed("Calculated forecasted cap is zero.");
        }

        emit CapForecasted(forecastedCap, block.timestamp, s_forecastingModel);
    }

    function setForecastingModel(string calldata _model) external onlyOwner {
        s_forecastingModel = _model;
    }

    function getForecastingModel() external view returns (string memory) {
        return s_forecastingModel;
    }
}