// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ModuleLifecycleController {
    /**
     * @dev Emitted when a module's status changes.
     * @param moduleId The unique ID of the module.
     * @param oldStatus The previous status.
     * @param newStatus The new status (e.g., "active", "paused", "deprecated", "terminated").
     */
    event ModuleStatusChanged(bytes32 indexed moduleId, string oldStatus, string newStatus);

    /**
     * @dev Emitted when a module is terminated.
     * @param moduleId The unique ID of the module.
     * @param reason The reason for termination.
     */
    event ModuleTerminated(bytes32 indexed moduleId, string reason);

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
     * @dev Thrown when a status transition is invalid.
     */
    error InvalidStatusTransition(bytes32 moduleId, string currentStatus, string desiredStatus);

    /**
     * @dev Changes the operational status of a module.
     * @param moduleId The unique ID of the module.
     * @param newStatus The desired new status for the module.
     */
    function changeModuleStatus(bytes32 moduleId, string calldata newStatus) external;

    /**
     * @dev Terminates a module, making it permanently inactive.
     * @param moduleId The unique ID of the module to terminate.
     * @param reason The reason for termination.
     */
    function terminateModule(bytes32 moduleId, string calldata reason) external;

    /**
     * @dev Retrieves the current lifecycle status of a module.
     * @param moduleId The unique ID of the module.
     * @return status The current status of the module.
     */
    function getModuleStatus(bytes32 moduleId) external view returns (string memory status);
}