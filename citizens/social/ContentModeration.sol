// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ContentModeration {
    /**
     * @dev Emitted when content is reported.
     * @param contentId The unique ID of the reported content.
     * @param reporter The address of the reporter.
     * @param reason The reason for the report.
     * @param timestamp The timestamp of the report.
     */
    event ContentReported(bytes32 indexed contentId, address indexed reporter, string reason, uint256 timestamp);

    /**
     * @dev Emitted when content is moderated (e.g., approved, rejected, hidden).
     * @param contentId The unique ID of the moderated content.
     * @param moderator The address of the moderator.
     * @param status The new moderation status.
     * @param reason The reason for the moderation decision.
     */
    event ContentModerated(bytes32 indexed contentId, address indexed moderator, string status, string reason);

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
     * @dev Thrown when content with the given ID is not found.
     */
    error ContentNotFound(bytes32 contentId);

    /**
     * @dev Thrown when attempting to report content that has already been reported.
     */
    error ContentAlreadyReported(bytes32 contentId);

    /**
     * @dev Reports a piece of content for moderation.
     * @param contentId The unique ID of the content to report.
     * @param reason The reason for reporting the content.
     */
    function reportContent(bytes32 contentId, string calldata reason) external;

    /**
     * @dev Sets the moderation status of a piece of content.
     * @param contentId The unique ID of the content to moderate.
     * @param status The new moderation status (e.g., "approved", "rejected", "hidden").
     * @param reason The reason for the moderation decision.
     */
    function moderateContent(bytes32 contentId, string calldata status, string calldata reason) external;

    /**
     * @dev Retrieves the moderation status of a piece of content.
     * @param contentId The unique ID of the content.
     * @return status The current moderation status.
     * @return lastModerator The address of the last moderator.
     * @return lastModerationReason The reason for the last moderation decision.
     */
    function getContentStatus(bytes32 contentId) external view returns (string memory status, address lastModerator, string memory lastModerationReason);

    /**
     * @dev Retrieves all reported content that is pending moderation.
     * @return reportedContentIds An array of content IDs that are pending moderation.
     */
    function getPendingModeration() external view returns (bytes32[] memory reportedContentIds);
}