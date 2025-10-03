// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface UserFeedbackCollector {
    /**
     * @dev Emitted when new feedback is submitted.
     * @param feedbackId The unique ID of the feedback.
     * @param user The address of the user who submitted the feedback.
     * @param moduleId The ID of the module the feedback is for.
     */
    event FeedbackSubmitted(bytes32 indexed feedbackId, address indexed user, bytes32 indexed moduleId);

    /**
     * @dev Emitted when feedback status is updated (e.g., reviewed, resolved).
     * @param feedbackId The unique ID of the feedback.
     * @param newStatus The new status of the feedback.
     */
    event FeedbackStatusUpdated(bytes32 indexed feedbackId, string newStatus);

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
     * @dev Thrown when the specified feedback is not found.
     */
    error FeedbackNotFound(bytes32 feedbackId);

    /**
     * @dev Allows users to submit feedback for a specific module.
     * @param moduleId The unique ID of the module the feedback is about.
     * @param feedbackContent The content of the feedback.
     * @param feedbackType The type of feedback (e.g., "bug_report", "feature_request", "general_comment").
     * @return feedbackId The unique ID generated for the submitted feedback.
     */
    function submitFeedback(bytes32 moduleId, string calldata feedbackContent, string calldata feedbackType) external returns (bytes32 feedbackId);

    /**
     * @dev Allows authorized parties to update the status of submitted feedback.
     * @param feedbackId The unique ID of the feedback to update.
     * @param newStatus The new status (e.g., "reviewed", "in_progress", "resolved", "rejected").
     */
    function updateFeedbackStatus(bytes32 feedbackId, string calldata newStatus) external;

    /**
     * @dev Retrieves the details of a specific feedback entry.
     * @param feedbackId The unique ID of the feedback.
     * @return user The address of the user who submitted the feedback.
     * @return moduleId The ID of the module the feedback is for.
     * @return content The content of the feedback.
     * @return feedbackType The type of feedback.
     * @return status The current status of the feedback.
     */
    function getFeedbackDetails(bytes32 feedbackId) external view returns (address user, bytes32 moduleId, string memory content, string memory feedbackType, string memory status);
}