// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface EncryptedDataStorage {
    /**
     * @dev Emitted when encrypted data is stored.
     * @param dataId The unique ID of the data.
     * @param owner The address that owns the data.
     * @param encryptedHash The hash of the encrypted content.
     * @param encryptionKeyHash The hash of the encryption key.
     */
    event EncryptedDataStored(bytes32 indexed dataId, address indexed owner, bytes32 encryptedHash, bytes32 encryptionKeyHash);

    /**
     * @dev Emitted when access to encrypted data is granted to another address.
     * @param dataId The unique ID of the data.
     * @param granter The address that granted access.
     * @param grantee The address that received access.
     */
    event AccessGranted(bytes32 indexed dataId, address indexed granter, address indexed grantee);

    /**
     * @dev Emitted when access to encrypted data is revoked from another address.
     * @param dataId The unique ID of the data.
     * @param revoker The address that revoked access.
     * @param revokedAddress The address from which access was revoked.
     */
    event AccessRevoked(bytes32 indexed dataId, address indexed revoker, address indexed revokedAddress);

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
     * @dev Thrown when data with the given ID is not found.
     */
    error DataNotFound(bytes32 dataId);

    /**
     * @dev Thrown when attempting to grant access to an address that already has it.
     */
    error AccessAlreadyGranted(bytes32 dataId, address grantee);

    /**
     * @dev Thrown when attempting to revoke access from an address that does not have it.
     */
    error AccessNotGranted(bytes32 dataId, address revokedAddress);

    /**
     * @dev Stores encrypted data on-chain.
     * @param dataId The unique ID for this data entry.
     * @param encryptedHash The hash of the encrypted content (e.g., IPFS CID of encrypted file).
     * @param encryptionKeyHash The hash of the encryption key (e.g., hash of symmetric key).
     */
    function storeEncryptedData(bytes32 dataId, bytes32 encryptedHash, bytes32 encryptionKeyHash) external;

    /**
     * @dev Grants read access to encrypted data to another address.
     * Only callable by the data owner.
     * @param dataId The ID of the data.
     * @param grantee The address to grant access to.
     */
    function grantAccess(bytes32 dataId, address grantee) external;

    /**
     * @dev Revokes read access to encrypted data from another address.
     * Only callable by the data owner.
     * @param dataId The ID of the data.
     * @param revokedAddress The address to revoke access from.
     */
    function revokeAccess(bytes32 dataId, address revokedAddress) external;

    /**
     * @dev Retrieves the details of stored encrypted data.
     * @param dataId The ID of the data.
     * @return owner The address that owns the data.
     * @return encryptedHash The hash of the encrypted content.
     * @return encryptionKeyHash The hash of the encryption key.
     */
    function getEncryptedDataDetails(bytes32 dataId) external view returns (address owner, bytes32 encryptedHash, bytes32 encryptionKeyHash);

    /**
     * @dev Checks if an address has access to specific encrypted data.
     * @param dataId The ID of the data.
     * @param user The address to check access for.
     * @return hasAccess True if the user has access, false otherwise.
     */
    function hasAccess(bytes32 dataId, address user) external view returns (bool hasAccess);
}