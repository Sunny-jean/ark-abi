// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ModuleRatingSystem {
    /**
     * @dev Emitted when a module receives a new rating.
     * @param moduleId The ID of the module being rated.
     * @param user The address of the user who submitted the rating.
     * @param rating The rating value.
     */
    event ModuleRated(bytes32 indexed moduleId, address indexed user, uint256 rating);

    /**
     * @dev Emitted when a module's average rating is updated.
     * @param moduleId The ID of the module.
     * @param newAverageRating The new average rating.
     */
    event AverageRatingUpdated(bytes32 indexed moduleId, uint256 newAverageRating);

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
     * @dev Thrown when a rating is out of the allowed range.
     */
    error InvalidRating(uint256 rating);

    /**
     * @dev Allows a user to submit a rating for a specific module.
     * @param moduleId The unique ID of the module to rate.
     * @param rating The rating value (e.g., 1 to 5).
     */
    function submitRating(bytes32 moduleId, uint256 rating) external;

    /**
     * @dev Retrieves the average rating for a specific module.
     * @param moduleId The unique ID of the module.
     * @return averageRating The current average rating of the module.
     * @return totalRatings The total number of ratings received.
     */
    function getAverageRating(bytes32 moduleId) external view returns (uint256 averageRating, uint256 totalRatings);

    /**
     * @dev Allows an authorized entity to remove a specific rating.
     * @param moduleId The unique ID of the module.
     * @param user The address of the user whose rating is to be removed.
     */
    function removeRating(bytes32 moduleId, address user) external;
}