// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ModelDeploymentAI - AI for model deployment
/// @notice This interface defines functions for an AI system that manages the deployment of AI models.
interface ModelDeploymentAI {
    /// @notice Deploys a specified AI model to a target environment.
    /// @param modelId The unique identifier of the model to deploy.
    /// @param targetEnvironment A string describing the deployment target (e.g., "production", "staging").
    /// @param deploymentConfigHash A hash of the deployment configuration.
    /// @return deploymentId A unique identifier for the deployment instance.
    function deployModel(
        uint256 modelId,
        string calldata targetEnvironment,
        bytes32 deploymentConfigHash
    ) external returns (uint256 deploymentId);

    /// @notice Retrieves the status of a specific model deployment.
    /// @param deploymentId The unique identifier of the deployment.
    /// @return status A string describing the deployment status (e.g., "pending", "in_progress", "completed", "failed").
    /// @return details A string providing further details about the deployment status.
    function getDeploymentStatus(
        uint256 deploymentId
    ) external view returns (string memory status, string memory details);

    /// @notice Rolls back a deployed model to a previous version or state.
    /// @param deploymentId The unique identifier of the deployment to roll back.
    /// @param previousVersionHash A hash of the previous model version or state.
    /// @return success True if the rollback was successful, false otherwise.
    function rollbackDeployment(
        uint256 deploymentId,
        bytes32 previousVersionHash
    ) external returns (bool success);

    /// @notice Event emitted when an AI model deployment is initiated.
    /// @param deploymentId The unique identifier of the deployment.
    /// @param modelId The unique identifier of the model.
    /// @param targetEnvironment The deployment target.
    /// @param timestamp The timestamp of initiation.
    event ModelDeploymentInitiated(
        uint256 indexed deploymentId,
        uint256 indexed modelId,
        string targetEnvironment,
        uint256 timestamp
    );

    /// @notice Event emitted when a model deployment status changes.
    /// @param deploymentId The unique identifier of the deployment.
    /// @param status The new status of the deployment.
    /// @param timestamp The timestamp of the status change.
    event ModelDeploymentStatusChanged(
        uint256 indexed deploymentId,
        string status,
        uint256 timestamp
    );

    /// @notice Error indicating that the model ID is invalid.
    error InvalidModelId(uint256 modelId);

    /// @notice Error indicating that the deployment ID is invalid.
    error InvalidDeploymentId(uint256 deploymentId);

    /// @notice Error indicating a failure in the model deployment process.
    error ModelDeploymentFailed(string message);
}