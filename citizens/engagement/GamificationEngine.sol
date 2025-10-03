// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface GamificationEngine {
    /**
     * @dev Emitted when a user achieves a new level or milestone.
     * @param user The address of the user.
     * @param level The new level achieved.
     * @param milestone The name of the milestone achieved.
     */
    event LevelUp(address indexed user, uint256 level, string indexed milestone);

    /**
     * @dev Emitted when a user earns a badge or achievement.
     * @param user The address of the user.
     * @param badgeId The unique ID of the badge.
     * @param achievementName The name of the achievement.
     */
    event BadgeEarned(address indexed user, bytes32 indexed badgeId, string indexed achievementName);

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
     * @dev Thrown when the specified user is not found.
     */
    error UserNotFound(address user);

    /**
     * @dev Thrown when a gamification rule is not found.
     */
    error RuleNotFound(bytes32 ruleId);

    /**
     * @dev Processes a user's action and updates their gamification status (e.g., points, levels, badges).
     * @param user The address of the user performing the action.
     * @param actionType The type of action (e.g., "module_completion", "daily_login").
     * @param actionData Additional data related to the action.
     */
    function processUserAction(address user, string calldata actionType, bytes calldata actionData) external;

    /**
     * @dev Retrieves a user's current gamification profile.
     * @param user The address of the user.
     * @return level The current level of the user.
     * @return points The total points accumulated by the user.
     * @return badges An array of badge IDs earned by the user.
     */
    function getUserGamificationProfile(address user) external view returns (uint256 level, uint256 points, bytes32[] memory badges);

    /**
     * @dev Updates a gamification rule or adds a new one.
     * @param ruleId The unique ID of the rule.
     * @param ruleDefinition The definition of the gamification rule.
     */
    function updateGamificationRule(bytes32 ruleId, bytes calldata ruleDefinition) external;
}