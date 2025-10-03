// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ModuleUsageTracker {
    /**
     * @dev Emitted when a module usage event is recorded.
     * @param moduleId The ID of the module used.
     * @param user The address of the user.
     * @param usageType The type of usage event.
     */
    event ModuleUsed(bytes32 indexed moduleId, address indexed user, string indexed usageType);

    /**
     * @dev Emitted when usage statistics are updated.
     * @param moduleId The ID of the module.
     * @param totalUses The total number of uses.
     */
    event UsageStatisticsUpdated(bytes32 indexed moduleId, uint256 totalUses);

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
     * @dev Records a usage event for a specific module.
     * @param moduleId The unique ID of the module being used.
     * @param user The address of the user who used the module.
     * @param usageType The type of usage (e.g., "execution", "view", "configuration").
     * @param usageData Additional data related to the usage event.
     */
    function recordModuleUsage(bytes32 moduleId, address user, string calldata usageType, bytes calldata usageData) external;

    /**
     * @dev Retrieves the total usage count for a specific module.
     * @param moduleId The unique ID of the module.
     * @return totalUses The total number of times the module has been used.
     */
    function getTotalModuleUses(bytes32 moduleId) external view returns (uint256 totalUses);

    /**
     * @dev Retrieves the number of unique users for a specific module.
     * @param moduleId The unique ID of the module.
     * @return uniqueUsers The count of unique users.
     */
    function getUniqueModuleUsers(bytes32 moduleId) external view returns (uint256 uniqueUsers);
}