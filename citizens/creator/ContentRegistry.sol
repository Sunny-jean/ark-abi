// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ContentRegistry {
    /**
     * @dev Emitted when new content is registered.
     * @param contentId The unique ID of the content.
     * @param creator The address of the content creator.
     * @param contentHash The hash of the content data.
     * @param contentType The type of content (e.g., "image", "video", "text").
     */
    event ContentRegistered(bytes32 indexed contentId, address indexed creator, bytes32 contentHash, string indexed contentType);

    /**
     * @dev Emitted when content ownership is transferred.
     * @param contentId The unique ID of the content.
     * @param oldOwner The previous owner.
     * @param newOwner The new owner.
     */
    event ContentOwnershipTransferred(bytes32 indexed contentId, address indexed oldOwner, address indexed newOwner);

    /**
     * @dev Emitted when content is removed from the registry.
     * @param contentId The unique ID of the content.
     */
    event ContentRemoved(bytes32 indexed contentId);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when content with the given ID is not found.
     */
    error ContentNotFound(bytes32 contentId);

    /**
     * @dev Thrown when content with the given ID is already registered.
     */
    error ContentAlreadyRegistered(bytes32 contentId);

    /**
     * @dev Registers new digital content.
     * @param contentId The unique ID for the content.
     * @param contentHash The hash of the content data (e.g., IPFS CID).
     * @param contentType The type of content (e.g., "image", "video", "text", "audio").
     */
    function registerContent(bytes32 contentId, bytes32 contentHash, string calldata contentType) external;

    /**
     * @dev Transfers ownership of registered content.
     * Only callable by the current owner of the content.
     * @param contentId The ID of the content.
     * @param newOwner The address of the new owner.
     */
    function transferContentOwnership(bytes32 contentId, address newOwner) external;

    /**
     * @dev Removes content from the registry.
     * Only callable by the content owner or an authorized administrator.
     * @param contentId The ID of the content to remove.
     */
    function removeContent(bytes32 contentId) external;

    /**
     * @dev Retrieves the details of registered content.
     * @param contentId The ID of the content.
     * @return creator The address of the content creator.
     * @return owner The current owner of the content.
     * @return contentHash The hash of the content data.
     * @return contentType The type of content.
     */
    function getContentDetails(bytes32 contentId) external view returns (address creator, address owner, bytes32 contentHash, string memory contentType);

    /**
     * @dev Retrieves all content registered by a specific creator.
     * @param creator The address of the creator.
     * @return contentIds An array of content IDs registered by the creator.
     */
    function getContentByCreator(address creator) external view returns (bytes32[] memory contentIds);
}