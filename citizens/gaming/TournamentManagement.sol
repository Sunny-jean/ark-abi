// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface TournamentManagement {
    /**
     * @dev Emitted when a new tournament is created.
     * @param tournamentId The unique ID of the tournament.
     * @param name The name of the tournament.
     * @param startTime The start time of the tournament.
     * @param endTime The end time of the tournament.
     * @param entryFee The entry fee for the tournament.
     * @param rewardPool The total reward pool for the tournament.
     */
    event TournamentCreated(bytes32 indexed tournamentId, string name, uint256 startTime, uint256 endTime, uint256 entryFee, uint256 rewardPool);

    /**
     * @dev Emitted when a player registers for a tournament.
     * @param tournamentId The ID of the tournament.
     * @param player The address of the player who registered.
     */
    event PlayerRegistered(bytes32 indexed tournamentId, address indexed player);

    /**
     * @dev Emitted when tournament results are recorded.
     * @param tournamentId The ID of the tournament.
     * @param winner The address of the winner.
     * @param score The winning score.
     */
    event TournamentResultsRecorded(bytes32 indexed tournamentId, address indexed winner, uint256 score);

    /**
     * @dev Emitted when rewards are distributed for a tournament.
     * @param tournamentId The ID of the tournament.
     * @param player The address of the player receiving rewards.
     * @param amount The amount of rewards distributed.
     */
    event RewardsDistributed(bytes32 indexed tournamentId, address indexed player, uint256 amount);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a tournament with the given ID is not found.
     */
    error TournamentNotFound(bytes32 tournamentId);

    /**
     * @dev Thrown when a player attempts to register for a tournament that is not open for registration.
     */
    error RegistrationClosed(bytes32 tournamentId);

    /**
     * @dev Thrown when a player attempts to register for a tournament they are already registered for.
     */
    error AlreadyRegistered(bytes32 tournamentId, address player);

    /**
     * @dev Thrown when the entry fee is not met.
     */
    error InsufficientEntryFee(uint256 required, uint256 provided);

    /**
     * @dev Thrown when tournament results are attempted to be recorded before the tournament ends.
     */
    error TournamentNotEnded(bytes32 tournamentId);

    /**
     * @dev Thrown when rewards are attempted to be distributed before results are recorded.
     */
    error ResultsNotRecorded(bytes32 tournamentId);

    /**
     * @dev Creates a new tournament.
     * Only callable by authorized administrators.
     * @param tournamentId The unique ID for the tournament.
     * @param name The name of the tournament.
     * @param startTime The start timestamp of the tournament.
     * @param endTime The end timestamp of the tournament.
     * @param entryFee The entry fee required to participate.
     * @param rewardPool The total reward pool for the tournament.
     */
    function createTournament(bytes32 tournamentId, string calldata name, uint256 startTime, uint256 endTime, uint256 entryFee, uint256 rewardPool) external;

    /**
     * @dev Allows a player to register for a tournament.
     * @param tournamentId The ID of the tournament to register for.
     */
    function registerForTournament(bytes32 tournamentId) external payable;

    /**
     * @dev Records the results of a tournament.
     * Only callable by authorized game contracts or administrators after the tournament ends.
     * @param tournamentId The ID of the tournament.
     * @param winner The address of the winning player.
     * @param score The winning score.
     */
    function recordTournamentResults(bytes32 tournamentId, address winner, uint256 score) external;

    /**
     * @dev Distributes rewards to participants based on recorded results.
     * Only callable by authorized administrators after results are recorded.
     * @param tournamentId The ID of the tournament.
     */
    function distributeRewards(bytes32 tournamentId) external;

    /**
     * @dev Retrieves the details of a tournament.
     * @param tournamentId The ID of the tournament to query.
     * @return name The name of the tournament.
     * @return startTime The start time of the tournament.
     * @return endTime The end time of the tournament.
     * @return entryFee The entry fee.
     * @return rewardPool The total reward pool.
     * @return winner The address of the winner (if results recorded).
     * @return winningScore The winning score (if results recorded).
     */
    function getTournamentDetails(bytes32 tournamentId) external view returns (string memory name, uint256 startTime, uint256 endTime, uint256 entryFee, uint256 rewardPool, address winner, uint256 winningScore);

    /**
     * @dev Checks if a player is registered for a specific tournament.
     * @param tournamentId The ID of the tournament.
     * @param player The address of the player.
     * @return True if the player is registered, false otherwise.
     */
    function isPlayerRegistered(bytes32 tournamentId, address player) external view returns (bool);
}