// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface CrossChainMessaging {
    /**
     * @dev Emitted when a message is sent from this chain to another chain.
     * @param messageId The unique ID of the message.
     * @param sender The address that sent the message.
     * @param destinationChainId The ID of the destination chain.
     * @param recipient The address on the destination chain.
     * @param payloadHash A hash of the message payload.
     */
    event MessageSent(bytes32 indexed messageId, address indexed sender, uint256 indexed destinationChainId, bytes32 recipient, bytes32 payloadHash);

    /**
     * @dev Emitted when a message is received and processed on this chain.
     * @param messageId The unique ID of the message.
     * @param sourceChainId The ID of the source chain.
     * @param sender The address on the source chain.
     * @param recipient The address on this chain.
     * @param payloadHash A hash of the message payload.
     */
    event MessageReceived(bytes32 indexed messageId, uint256 indexed sourceChainId, bytes32 indexed sender, address recipient, bytes32 payloadHash);

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
     * @dev Sends a message to a contract or address on another blockchain.
     * @param destinationChainId The ID of the target blockchain.
     * @param recipient The address on the destination chain to receive the message.
     * @param payload The message content.
     * @return messageId The unique ID generated for this cross-chain message.
     */
    function sendMessage(uint256 destinationChainId, bytes32 recipient, bytes calldata payload) external returns (bytes32 messageId);

    /**
     * @dev Receives and processes a message from another blockchain.
     * Only callable by authorized relayers or message validators.
     * @param messageId The unique ID of the message.
     * @param sourceChainId The ID of the source blockchain.
     * @param sender The original sender's address on the source chain.
     * @param recipient The recipient's address on this chain.
     * @param payload The message content.
     */
    function receiveMessage(bytes32 messageId, uint256 sourceChainId, bytes32 sender, address recipient, bytes calldata payload) external;

    /**
     * @dev Retrieves the status of a sent cross-chain message.
     * @param messageId The ID of the message.
     * @return status The current status of the message (e.g., "sent", "delivered", "failed").
     * @return destinationChainId The ID of the destination chain.
     * @return recipient The recipient's address on the destination chain.
     * @return payloadHash The hash of the message payload.
     */
    function getMessageStatus(bytes32 messageId) external view returns (string memory status, uint256 destinationChainId, bytes32 recipient, bytes32 payloadHash);
}