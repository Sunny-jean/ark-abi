// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface Messaging {
    /**
     * @dev Emitted when a new message is sent.
     * @param messageId The unique ID of the message.
     * @param sender The address of the sender.
     * @param receiver The address of the receiver.
     * @param timestamp The timestamp when the message was sent.
     * @param contentHash The IPFS hash or content identifier of the message.
     */
    event MessageSent(bytes32 indexed messageId, address indexed sender, address indexed receiver, uint256 timestamp, string contentHash);

    /**
     * @dev Emitted when a message is marked as read.
     * @param messageId The unique ID of the message.
     * @param reader The address of the user who read the message.
     */
    event MessageRead(bytes32 indexed messageId, address indexed reader);

    /**
     * @dev Emitted when a message is deleted.
     * @param messageId The unique ID of the message.
     * @param deleter The address of the user who deleted the message.
     */
    event MessageDeleted(bytes32 indexed messageId, address indexed deleter);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a message with the given ID is not found.
     */
    error MessageNotFound(bytes32 messageId);

    /**
     * @dev Thrown when a message is sent to oneself.
     */
    error CannotMessageSelf();

    /**
     * @dev Thrown when the message content is empty.
     */
    error EmptyMessageContent();

    /**
     * @dev Sends a new message to a recipient.
     * The message content itself is expected to be stored off-chain (e.g., IPFS) and its hash provided.
     * @param receiver The address of the recipient.
     * @param contentHash The IPFS hash or content identifier of the message.
     * @return messageId The unique ID of the sent message.
     */
    function sendMessage(address receiver, string calldata contentHash) external returns (bytes32 messageId);

    /**
     * @dev Marks a message as read.
     * Only the receiver of the message can mark it as read.
     * @param messageId The ID of the message to mark as read.
     */
    function markMessageAsRead(bytes32 messageId) external;

    /**
     * @dev Deletes a message.
     * Only the sender or receiver can delete a message.
     * @param messageId The ID of the message to delete.
     */
    function deleteMessage(bytes32 messageId) external;

    /**
     * @dev Retrieves the details of a specific message.
     * @param messageId The ID of the message to query.
     * @return sender The address of the sender.
     * @return receiver The address of the receiver.
     * @return timestamp The timestamp when the message was sent.
     * @return contentHash The IPFS hash of the message content.
     * @return isRead True if the message has been read by the receiver, false otherwise.
     */
    function getMessageDetails(bytes32 messageId) external view returns (address sender, address receiver, uint256 timestamp, string memory contentHash, bool isRead);

    /**
     * @dev Retrieves all messages sent by a specific user.
     * @param sender The address of the sender.
     * @return messageIds An array of message IDs sent by the user.
     */
    function getSentMessages(address sender) external view returns (bytes32[] memory messageIds);

    /**
     * @dev Retrieves all messages received by a specific user.
     * @param receiver The address of the receiver.
     * @return messageIds An array of message IDs received by the user.
     */
    function getReceivedMessages(address receiver) external view returns (bytes32[] memory messageIds);
}