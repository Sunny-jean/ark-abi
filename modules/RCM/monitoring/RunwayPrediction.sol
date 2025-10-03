// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRunwayPrediction {
    event PredictionUpdated(uint256 indexed predictedDays, uint256 indexed timestamp, string indexed modelUsed);

    error PredictionFailed(string message);

    function updatePrediction(uint256 _tvl, uint256 _roi, uint256 _emissionRate) external;
    function getPredictedRunway() external view returns (uint256);
    function setPredictionModel(string calldata _model) external;
}

contract RunwayPrediction is IRunwayPrediction, Ownable {
    uint256 private s_predictedRunwayDays;
    string private s_predictionModel;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function updatePrediction(uint256 _tvl, uint256 _roi, uint256 _emissionRate) external onlyOwner {
        if (_tvl == 0 || _roi == 0 || _emissionRate == 0) {
            revert PredictionFailed("Input parameters cannot be zero.");
        }

        // This would integrate TVL, ROI, and emission rate to forecast runway.
        s_predictedRunwayDays = (_tvl * _roi) / _emissionRate; // Example calculation
        emit PredictionUpdated(s_predictedRunwayDays, block.timestamp, s_predictionModel);
    }

    function getPredictedRunway() external view returns (uint256) {
        return s_predictedRunwayDays;
    }

    function setPredictionModel(string calldata _model) external onlyOwner {
        s_predictionModel = _model;
    }
}