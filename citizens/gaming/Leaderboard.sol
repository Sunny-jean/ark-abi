// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface Leaderboard {
    /**
     * @dev Emitted when a player's score is updated.
     * @param gameId The ID of the game the score belongs to.
     * @param player The address of the player whose score was updated.
     * @param newScore The new score of the player.
     */
    event ScoreUpdated(bytes32 indexed gameId, address indexed player, uint256 newScore);

    /**
     * @dev Emitted when a new leaderboard is created or configured.
     * @param gameId The ID of the game for which the leaderboard is created.
     * @param name The name of the leaderboard.
     * @param sortOrder True for ascending, false for descending.
     */
    event LeaderboardConfigured(bytes32 indexed gameId, string name, bool sortOrder);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a game or leaderboard with the given ID is not found.
     */
    error LeaderboardNotFound(bytes32 gameId);

    /**
     * @dev Thrown when an invalid score is provided (e.g., negative score if not allowed).
     */
    error InvalidScore(uint256 score);

    /**
     * @dev Updates a player's score for a specific game on the leaderboard.
     * Only callable by authorized game contracts or administrators.
     * @param gameId The ID of the game.
     * @param player The address of the player.
     * @param score The new score for the player.
     */
    function updateScore(bytes32 gameId, address player, uint256 score) external;

    /**
     * @dev Retrieves a player's score for a specific game.
     * @param gameId The ID of the game.
     * @param player The address of the player.
     * @return score The player's score.
     */
    function getPlayerScore(bytes32 gameId, address player) external view returns (uint256 score);

    /**
     * @dev Retrieves the top N players and their scores for a specific game.
     * @param gameId The ID of the game.
     * @param count The number of top players to retrieve.
     * @return players An array of player addresses.
     * @return scores An array of corresponding scores.
     */
    function getTopPlayers(bytes32 gameId, uint256 count) external view returns (address[] memory players, uint256[] memory scores);

    /**
     * @dev Configures a new leaderboard for a game, specifying its name and sort order.
     * @param gameId The ID of the game.
     * @param name The name of the leaderboard.
     * @param sortOrder True for ascending order (lowest score first), false for descending (highest score first).
     */
    function configureLeaderboard(bytes32 gameId, string calldata name, bool sortOrder) external;
}