// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface MessagingSystem {
    /**
     * @dev Emitted when a new message is sent.
     * @param messageId The unique ID of the message.
     * @param sender The address of the sender.
     * @param recipient The address of the recipient.
     * @param timestamp The timestamp when the message was sent.
     */
    event MessageSent(bytes32 indexed messageId, address indexed sender, address indexed recipient, uint256 timestamp);

    /**
     * @dev Emitted when a message is read by the recipient.
     * @param messageId The unique ID of the message.
     * @param reader The address of the reader.
     * @param timestamp The timestamp when the message was read.
     */
    event MessageRead(bytes32 indexed messageId, address indexed reader, uint256 timestamp);

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
     * @dev Thrown when a message with the given ID is not found.
     */
    error MessageNotFound(bytes32 messageId);

    /**
     * @dev Thrown when attempting to send a message to a zero address.
     */
    error InvalidRecipient();

    /**
     * @dev Sends a new message.
     * @param recipient The address of the recipient.
     * @param content The content of the message.
     * @return messageId The unique ID of the sent message.
     */
    function sendMessage(address recipient, string calldata content) external returns (bytes32 messageId);

    /**
     * @dev Marks a message as read.
     * @param messageId The unique ID of the message to mark as read.
     */
    function markAsRead(bytes32 messageId) external;

    /**
     * @dev Retrieves the content of a message.
     * @param messageId The unique ID of the message.
     * @return sender The address of the sender.
     * @return recipient The address of the recipient.
     * @return content The content of the message.
     * @return timestamp The timestamp when the message was sent.
     * @return isRead True if the message has been read, false otherwise.
     */
    function getMessage(bytes32 messageId) external view returns (address sender, address recipient, string memory content, uint256 timestamp, bool isRead);

    /**
     * @dev Retrieves a list of message IDs for a given user.
     * @param user The address of the user.
     * @return messageIds An array of message IDs.
     */
    function getInbox(address user) external view returns (bytes32[] memory messageIds);
}