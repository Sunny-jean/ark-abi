// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface GameLogic {
    /**
     * @dev Emitted when a new game session starts.
     * @param sessionId The unique ID of the game session.
     * @param players The addresses of the players in the session.
     */
    event GameStarted(uint256 indexed sessionId, address[] players);

    /**
     * @dev Emitted when a player makes a move in the game.
     * @param sessionId The unique ID of the game session.
     * @param player The address of the player who made the move.
     * @param moveData The data representing the move.
     */
    event PlayerMoved(uint256 indexed sessionId, address indexed player, bytes moveData);

    /**
     * @dev Emitted when a game session ends.
     * @param sessionId The unique ID of the game session.
     * @param winner The address of the winner (if any).
     * @param gameResultData The data representing the game result.
     */
    event GameEnded(uint256 indexed sessionId, address indexed winner, bytes gameResultData);

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
     * @dev Thrown when a game session with the given ID does not exist.
     */
    error GameSessionNotFound(uint256 sessionId);

    /**
     * @dev Thrown when an invalid move is attempted.
     */
    error InvalidMove(string reason);

    /**
     * @dev Starts a new game session.
     * @param players The addresses of the players participating in the game.
     * @param initialGameState The initial state of the game.
     * @return sessionId The unique ID of the new game session.
     */
    function startGame(address[] calldata players, bytes calldata initialGameState) external returns (uint256 sessionId);

    /**
     * @dev Records a player's move in a game session.
     * @param sessionId The unique ID of the game session.
     * @param moveData The data representing the player's move.
     */
    function makeMove(uint256 sessionId, bytes calldata moveData) external;

    /**
     * @dev Ends a game session and records the result.
     * @param sessionId The unique ID of the game session.
     * @param winner The address of the winner (address(0) if draw or no winner).
     * @param gameResultData The data representing the final game result.
     */
    function endGame(uint256 sessionId, address winner, bytes calldata gameResultData) external;

    /**
     * @dev Returns the current state of a game session.
     * @param sessionId The unique ID of the game session.
     * @return currentGameState The current state of the game.
     */
    function getGameState(uint256 sessionId) external view returns (bytes memory currentGameState);

    /**
     * @dev Returns the players participating in a game session.
     * @param sessionId The unique ID of the game session.
     * @return players The addresses of the players.
     */
    function getGamePlayers(uint256 sessionId) external view returns (address[] memory players);
}