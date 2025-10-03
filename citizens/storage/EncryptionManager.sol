// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface EncryptionManager {
    /**
     * @dev Emitted when a new encryption key is registered.
     * @param owner The address of the key owner.
     * @param keyId The unique ID of the registered key.
     * @param publicKeyHash A hash of the public key.
     */
    event EncryptionKeyRegistered(address indexed owner, bytes32 indexed keyId, bytes32 publicKeyHash);

    /**
     * @dev Emitted when an encryption key is revoked.
     * @param keyId The unique ID of the revoked key.
     */
    event EncryptionKeyRevoked(bytes32 indexed keyId);

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
     * @dev Thrown when an encryption key with the given ID is not found.
     */
    error KeyNotFound(bytes32 keyId);

    /**
     * @dev Thrown when an attempt is made to register an already existing key.
     */
    error KeyAlreadyExists(bytes32 keyId);

    /**
     * @dev Registers a public encryption key for an owner.
     * @param owner The address that owns this key.
     * @param publicKeyHash A hash of the public key (the key itself is stored off-chain).
     * @return keyId The unique ID generated for this key.
     */
    function registerPublicKey(address owner, bytes32 publicKeyHash) external returns (bytes32 keyId);

    /**
     * @dev Revokes an existing encryption key.
     * @param keyId The unique ID of the key to revoke.
     */
    function revokePublicKey(bytes32 keyId) external;

    /**
     * @dev Retrieves the public key hash for a given key ID.
     * @param keyId The unique ID of the key.
     * @return owner The address of the key owner.
     * @return publicKeyHash The hash of the public key.
     * @return isRevoked True if the key has been revoked, false otherwise.
     */
    function getPublicKeyDetails(bytes32 keyId) external view returns (address owner, bytes32 publicKeyHash, bool isRevoked);

    /**
     * @dev Encrypts data using a specified public key.
     * @param keyId The ID of the public key to use for encryption.
     * @param data The data to encrypt.
     * @return encryptedData The encrypted data.
     */
    function encryptData(bytes32 keyId, bytes calldata data) external view returns (bytes memory encryptedData);
}