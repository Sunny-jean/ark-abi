// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface PlayerProgression {
    /**
     * @dev Emitted when a player's experience points (XP) are updated.
     * @param player The address of the player.
     * @param gameId The ID of the game.
     * @param newXP The player's new total XP for the game.
     * @param xpGained The amount of XP gained in this update.
     */
    event XPUpdated(address indexed player, bytes32 indexed gameId, uint256 newXP, uint256 xpGained);

    /**
     * @dev Emitted when a player levels up.
     * @param player The address of the player.
     * @param gameId The ID of the game.
     * @param newLevel The player's new level.
     */
    event LevelUp(address indexed player, bytes32 indexed gameId, uint256 newLevel);

    /**
     * @dev Emitted when a player unlocks a new skill or ability.
     * @param player The address of the player.
     * @param gameId The ID of the game.
     * @param skillId The ID of the skill unlocked.
     */
    event SkillUnlocked(address indexed player, bytes32 indexed gameId, bytes32 indexed skillId);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a game with the given ID is not found.
     */
    error GameNotFound(bytes32 gameId);

    /**
     * @dev Thrown when a skill with the given ID is not found or not defined.
     */
    error SkillNotFound(bytes32 skillId);

    /**
     * @dev Thrown when a player attempts to unlock an already unlocked skill.
     */
    error SkillAlreadyUnlocked(address player, bytes32 skillId);

    /**
     * @dev Adds experience points (XP) to a player for a specific game.
     * Only callable by authorized game contracts or administrators.
     * @param player The address of the player.
     * @param gameId The ID of the game.
     * @param amount The amount of XP to add.
     */
    function addXP(address player, bytes32 gameId, uint256 amount) external;

    /**
     * @dev Unlocks a specific skill for a player in a game.
     * Only callable by authorized game contracts or administrators.
     * @param player The address of the player.
     * @param gameId The ID of the game.
     * @param skillId The ID of the skill to unlock.
     */
    function unlockSkill(address player, bytes32 gameId, bytes32 skillId) external;

    /**
     * @dev Retrieves a player's current experience points (XP) for a specific game.
     * @param player The address of the player.
     * @param gameId The ID of the game.
     * @return xp The player's total XP.
     */
    function getPlayerXP(address player, bytes32 gameId) external view returns (uint256 xp);

    /**
     * @dev Retrieves a player's current level for a specific game.
     * @param player The address of the player.
     * @param gameId The ID of the game.
     * @return level The player's current level.
     */
    function getPlayerLevel(address player, bytes32 gameId) external view returns (uint256 level);

    /**
     * @dev Checks if a player has a specific skill unlocked for a game.
     * @param player The address of the player.
     * @param gameId The ID of the game.
     * @param skillId The ID of the skill to check.
     * @return True if the skill is unlocked, false otherwise.
     */
    function hasSkill(address player, bytes32 gameId, bytes32 skillId) external view returns (bool);

    /**
     * @dev Retrieves all skills unlocked by a player for a specific game.
     * @param player The address of the player.
     * @param gameId The ID of the game.
     * @return unlockedSkills An array of skill IDs unlocked by the player.
     */
    function getUnlockedSkills(address player, bytes32 gameId) external view returns (bytes32[] memory unlockedSkills);
}