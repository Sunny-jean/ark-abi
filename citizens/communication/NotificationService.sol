// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface NotificationService {
    /**
     * @dev Emitted when a new notification is sent.
     * @param notificationId The unique ID of the notification.
     * @param recipient The address of the recipient.
     * @param notificationType The type of notification (e.g., "alert", "update").
     * @param timestamp The timestamp when the notification was sent.
     */
    event NotificationSent(bytes32 indexed notificationId, address indexed recipient, string indexed notificationType, uint256 timestamp);

    /**
     * @dev Emitted when a notification is marked as read.
     * @param notificationId The unique ID of the notification.
     * @param reader The address that marked the notification as read.
     */
    event NotificationRead(bytes32 indexed notificationId, address indexed reader);

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
     * @dev Thrown when a notification with the given ID is not found.
     */
    error NotificationNotFound(bytes32 notificationId);

    /**
     * @dev Sends a new notification to a recipient.
     * @param recipient The address of the recipient.
     * @param notificationType The type of notification.
     * @param message The content of the notification message.
     * @return notificationId The unique ID of the sent notification.
     */
    function sendNotification(address recipient, string calldata notificationType, string calldata message) external returns (bytes32 notificationId);

    /**
     * @dev Marks a notification as read.
     * @param notificationId The unique ID of the notification to mark as read.
     */
    function markNotificationAsRead(bytes32 notificationId) external;

    /**
     * @dev Retrieves the details of a specific notification.
     * @param notificationId The unique ID of the notification.
     * @return recipient The address of the recipient.
     * @return notificationType The type of notification.
     * @return message The content of the notification message.
     * @return timestamp The timestamp when the notification was sent.
     * @return isRead True if the notification has been read, false otherwise.
     */
    function getNotificationDetails(bytes32 notificationId) external view returns (address recipient, string memory notificationType, string memory message, uint256 timestamp, bool isRead);

    /**
     * @dev Retrieves all unread notifications for a given recipient.
     * @param recipient The address of the recipient.
     * @return unreadNotificationIds An array of unread notification IDs.
     */
    function getUnreadNotifications(address recipient) external view returns (bytes32[] memory unreadNotificationIds);
}