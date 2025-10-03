// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface CreatorIdentity {
    /**
     * @dev Emitted when a creator's identity is verified.
     * @param creatorId The unique ID of the creator.
     * @param verifier The address that performed the verification.
     * @param timestamp The time of verification.
     */
    event IdentityVerified(bytes32 indexed creatorId, address indexed verifier, uint256 timestamp);

    /**
     * @dev Emitted when a creator's identity status is updated.
     * @param creatorId The unique ID of the creator.
     * @param newStatus The new status of the identity (e.g., "verified", "pending", "revoked").
     */
    event IdentityStatusUpdated(bytes32 indexed creatorId, string newStatus);

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
     * @dev Thrown when the specified creator ID is not found.
     */
    error CreatorNotFound(bytes32 creatorId);

    /**
     * @dev Thrown when identity verification fails.
     */
    error VerificationFailed(bytes32 creatorId, string reason);

    /**
     * @dev Verifies the identity of a module creator.
     * @param creatorId The unique ID of the creator.
     * @param verificationData Data used for verification (e.g., hash of KYC document).
     */
    function verifyIdentity(bytes32 creatorId, bytes calldata verificationData) external;

    /**
     * @dev Updates the verification status of a creator's identity.
     * @param creatorId The unique ID of the creator.
     * @param newStatus The new status of the identity.
     */
    function updateIdentityStatus(bytes32 creatorId, string calldata newStatus) external;

    /**
     * @dev Retrieves the current identity verification status of a creator.
     * @param creatorId The unique ID of the creator.
     * @return status The current status of the identity.
     * @return lastVerifiedTime The timestamp of the last successful verification.
     */
    function getIdentityStatus(bytes32 creatorId) external view returns (string memory status, uint256 lastVerifiedTime);
}