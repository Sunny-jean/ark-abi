// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface GameRegistry {
    /**
     * @dev Emitted when a new game is registered.
     * @param gameId The unique ID of the game.
     * @param gameAddress The address of the game contract.
     * @param gameName The name of the game.
     * @param developer The address of the game developer.
     */
    event GameRegistered(bytes32 indexed gameId, address indexed gameAddress, string gameName, address indexed developer);

    /**
     * @dev Emitted when a game's status is updated.
     * @param gameId The unique ID of the game.
     * @param newStatus The new status of the game (e.g., "active", "paused", "retired").
     */
    event GameStatusUpdated(bytes32 indexed gameId, string newStatus);

    /**
     * @dev Emitted when a game is deregistered.
     * @param gameId The unique ID of the game.
     */
    event GameDeregistered(bytes32 indexed gameId);

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
     * @dev Thrown when a game with the given ID is already registered.
     */
    error GameAlreadyRegistered(bytes32 gameId);

    /**
     * @dev Registers a new game with its contract address, name, and developer.
     * Only callable by authorized administrators or game publishers.
     * @param gameId The unique ID for the game.
     * @param gameAddress The address of the game contract.
     * @param gameName The name of the game.
     * @param developer The address of the game developer.
     */
    function registerGame(bytes32 gameId, address gameAddress, string calldata gameName, address developer) external;

    /**
     * @dev Updates the status of a registered game.
     * Only callable by the game developer or authorized administrators.
     * @param gameId The ID of the game to update.
     * @param newStatus The new status of the game (e.g., "active", "paused", "retired").
     */
    function updateGameStatus(bytes32 gameId, string calldata newStatus) external;

    /**
     * @dev Deregisters a game.
     * Only callable by authorized administrators.
     * @param gameId The ID of the game to deregister.
     */
    function deregisterGame(bytes32 gameId) external;

    /**
     * @dev Retrieves the details of a registered game.
     * @param gameId The ID of the game to query.
     * @return gameAddress The address of the game contract.
     * @return gameName The name of the game.
     * @return developer The address of the game developer.
     * @return status The current status of the game.
     */
    function getGameDetails(bytes32 gameId) external view returns (address gameAddress, string memory gameName, address developer, string memory status);

    /**
     * @dev Retrieves all games registered by a specific developer.
     * @param developer The address of the developer.
     * @return gameIds An array of game IDs registered by the developer.
     */
    function getGamesByDeveloper(address developer) external view returns (bytes32[] memory gameIds);
}