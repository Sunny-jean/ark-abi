// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface DecentralizedStorageConnector {
    /**
     * @dev Emitted when content is pinned to decentralized storage.
     * @param contentId The unique ID of the content.
     * @param storageProvider The identifier of the storage provider (e.g., IPFS CID).
     * @param owner The address that initiated the pinning.
     */
    event ContentPinned(bytes32 indexed contentId, string indexed storageProvider, address indexed owner);

    /**
     * @dev Emitted when content is unpinned from decentralized storage.
     * @param contentId The unique ID of the content.
     * @param storageProvider The identifier of the storage provider.
     */
    event ContentUnpinned(bytes32 indexed contentId, string indexed storageProvider);

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
     * @dev Thrown when content is not found on the specified storage provider.
     */
    error ContentNotFound(bytes32 contentId, string storageProvider);

    /**
     * @dev Thrown when an attempt to pin content fails.
     */
    error PinningFailed(bytes32 contentId, string storageProvider, string reason);

    /**
     * @dev Pins content to a decentralized storage network (e.g., IPFS, Arweave).
     * @param contentId The unique ID of the content to pin.
     * @param storageProviderIdentifier A string identifying the content on the decentralized storage (e.g., IPFS CID).
     */
    function pinContent(bytes32 contentId, string calldata storageProviderIdentifier) external;

    /**
     * @dev Unpins content from a decentralized storage network.
     * @param contentId The unique ID of the content to unpin.
     * @param storageProviderIdentifier A string identifying the content on the decentralized storage.
     */
    function unpinContent(bytes32 contentId, string calldata storageProviderIdentifier) external;

    /**
     * @dev Retrieves the storage provider identifier for a given content ID.
     * @param contentId The unique ID of the content.
     * @return storageProviderIdentifier The identifier of the content on the decentralized storage.
     */
    function getContentLocation(bytes32 contentId) external view returns (string memory storageProviderIdentifier);

    /**
     * @dev Checks if content is currently pinned on a decentralized storage network.
     * @param contentId The unique ID of the content.
     * @param storageProviderIdentifier A string identifying the content on the decentralized storage.
     * @return isPinned True if the content is pinned, false otherwise.
     */
    function isContentPinned(bytes32 contentId, string calldata storageProviderIdentifier) external view returns (bool isPinned);
}