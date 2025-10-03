// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface DIDRegistry {
    /**
     * @dev Emitted when a DID document is registered or updated.
     * @param did The Decentralized Identifier.
     * @param owner The controller of the DID.
     * @param documentHash A hash of the DID document.
     */
    event DIDUpdated(bytes32 indexed did, address indexed owner, bytes32 documentHash);

    /**
     * @dev Emitted when a DID is revoked.
     * @param did The Decentralized Identifier.
     * @param revoker The address that revoked the DID.
     */
    event DIDRevoked(bytes32 indexed did, address indexed revoker);

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
     * @dev Thrown when a DID is not found in the registry.
     */
    error DIDNotFound(bytes32 did);

    /**
     * @dev Thrown when an attempt is made to register an already existing DID.
     */
    error DIDAlreadyExists(bytes32 did);

    /**
     * @dev Registers a new Decentralized Identifier (DID) and its associated document hash.
     * @param did The unique Decentralized Identifier.
     * @param documentHash A hash of the DID document, typically stored off-chain.
     */
    function registerDID(bytes32 did, bytes32 documentHash) external;

    /**
     * @dev Updates the DID document hash for an existing DID.
     * @param did The unique Decentralized Identifier.
     * @param newDocumentHash The new hash of the DID document.
     */
    function updateDID(bytes32 did, bytes32 newDocumentHash) external;

    /**
     * @dev Revokes an existing DID, marking it as invalid.
     * @param did The unique Decentralized Identifier to revoke.
     */
    function revokeDID(bytes32 did) external;

    /**
     * @dev Retrieves the current document hash and owner for a given DID.
     * @param did The unique Decentralized Identifier.
     * @return owner The controller of the DID.
     * @return documentHash The hash of the DID document.
     * @return isRevoked True if the DID has been revoked, false otherwise.
     */
    function getDIDDetails(bytes32 did) external view returns (address owner, bytes32 documentHash, bool isRevoked);
}