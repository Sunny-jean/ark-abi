// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ModuleDeploymentFactory {
    /**
     * @dev Emitted when a new module is deployed.
     * @param moduleId The unique ID of the deployed module.
     * @param creatorId The ID of the creator who deployed the module.
     * @param moduleAddress The address of the deployed module contract.
     */
    event ModuleDeployed(bytes32 indexed moduleId, bytes32 indexed creatorId, address indexed moduleAddress);

    /**
     * @dev Emitted when a module deployment configuration is updated.
     * @param moduleId The unique ID of the module.
     * @param configHash A hash of the new configuration.
     */
    event DeploymentConfigUpdated(bytes32 indexed moduleId, bytes32 configHash);

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
     * @dev Thrown when the specified creator is not authorized to deploy.
     */
    error CreatorNotAuthorized(bytes32 creatorId);

    /**
     * @dev Thrown when module deployment fails.
     */
    error DeploymentFailed(bytes32 moduleId, string reason);

    /**
     * @dev Deploys a new module contract.
     * @param creatorId The ID of the creator deploying the module.
     * @param moduleType The type of module to deploy.
     * @param deploymentConfig Configuration data for the module deployment.
     * @return moduleId The unique ID of the newly deployed module.
     * @return moduleAddress The address of the deployed module contract.
     */
    function deployModule(bytes32 creatorId, string calldata moduleType, bytes calldata deploymentConfig) external returns (bytes32 moduleId, address moduleAddress);

    /**
     * @dev Updates the deployment configuration for an existing module.
     * @param moduleId The unique ID of the module.
     * @param newConfig Configuration data for the module deployment.
     */
    function updateDeploymentConfig(bytes32 moduleId, bytes calldata newConfig) external;

    /**
     * @dev Retrieves the deployment details of a module.
     * @param moduleId The unique ID of the module.
     * @return creatorId The ID of the creator.
     * @return moduleAddress The address of the deployed module contract.
     * @return moduleType The type of module.
     */
    function getModuleDeploymentDetails(bytes32 moduleId) external view returns (bytes32 creatorId, address moduleAddress, string memory moduleType);
}