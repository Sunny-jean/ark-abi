// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title AIModelRegistry - Registry for AI models
/// @notice This interface defines functions for registering, retrieving, and managing AI models within the system.
interface AIModelRegistry {
    /// @notice Registers a new AI model.
    /// @param modelName The name of the AI model.
    /// @param modelHash A unique hash representing the model's code or configuration.
    /// @param modelType A string describing the type of model (e.g., "forecasting", "risk_assessment").
    /// @return modelId The unique identifier assigned to the registered model.
    function registerModel(
        string calldata modelName,
        bytes32 modelHash,
        string calldata modelType
    ) external returns (uint256 modelId);

    /// @notice Retrieves the details of a registered AI model.
    /// @param modelId The unique identifier of the model.
    /// @return modelName The name of the AI model.
    /// @return modelHash The hash representing the model's code or configuration.
    /// @return modelType The type of the model.
    /// @return isActive True if the model is active, false otherwise.
    function getModelDetails(
        uint256 modelId
    ) external view returns (string memory modelName, bytes32 modelHash, string memory modelType, bool isActive);

    /// @notice Activates a registered AI model, making it available for use.
    /// @param modelId The unique identifier of the model to activate.
    /// @return success True if the model was activated successfully, false otherwise.
    function activateModel(
        uint256 modelId
    ) external returns (bool success);

    /// @notice Deactivates a registered AI model, making it unavailable for use.
    /// @param modelId The unique identifier of the model to deactivate.
    /// @return success True if the model was deactivated successfully, false otherwise.
    function deactivateModel(
        uint256 modelId
    ) external returns (bool success);

    /// @notice Event emitted when an AI model is registered.
    /// @param modelId The unique identifier of the model.
    /// @param modelName The name of the model.
    /// @param modelType The type of the model.
    /// @param timestamp The timestamp of registration.
    event ModelRegistered(
        uint256 indexed modelId,
        string modelName,
        string modelType,
        uint256 timestamp
    );

    /// @notice Event emitted when an AI model's status changes (activated/deactivated).
    /// @param modelId The unique identifier of the model.
    /// @param isActive The new active status.
    /// @param timestamp The timestamp of the status change.
    event ModelStatusChanged(
        uint256 indexed modelId,
        bool isActive,
        uint256 timestamp
    );

    /// @notice Error indicating that the model ID is invalid.
    error InvalidModelId(uint256 modelId);

    /// @notice Error indicating that a model with the given hash already exists.
    error ModelAlreadyExists(bytes32 modelHash);

    /// @notice Error indicating a failure in model registration or management.
    error ModelManagementFailed(string message);
}