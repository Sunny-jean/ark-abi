// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface MarketTrendPredictor {
    /**
     * @dev Emitted when a new market prediction is generated.
     * @param predictionId The unique ID of the prediction.
     * @param assetId The ID of the asset being predicted.
     * @param predictedValue The predicted value.
     */
    event PredictionGenerated(bytes32 indexed predictionId, bytes32 indexed assetId, uint256 predictedValue);

    /**
     * @dev Emitted when a prediction model is updated.
     * @param modelId The ID of the updated model.
     * @param modelHash A hash of the new model definition.
     */
    event PredictionModelUpdated(bytes32 indexed modelId, bytes32 modelHash);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a required parameter is missing or invalid.
     */
    error InvalidParameter(string parameterName, string description);

    /**
     * @dev Thrown when the specified asset is not found.
     */
    error AssetNotFound(bytes32 assetId);

    /**
     * @dev Thrown when prediction generation fails.
     */
    error PredictionFailed(bytes32 assetId, string reason);

    /**
     * @dev Triggers the AI to generate a market trend prediction for a specific asset.
     * @param assetId The unique ID of the asset to predict (e.g., module ID, token address).
     * @param predictionType The type of prediction (e.g., "price_movement", "demand_forecast").
     * @param predictionParameters Additional parameters for the prediction model.
     * @return predictionId The unique ID generated for this prediction.
     */
    function generatePrediction(bytes32 assetId, string calldata predictionType, bytes calldata predictionParameters) external returns (bytes32 predictionId);

    /**
     * @dev Retrieves a previously generated market prediction.
     * @param predictionId The unique ID of the prediction.
     * @return assetId The ID of the asset.
     * @return predictedValue The predicted numerical value.
     * @return confidenceScore The confidence level of the prediction (0-100).
     */
    function getPrediction(bytes32 predictionId) external view returns (bytes32 assetId, uint256 predictedValue, uint256 confidenceScore);

    /**
     * @dev Updates the underlying AI model used for market trend prediction.
     * @param modelId The unique ID of the model to update.
     * @param modelDefinition The new definition of the prediction model.
     */
    function updatePredictionModel(bytes32 modelId, bytes calldata modelDefinition) external;
}