// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface Bridge {
    /**
     * @dev Emitted when assets are locked on the source chain for a cross-chain transfer.
     * @param sender The address that initiated the transfer.
     * @param recipient The address on the destination chain.
     * @param asset The address of the asset being transferred.
     * @param amount The amount of the asset.
     * @param destinationChainId The ID of the destination chain.
     * @param transferId The unique ID for this cross-chain transfer.
     */
    event AssetsLocked(address indexed sender, bytes32 indexed recipient, address indexed asset, uint256 amount, uint256 destinationChainId, bytes32 transferId);

    /**
     * @dev Emitted when assets are minted on the destination chain after a successful cross-chain transfer.
     * @param recipient The address on the destination chain.
     * @param asset The address of the asset minted.
     * @param amount The amount of the asset.
     * @param sourceChainId The ID of the source chain.
     * @param transferId The unique ID for this cross-chain transfer.
     */
    event AssetsMinted(bytes32 indexed recipient, address indexed asset, uint256 amount, uint256 sourceChainId, bytes32 transferId);

    /**
     * @dev Emitted when a cross-chain transfer is successfully relayed and processed.
     * @param transferId The unique ID for the cross-chain transfer.
     * @param status The status of the relay (e.g., "success", "failed").
     */
    event TransferRelayed(bytes32 indexed transferId, string status);

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
     * @dev Thrown when a transfer with the given ID is not found.
     */
    error TransferNotFound(bytes32 transferId);

    /**
     * @dev Thrown when attempting to process a transfer that is already completed or invalid.
     */
    error InvalidTransferState(bytes32 transferId);

    /**
     * @dev Initiates a cross-chain transfer by locking assets on the source chain.
     * @param recipient The address on the destination chain to receive the assets.
     * @param asset The address of the ERC-20 token or native asset to transfer.
     * @param amount The amount of the asset to transfer.
     * @param destinationChainId The ID of the destination blockchain.
     * @param message An optional message or data payload for the destination chain.
     * @return transferId The unique ID generated for this cross-chain transfer.
     */
    function initiateTransfer(bytes32 recipient, address asset, uint256 amount, uint256 destinationChainId, bytes calldata message) external returns (bytes32 transferId);

    /**
     * @dev Relays and processes a cross-chain transfer on the destination chain.
     * Only callable by authorized relayers or validators.
     * @param transferId The unique ID of the transfer.
     * @param sourceChainId The ID of the source blockchain.
     * @param sender The original sender's address on the source chain.
     * @param recipient The recipient's address on the destination chain.
     * @param asset The address of the asset to mint/release.
     * @param amount The amount of the asset.
     * @param message The original message or data payload.
     */
    function relayTransfer(bytes32 transferId, uint256 sourceChainId, address sender, bytes32 recipient, address asset, uint256 amount, bytes calldata message) external;

    /**
     * @dev Retrieves the status of a cross-chain transfer.
     * @param transferId The ID of the transfer.
     * @return status The current status of the transfer (e.g., "pending", "completed", "failed").
     * @return sourceChainId The ID of the source chain.
     * @return destinationChainId The ID of the destination chain.
     * @return sender The sender's address.
     * @return recipient The recipient's address.
     * @return asset The asset being transferred.
     * @return amount The amount being transferred.
     */
    function getTransferStatus(bytes32 transferId) external view returns (string memory status, uint256 sourceChainId, uint256 destinationChainId, address sender, bytes32 recipient, address asset, uint256 amount);
}