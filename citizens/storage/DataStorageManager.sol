// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface DataStorageManager {
    /**
     * @dev Emitted when a new data record is stored.
     * @param dataId The unique ID of the stored data.
     * @param owner The address that owns the data.
     * @param dataHash A hash of the stored data.
     */
    event DataStored(bytes32 indexed dataId, address indexed owner, bytes32 dataHash);

    /**
     * @dev Emitted when an existing data record is updated.
     * @param dataId The unique ID of the updated data.
     * @param newDataHash A hash of the new data.
     */
    event DataUpdated(bytes32 indexed dataId, bytes32 newDataHash);

    /**
     * @dev Emitted when a data record is deleted.
     * @param dataId The unique ID of the deleted data.
     */
    event DataDeleted(bytes32 indexed dataId);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a required parameter is missing or invalid.
     */

    /**
     * @dev Thrown when a data record with the given ID is not found.
     */
    error DataNotFound(bytes32 dataId);

    /**
     * @dev Stores a new data record and associates it with an owner.
     * @param dataHash A hash of the data to be stored (data itself is off-chain).
     * @param owner The address that owns this data record.
     * @return dataId The unique ID generated for this data record.
     */
    function storeData(bytes32 dataHash, address owner) external returns (bytes32 dataId);

    /**
     * @dev Updates an existing data record.
     * @param dataId The unique ID of the data record to update.
     * @param newDataHash The new hash of the data.
     */
    function updateData(bytes32 dataId, bytes32 newDataHash) external;

    /**
     * @dev Deletes a data record.
     * @param dataId The unique ID of the data record to delete.
     */
    function deleteData(bytes32 dataId) external;

    /**
     * @dev Retrieves the hash and owner of a stored data record.
     * @param dataId The unique ID of the data record.
     * @return dataHash The hash of the stored data.
     * @return owner The address that owns the data.
     */
    function getDataDetails(bytes32 dataId) external view returns (bytes32 dataHash, address owner);
}