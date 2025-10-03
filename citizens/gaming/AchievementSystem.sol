// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface AchievementSystem {
    /**
     * @dev Emitted when a new achievement is defined.
     * @param achievementId The unique ID of the achievement.
     * @param name The name of the achievement.
     * @param description The description of the achievement.
     */
    event AchievementDefined(bytes32 indexed achievementId, string name, string description);

    /**
     * @dev Emitted when a player earns an achievement.
     * @param player The address of the player who earned the achievement.
     * @param achievementId The ID of the achievement earned.
     * @param timestamp The timestamp when the achievement was earned.
     */
    event AchievementEarned(address indexed player, bytes32 indexed achievementId, uint256 timestamp);

    /**
     * @dev Emitted when an achievement's status is updated (e.g., enabled/disabled).
     * @param achievementId The ID of the achievement.
     * @param enabled True if the achievement is enabled, false otherwise.
     */
    event AchievementStatusUpdated(bytes32 indexed achievementId, bool enabled);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when an achievement with the given ID is not found.
     */
    error AchievementNotFound(bytes32 achievementId);

    /**
     * @dev Thrown when a player has already earned a specific achievement.
     */
    error AchievementAlreadyEarned(address player, bytes32 achievementId);

    /**
     * @dev Thrown when an achievement is disabled and cannot be earned.
     */
    error AchievementDisabled(bytes32 achievementId);

    /**
     * @dev Defines a new achievement.
     * Only callable by authorized game administrators.
     * @param achievementId The unique ID for the achievement.
     * @param name The name of the achievement.
     * @param description The description of the achievement.
     */
    function defineAchievement(bytes32 achievementId, string calldata name, string calldata description) external;

    /**
     * @dev Awards an achievement to a player.
     * Only callable by authorized game contracts or administrators.
     * @param player The address of the player to award the achievement to.
     * @param achievementId The ID of the achievement to award.
     */
    function awardAchievement(address player, bytes32 achievementId) external;

    /**
     * @dev Updates the enabled status of an achievement.
     * Only callable by authorized game administrators.
     * @param achievementId The ID of the achievement to update.
     * @param enabled True to enable, false to disable.
     */
    function setAchievementStatus(bytes32 achievementId, bool enabled) external;

    /**
     * @dev Retrieves the details of a defined achievement.
     * @param achievementId The ID of the achievement to query.
     * @return name The name of the achievement.
     * @return description The description of the achievement.
     * @return enabled True if the achievement is enabled, false otherwise.
     */
    function getAchievementDetails(bytes32 achievementId) external view returns (string memory name, string memory description, bool enabled);

    /**
     * @dev Retrieves all achievements earned by a specific player.
     * @param player The address of the player to query.
     * @return earnedAchievements An array of achievement IDs earned by the player.
     */
    function getPlayerAchievements(address player) external view returns (bytes32[] memory earnedAchievements);
}