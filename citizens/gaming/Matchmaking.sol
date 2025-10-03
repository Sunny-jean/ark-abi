// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface Matchmaking {
    /**
     * @dev Emitted when a player requests to join a match queue.
     * @param player The address of the player.
     * @param gameId The ID of the game they want to play.
     * @param skillRating The player's skill rating.
     */
    event MatchmakingRequested(address indexed player, bytes32 indexed gameId, uint256 skillRating);

    /**
     * @dev Emitted when a match is successfully found and created.
     * @param matchId The unique ID of the created match.
     * @param gameId The ID of the game.
     * @param players An array of player addresses in the match.
     */
    event MatchFound(bytes32 indexed matchId, bytes32 indexed gameId, address[] players);

    /**
     * @dev Emitted when a player cancels their matchmaking request.
     * @param player The address of the player.
     * @param gameId The ID of the game.
     */
    event MatchmakingCanceled(address indexed player, bytes32 indexed gameId);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a game with the given ID is not configured for matchmaking.
     */
    error GameNotConfiguredForMatchmaking(bytes32 gameId);

    /**
     * @dev Thrown when a player is already in a matchmaking queue.
     */
    error AlreadyInQueue(address player, bytes32 gameId);

    /**
     * @dev Thrown when a player attempts to cancel a request they haven't made.
     */
    error NotInQueue(address player, bytes32 gameId);

    /**
     * @dev Requests to join the matchmaking queue for a specific game.
     * @param gameId The ID of the game the player wants to play.
     * @param skillRating The player's current skill rating, used for matching.
     */
    function requestMatch(bytes32 gameId, uint256 skillRating) external;

    /**
     * @dev Cancels a player's pending matchmaking request.
     * @param gameId The ID of the game for which the request was made.
     */
    function cancelMatchRequest(bytes32 gameId) external;

    /**
     * @dev Called by an authorized entity (e.g., off-chain matcher) to report a found match.
     * This function would typically be restricted to a trusted relayer.
     * @param matchId The unique ID for the new match.
     * @param gameId The ID of the game.
     * @param players An array of player addresses participating in the match.
     */
    function reportMatchFound(bytes32 matchId, bytes32 gameId, address[] calldata players) external;

    /**
     * @dev Retrieves the current status of a player's matchmaking request.
     * @param player The address of the player.
     * @param gameId The ID of the game.
     * @return inQueue True if the player is in the queue, false otherwise.
     * @return skillRating The player's skill rating if in queue.
     */
    function getMatchmakingStatus(address player, bytes32 gameId) external view returns (bool inQueue, uint256 skillRating);

    /**
     * @dev Retrieves the details of a found match.
     * @param matchId The ID of the match.
     * @return gameId The ID of the game.
     * @return players An array of player addresses in the match.
     */
    function getMatchDetails(bytes32 matchId) external view returns (bytes32 gameId, address[] memory players);
}