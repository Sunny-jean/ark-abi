// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface DataFeed {
    /**
     * @dev Emitted when new data is pushed to the feed.
     * @param dataId The unique ID of the data entry.
     * @param publisher The address that published the data.
     * @param timestamp The timestamp when the data was published.
     */
    event DataPublished(bytes32 indexed dataId, address indexed publisher, uint256 timestamp);

    /**
     * @dev Emitted when a data entry is updated.
     * @param dataId The unique ID of the data entry.
     * @param updater The address that updated the data.
     * @param timestamp The timestamp when the data was updated.
     */
    event DataUpdated(bytes32 indexed dataId, address indexed updater, uint256 timestamp);

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
     * @dev Thrown when a data entry with the given ID is not found.
     */
    error DataNotFound(bytes32 dataId);

    /**
     * @dev Thrown when attempting to publish data that already exists.
     */
    error DataAlreadyExists(bytes32 dataId);

    /**
     * @dev Publishes new data to the feed.
     * @param dataId The unique ID for the data entry.
     * @param data The raw data bytes.
     * @param metadataURI A URI pointing to additional metadata about the data.
     */
    function publishData(bytes32 dataId, bytes calldata data, string calldata metadataURI) external;

    /**
     * @dev Updates an existing data entry in the feed.
     * @param dataId The unique ID of the data entry to update.
     * @param newData The updated raw data bytes.
     * @param newMetadataURI An updated URI pointing to additional metadata.
     */
    function updateData(bytes32 dataId, bytes calldata newData, string calldata newMetadataURI) external;

    /**
     * @dev Retrieves the raw data for a given data ID.
     * @param dataId The unique ID of the data entry.
     * @return data The raw data bytes.
     * @return metadataURI A URI pointing to additional metadata.
     * @return publisher The address that originally published the data.
     * @return timestamp The timestamp when the data was last updated.
     */
    function getData(bytes32 dataId) external view returns (bytes memory data, string memory metadataURI, address publisher, uint256 timestamp);

    /**
     * @dev Retrieves a list of data IDs published by a specific address.
     * @param publisher The address of the publisher.
     * @return dataIds An array of data IDs published by the address.
     */
    function getPublishedDataIds(address publisher) external view returns (bytes32[] memory dataIds);
}