// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ModuleReviewManager {
    /**
     * @dev Emitted when a new review is submitted for a module.
     * @param reviewId The unique ID of the review.
     * @param moduleId The ID of the module reviewed.
     * @param reviewer The address of the reviewer.
     */
    event ReviewSubmitted(bytes32 indexed reviewId, bytes32 indexed moduleId, address indexed reviewer);

    /**
     * @dev Emitted when a review's status is updated (e.g., approved, flagged).
     * @param reviewId The unique ID of the review.
     * @param newStatus The new status of the review.
     */
    event ReviewStatusUpdated(bytes32 indexed reviewId, string newStatus);

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
     * @dev Thrown when a review is not found.
     */
    error ReviewNotFound(bytes32 reviewId);

    /**
     * @dev Allows users to submit a text-based review for a specific module.
     * @param moduleId The unique ID of the module being reviewed.
     * @param reviewContent The text content of the review.
     * @param rating An optional numerical rating associated with the review.
     * @return reviewId The unique ID generated for the submitted review.
     */
    function submitReview(bytes32 moduleId, string calldata reviewContent, uint256 rating) external returns (bytes32 reviewId);

    /**
     * @dev Allows authorized parties to moderate or update the status of a review.
     * @param reviewId The unique ID of the review to update.
     * @param newStatus The new status (e.g., "approved", "flagged", "removed").
     */
    function updateReviewStatus(bytes32 reviewId, string calldata newStatus) external;

    /**
     * @dev Retrieves the details of a specific review.
     * @param reviewId The unique ID of the review.
     * @return moduleId The ID of the module reviewed.
     * @return reviewer The address of the reviewer.
     * @return content The text content of the review.
     * @return rating The numerical rating (0 if not provided).
     * @return status The current status of the review.
     */
    function getReviewDetails(bytes32 reviewId) external view returns (bytes32 moduleId, address reviewer, string memory content, uint256 rating, string memory status);

    /**
     * @dev Retrieves all review IDs for a given module.
     * @param moduleId The unique ID of the module.
     * @return reviewIds An array of unique review IDs.
     */
    function getModuleReviewIds(bytes32 moduleId) external view returns (bytes32[] memory reviewIds);
}