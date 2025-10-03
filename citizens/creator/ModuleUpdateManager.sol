// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ModuleUpdateManager {
    /**
     * @dev Emitted when a module update is proposed.
     * @param moduleId The unique ID of the module.
     * @param updateId The unique ID of the proposed update.
     * @param newVersion The new version string.
     */
    event UpdateProposed(bytes32 indexed moduleId, bytes32 indexed updateId, string newVersion);

    /**
     * @dev Emitted when a module update is approved and applied.
     * @param moduleId The unique ID of the module.
     * @param updateId The unique ID of the applied update.
     * @param newVersion The new version string.
     */
    event UpdateApplied(bytes32 indexed moduleId, bytes32 indexed updateId, string newVersion);

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
     * @dev Thrown when the specified module is not found.
     */
    error ModuleNotFound(bytes32 moduleId);

    /**
     * @dev Thrown when an update is not found or not applicable.
     */
    error UpdateNotApplicable(bytes32 updateId);

    /**
     * @dev Proposes an update for an existing module.
     * @param moduleId The unique ID of the module to update.
     * @param newVersion The new version string for the module.
     * @param updateData The data for the update (e.g., new code hash, changelog).
     * @return updateId The unique ID of the proposed update.
     */
    function proposeModuleUpdate(bytes32 moduleId, string calldata newVersion, bytes calldata updateData) external returns (bytes32 updateId);

    /**
     * @dev Approves and applies a proposed module update.
     * @param updateId The unique ID of the update to apply.
     */
    function applyModuleUpdate(bytes32 updateId) external;

    /**
     * @dev Retrieves the status of a proposed module update.
     * @param updateId The unique ID of the update.
     * @return moduleId The ID of the module being updated.
     * @return newVersion The proposed new version.
     * @return status The current status of the update (e.g., "proposed", "approved", "applied", "rejected").
     */
    function getUpdateStatus(bytes32 updateId) external view returns (bytes32 moduleId, string memory newVersion, string memory status);
}