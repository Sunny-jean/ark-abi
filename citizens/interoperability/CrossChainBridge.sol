// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface CrossChainBridge {
    /**
     * @dev Emitted when tokens are locked on the source chain for a cross-chain transfer.
     * @param sender The address that initiated the transfer.
     * @param token The address of the token being transferred.
     * @param amount The amount of tokens.
     * @param destinationChainId The ID of the destination blockchain.
     * @param destinationAddress The address on the destination chain.
     */
    event TokensLocked(address indexed sender, address indexed token, uint256 amount, uint256 destinationChainId, bytes destinationAddress);

    /**
     * @dev Emitted when tokens are released on the destination chain after a successful transfer.
     * @param recipient The address that received the tokens on the destination chain.
     * @param token The address of the token.
     * @param amount The amount of tokens.
     * @param sourceChainId The ID of the source blockchain.
     */
    event TokensReleased(address indexed recipient, address indexed token, uint256 amount, uint256 sourceChainId);

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
     * @dev Thrown when the destination chain is not supported.
     */
    error UnsupportedChain(uint256 chainId);

    /**
     * @dev Thrown when there are insufficient tokens for the transfer.
     */
    error InsufficientTokens(uint256 requested, uint256 available);

    /**
     * @dev Initiates a cross-chain transfer by locking tokens on the current chain.
     * @param token The address of the ERC-20 token to transfer.
     * @param amount The amount of tokens to transfer.
     * @param destinationChainId The ID of the blockchain to transfer to.
     * @param destinationAddress The recipient's address on the destination chain.
     */
    function lockTokens(address token, uint256 amount, uint256 destinationChainId, bytes calldata destinationAddress) external;

    /**
     * @dev Releases tokens on the destination chain after verification of a lock event on the source chain.
     * This function is typically called by an authorized relayer or oracle.
     * @param token The address of the ERC-20 token to release.
     * @param amount The amount of tokens to release.
     * @param recipient The address to send the tokens to on the current chain.
     * @param sourceChainId The ID of the blockchain from which the tokens originated.
     * @param sourceTransactionHash The hash of the transaction on the source chain.
     */
    function releaseTokens(address token, uint256 amount, address recipient, uint256 sourceChainId, bytes32 sourceTransactionHash) external;

    /**
     * @dev Returns the current balance of a token held by the bridge on this chain.
     * @param token The address of the token.
     * @return balance The amount of the token held by the bridge.
     */
    function getBridgeBalance(address token) external view returns (uint256 balance);

    /**
     * @dev Checks if a cross-chain transfer has been processed.
     * @param sourceChainId The ID of the source chain.
     * @param sourceTransactionHash The hash of the transaction on the source chain.
     * @return isProcessed True if the transfer has been processed, false otherwise.
     */
    function isTransferProcessed(uint256 sourceChainId, bytes32 sourceTransactionHash) external view returns (bool isProcessed);
}