// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface UserProgressTracker {
    /**
     * @dev Emitted when a user's progress on a module or course is updated.
     * @param user The address of the user.
     * @param contentId The ID of the content (module/course).
     * @param progressPercentage The new progress percentage.
     */
    event ProgressUpdated(address indexed user, bytes32 indexed contentId, uint256 progressPercentage);

    /**
     * @dev Emitted when a user completes a module or course.
     * @param user The address of the user.
     * @param contentId The ID of the completed content.
     */
    event ContentCompleted(address indexed user, bytes32 indexed contentId);

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
     * @dev Thrown when the specified content is not found.
     */
    error ContentNotFound(bytes32 contentId);

    /**
     * @dev Records or updates a user's progress for a specific module or course.
     * @param user The address of the user.
     * @param contentId The unique ID of the module or course.
     * @param progressPercentage The percentage of completion (0-100).
     */
    function updateProgress(address user, bytes32 contentId, uint256 progressPercentage) external;

    /**
     * @dev Marks a module or course as completed for a user.
     * @param user The address of the user.
     * @param contentId The unique ID of the module or course completed.
     */
    function markAsCompleted(address user, bytes32 contentId) external;

    /**
     * @dev Retrieves a user's current progress for a specific module or course.
     * @param user The address of the user.
     * @param contentId The unique ID of the module or course.
     * @return progressPercentage The current progress percentage.
     * @return isCompleted True if the content is marked as completed, false otherwise.
     */
    function getProgress(address user, bytes32 contentId) external view returns (uint256 progressPercentage, bool isCompleted);
}