// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface VerifiableCredentials {
    /**
     * @dev Emitted when a verifiable credential is issued.
     * @param credentialId The unique ID of the credential.
     * @param holder The address of the credential holder.
     * @param issuer The address of the credential issuer.
     * @param schemaHash The hash of the credential schema.
     */
    event CredentialIssued(bytes32 indexed credentialId, address indexed holder, address indexed issuer, bytes32 schemaHash);

    /**
     * @dev Emitted when a verifiable credential is revoked.
     * @param credentialId The unique ID of the credential.
     */
    event CredentialRevoked(bytes32 indexed credentialId);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a credential with the given ID is not found.
     */
    error CredentialNotFound(bytes32 credentialId);

    /**
     * @dev Thrown when a credential is already revoked.
     */
    error CredentialAlreadyRevoked(bytes32 credentialId);

    /**
     * @dev Issues a new verifiable credential.
     * Only callable by authorized issuers.
     * @param credentialId The unique ID for the credential.
     * @param holder The address of the entity to whom the credential is issued.
     * @param schemaHash The hash of the schema that defines the credential's structure and claims.
     * @param credentialHash The hash of the actual credential data (e.g., IPFS CID).
     */
    function issueCredential(bytes32 credentialId, address holder, bytes32 schemaHash, bytes32 credentialHash) external;

    /**
     * @dev Revokes an issued verifiable credential.
     * Only callable by the original issuer or an authorized revocation manager.
     * @param credentialId The ID of the credential to revoke.
     */
    function revokeCredential(bytes32 credentialId) external;

    /**
     * @dev Verifies the status of a verifiable credential.
     * @param credentialId The ID of the credential to verify.
     * @return isValid True if the credential is valid and not revoked, false otherwise.
     * @return holder The address of the credential holder.
     * @return issuer The address of the credential issuer.
     * @return schemaHash The hash of the credential schema.
     * @return credentialHash The hash of the credential data.
     */
    function verifyCredential(bytes32 credentialId) external view returns (bool isValid, address holder, address issuer, bytes32 schemaHash, bytes32 credentialHash);

    /**
     * @dev Retrieves all credentials issued to a specific holder.
     * @param holder The address of the holder.
     * @return credentialIds An array of credential IDs issued to the holder.
     */
    function getCredentialsByHolder(address holder) external view returns (bytes32[] memory credentialIds);
}