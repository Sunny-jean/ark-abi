// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPFSRegistry {
    /**
     * @dev Emitted when an IPFS CID is registered.
     * @param cid The IPFS Content Identifier.
     * @param owner The address that registered the CID.
     * @param metadataHash An optional hash of associated metadata.
     */
    event CIDRegistered(bytes32 indexed cid, address indexed owner, bytes32 metadataHash);

    /**
     * @dev Emitted when an IPFS CID is updated.
     * @param cid The IPFS Content Identifier.
     * @param newOwner The new owner of the CID.
     * @param newMetadataHash The new optional hash of associated metadata.
     */
    event CIDUpdated(bytes32 indexed cid, address indexed newOwner, bytes32 newMetadataHash);

    /**
     * @dev Emitted when an IPFS CID is removed.
     * @param cid The IPFS Content Identifier.
     */
    event CIDRemoved(bytes32 indexed cid);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when an IPFS CID is not found in the registry.
     */
    error CIDNotFound(bytes32 cid);

    /**
     * @dev Thrown when an IPFS CID is already registered.
     */
    error CIDAlreadyRegistered(bytes32 cid);

    /**
     * @dev Registers a new IPFS Content Identifier (CID) with an owner and optional metadata.
     * @param cid The IPFS Content Identifier (e.g., Qm...).
     * @param metadataHash An optional hash of associated metadata (e.g., a hash of a JSON file).
     */
    function registerCID(bytes32 cid, bytes32 metadataHash) external;

    /**
     * @dev Updates the owner or metadata hash of an existing IPFS CID.
     * Only callable by the current owner of the CID or an authorized administrator.
     * @param cid The IPFS Content Identifier.
     * @param newOwner The new owner of the CID (address(0) to keep current owner).
     * @param newMetadataHash The new optional hash of associated metadata (bytes32(0) to keep current metadata).
     */
    function updateCID(bytes32 cid, address newOwner, bytes32 newMetadataHash) external;

    /**
     * @dev Removes an IPFS CID from the registry.
     * Only callable by the owner of the CID or an authorized administrator.
     * @param cid The IPFS Content Identifier to remove.
     */
    function removeCID(bytes32 cid) external;

    /**
     * @dev Retrieves the owner and metadata hash of a registered IPFS CID.
     * @param cid The IPFS Content Identifier to query.
     * @return owner The address that registered the CID.
     * @return metadataHash The hash of the associated metadata.
     */
    function getCIDDetails(bytes32 cid) external view returns (address owner, bytes32 metadataHash);

    /**
     * @dev Checks if an IPFS CID is registered.
     * @param cid The IPFS Content Identifier to check.
     * @return isRegistered True if the CID is registered, false otherwise.
     */
    function isCIDRegistered(bytes32 cid) external view returns (bool isRegistered);
}