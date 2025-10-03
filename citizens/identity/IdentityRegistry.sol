// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IdentityRegistry {
    /**
     * @dev Emitted when a new identity is registered or an existing one is updated.
     * @param identityId The unique ID of the identity.
     * @param owner The address that owns the identity.
     * @param metadataHash A hash of the identity's metadata.
     */
    event IdentityUpdated(bytes32 indexed identityId, address indexed owner, bytes32 metadataHash);

    /**
     * @dev Emitted when an identity is revoked.
     * @param identityId The unique ID of the revoked identity.
     * @param revoker The address that revoked the identity.
     */
    event IdentityRevoked(bytes32 indexed identityId, address indexed revoker);

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
     * @dev Thrown when an identity with the given ID is not found.
     */
    error IdentityNotFound(bytes32 identityId);

    /**
     * @dev Thrown when attempting to register an identity that already exists.
     */
    error IdentityAlreadyExists(bytes32 identityId);

    /**
     * @dev Thrown when attempting to revoke an identity that is already revoked.
     */
    error IdentityAlreadyRevoked(bytes32 identityId);

    /**
     * @dev Registers a new identity or updates an existing one.
     * @param identityId The unique ID for the identity.
     * @param owner The address that will own this identity.
     * @param metadataURI A URI pointing to the identity's metadata (e.g., IPFS hash).
     */
    function registerIdentity(bytes32 identityId, address owner, string calldata metadataURI) external;

    /**
     * @dev Revokes an existing identity.
     * @param identityId The unique ID of the identity to revoke.
     */
    function revokeIdentity(bytes32 identityId) external;

    /**
     * @dev Retrieves the owner of a given identity.
     * @param identityId The unique ID of the identity.
     * @return owner The address that owns the identity.
     */
    function getIdentityOwner(bytes32 identityId) external view returns (address owner);

    /**
     * @dev Retrieves the metadata URI for a given identity.
     * @param identityId The unique ID of the identity.
     * @return metadataURI A URI pointing to the identity's metadata.
     */
    function getIdentityMetadataURI(bytes32 identityId) external view returns (string memory metadataURI);

    /**
     * @dev Checks if an identity is currently valid (not revoked).
     * @param identityId The unique ID of the identity.
     * @return isValid True if the identity is valid, false otherwise.
     */
    function isIdentityValid(bytes32 identityId) external view returns (bool isValid);
}