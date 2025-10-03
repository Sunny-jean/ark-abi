// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface RatingAggregator {
    /**
     * @dev Emitted when a new rating source is registered.
     * @param sourceId The unique ID of the rating source.
     * @param sourceAddress The address of the rating source contract.
     */
    event RatingSourceRegistered(bytes32 indexed sourceId, address indexed sourceAddress);

    /**
     * @dev Emitted when aggregated ratings for a module are updated.
     * @param moduleId The ID of the module.
     * @param newAggregatedRating The new aggregated rating.
     */
    event AggregatedRatingUpdated(bytes32 indexed moduleId, uint256 newAggregatedRating);

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
     * @dev Thrown when a rating source is not found.
     */
    error RatingSourceNotFound(bytes32 sourceId);

    /**
     * @dev Registers a new external or internal rating source.
     * @param sourceId A unique identifier for the rating source.
     * @param sourceAddress The address of the contract or entity providing ratings.
     * @param weight The weight of this source's ratings in the aggregation.
     */
    function registerRatingSource(bytes32 sourceId, address sourceAddress, uint256 weight) external;

    /**
     * @dev Aggregates ratings from various sources for a given module.
     * This function might be called by an off-chain process or a privileged account.
     * @param moduleId The unique ID of the module for which to aggregate ratings.
     */
    function aggregateModuleRatings(bytes32 moduleId) external;

    /**
     * @dev Retrieves the current aggregated rating for a module.
     * @param moduleId The unique ID of the module.
     * @return aggregatedRating The combined, weighted average rating.
     */
    function getAggregatedRating(bytes32 moduleId) external view returns (uint256 aggregatedRating);
}