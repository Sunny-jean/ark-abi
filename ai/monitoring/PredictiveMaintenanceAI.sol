// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface PredictiveMaintenanceAI {
    /**
     * @dev Emitted when a potential system failure is predicted.
     * @param componentName The name of the component predicted to fail.
     * @param failureProbability The probability of failure (e.g., 0-100).
     * @param predictedTimeOfFailure The estimated time of failure.
     * @param details A detailed message about the prediction.
     */
    event FailurePredicted(string componentName, uint256 failureProbability, uint256 predictedTimeOfFailure, string details);

    /**
     * @dev Emitted when maintenance recommendations are issued.
     * @param recommendationId A unique identifier for the recommendation.
     * @param componentName The component for which maintenance is recommended.
     * @param recommendationType The type of maintenance recommended (e.g., "Preventive", "Corrective").
     * @param urgency The urgency of the recommendation (e.g., "High", "Medium", "Low").
     */
    event MaintenanceRecommended(bytes32 recommendationId, string componentName, string recommendationType, string urgency);

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
     * @dev Thrown when a prediction cannot be made for the specified component.
     */
    error PredictionUnavailable(string componentName);

    /**
     * @dev Predicts potential failures for a given system component based on historical data and current metrics.
     * This function would typically trigger an off-chain AI model to perform the prediction.
     * @param componentName The name of the component to predict failure for.
     * @param dataHash A hash of the current operational data for the component.
     * @return failureProbability The probability of failure (e.g., 0-100).
     * @return predictedTimeOfFailure The estimated time of failure (Unix timestamp).
     */
    function predictFailure(string calldata componentName, bytes32 dataHash) external returns (uint256 failureProbability, uint256 predictedTimeOfFailure);

    /**
     * @dev Recommends proactive maintenance actions based on predicted failures or system degradation.
     * @param componentName The name of the component requiring maintenance.
     * @param failureProbability The predicted probability of failure for context.
     * @return recommendationId A unique identifier for the recommendation.
     * @return recommendationType The type of maintenance recommended (e.g., "Preventive", "Corrective").
     * @return urgency The urgency of the recommendation (e.g., "High", "Medium", "Low").
     */
    function recommendMaintenance(string calldata componentName, uint256 failureProbability) external returns (bytes32 recommendationId, string memory recommendationType, string memory urgency);

    /**
     * @dev Submits operational data for a component to be used in predictive models.
     * @param componentName The name of the component.
     * @param data The operational data (e.g., sensor readings, usage statistics).
     */
    function submitOperationalData(string calldata componentName, bytes calldata data) external;

    /**
     * @dev Retrieves the status of a maintenance recommendation.
     * @param recommendationId The unique identifier for the recommendation.
     * @return status The current status (e.g., "Pending", "InProgress", "Completed").
     * @return notes Additional notes or updates on the recommendation.
     */
    function getMaintenanceRecommendationStatus(bytes32 recommendationId) external view returns (string memory status, string memory notes);
}