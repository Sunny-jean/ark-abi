// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface DecentralizedStorage {
    /**
     * @dev Emitted when a new file is uploaded to decentralized storage.
     * @param fileId The unique ID of the file.
     * @param uploader The address that uploaded the file.
     * @param contentHash The content hash of the file (e.g., IPFS CID).
     * @param fileSize The size of the file in bytes.
     */
    event FileUploaded(bytes32 indexed fileId, address indexed uploader, bytes32 contentHash, uint256 fileSize);

    /**
     * @dev Emitted when a file's metadata is updated.
     * @param fileId The unique ID of the file.
     * @param newContentHash The new content hash of the file.
     */
    event FileMetadataUpdated(bytes32 indexed fileId, bytes32 newContentHash);

    /**
     * @dev Emitted when a file is removed from decentralized storage.
     * @param fileId The unique ID of the file.
     */
    event FileRemoved(bytes32 indexed fileId);

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
     * @dev Thrown when a file with the given ID is not found.
     */
    error FileNotFound(bytes32 fileId);

    /**
     * @dev Uploads a new file to decentralized storage.
     * @param fileId The unique ID for the file.
     * @param contentHash The content hash (e.g., IPFS CID) of the file.
     * @param fileSize The size of the file in bytes.
     * @param metadataHash An optional hash of additional metadata.
     */
    function uploadFile(bytes32 fileId, bytes32 contentHash, uint256 fileSize, bytes32 metadataHash) external;

    /**
     * @dev Updates the content hash or metadata hash of an existing file.
     * Only callable by the original uploader or authorized administrators.
     * @param fileId The ID of the file to update.
     * @param newContentHash The new content hash.
     * @param newMetadataHash The new metadata hash.
     */
    function updateFile(bytes32 fileId, bytes32 newContentHash, bytes32 newMetadataHash) external;

    /**
     * @dev Removes a file from the registry.
     * Note: This only removes the record from the blockchain, not the data from the decentralized storage network itself.
     * @param fileId The ID of the file to remove.
     */
    function removeFile(bytes32 fileId) external;

    /**
     * @dev Retrieves the details of a stored file.
     * @param fileId The ID of the file.
     * @return uploader The address that uploaded the file.
     * @return contentHash The content hash of the file.
     * @return fileSize The size of the file.
     * @return metadataHash The hash of additional metadata.
     */
    function getFileDetails(bytes32 fileId) external view returns (address uploader, bytes32 contentHash, uint256 fileSize, bytes32 metadataHash);

    /**
     * @dev Retrieves a list of all files uploaded by a specific address.
     * @param uploader The address of the uploader.
     * @return fileIds An array of file IDs uploaded by the address.
     */
    function getFilesByUploader(address uploader) external view returns (bytes32[] memory fileIds);
}