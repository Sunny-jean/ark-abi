// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAIModel {
    /**
     * @dev Emitted when a model is queried.
     * @param modelId The unique identifier of the model.
     * @param queryHash A hash of the input query.
     * @param responseHash A hash of the output response.
     */
    event ModelQueried(bytes32 modelId, bytes32 queryHash, bytes32 responseHash);

    /**
     * @dev Emitted when a model's version is updated.
     * @param modelId The unique identifier of the model.
     * @param oldVersion The previous version string.
     * @param newVersion The new version string.
     */
    event ModelVersionUpdated(bytes32 modelId, string oldVersion, string newVersion);

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
     * @dev Thrown when the model encounters an internal error during processing.
     */
    error ModelProcessingError(string message);

    /**
     * @dev Returns the current version of the AI model.
     * @return version_ The version string of the model.
     */
    function getVersion() external view returns (string memory version_);

    /**
     * @dev Queries the AI model with specific input data.
     * The interpretation of `inputData` and `outputData` depends on the specific model's implementation.
     * @param inputData The input data for the AI model, encoded as bytes.
     * @return outputData The output data from the AI model, encoded as bytes.
     */
    function query(bytes calldata inputData) external returns (bytes memory outputData);

    /**
     * @dev Sets the model's status (e.g., active, inactive, maintenance).
     * Only authorized addresses should be able to change the status.
     * @param newStatus The new status to set.
     */
    function setStatus(string calldata newStatus) external;

    /**
     * @dev Retrieves the current status of the model.
     * @return status The current status string.
     */
    function getStatus() external view returns (string memory status);

    /**
     * @dev Allows for upgrading the model's underlying logic or data.
     * This could involve pointing to a new off-chain model endpoint or updating on-chain parameters.
     * @param newModelHash A hash representing the new model's logic or data.
     * @param newVersion The new version string for the model.
     */
    function upgradeModel(bytes32 newModelHash, string calldata newVersion) external;
}