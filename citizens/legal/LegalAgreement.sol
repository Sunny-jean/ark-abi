// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface LegalAgreement {
    /**
     * @dev Emitted when a new legal agreement is added.
     * @param agreementId The unique ID of the agreement.
     * @param agreementHash The hash of the agreement content.
     * @param agreementType The type of agreement (e.g., "TermsOfService", "PrivacyPolicy").
     */
    event AgreementAdded(bytes32 indexed agreementId, bytes32 agreementHash, string agreementType);

    /**
     * @dev Emitted when a user accepts a legal agreement.
     * @param user The address of the user who accepted.
     * @param agreementId The ID of the agreement accepted.
     * @param timestamp The timestamp of acceptance.
     */
    event AgreementAccepted(address indexed user, bytes32 indexed agreementId, uint256 timestamp);

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
     * @dev Thrown when an agreement with the given ID is not found.
     */
    error AgreementNotFound(bytes32 agreementId);

    /**
     * @dev Thrown when a user has already accepted a specific agreement.
     */
    error AlreadyAccepted(address user, bytes32 agreementId);

    /**
     * @dev Adds a new legal agreement to the system.
     * @param agreementId The unique ID for the agreement.
     * @param agreementHash The hash of the agreement content (e.g., IPFS hash).
     * @param agreementType The type of agreement (e.g., "TermsOfService", "PrivacyPolicy").
     * @param documentURI The URI where the full document can be accessed (e.g., IPFS URI).
     */
    function addAgreement(bytes32 agreementId, bytes32 agreementHash, string calldata agreementType, string calldata documentURI) external;

    /**
     * @dev Records a user's acceptance of a specific legal agreement.
     * @param agreementId The ID of the agreement being accepted.
     */
    function acceptAgreement(bytes32 agreementId) external;

    /**
     * @dev Checks if a user has accepted a specific legal agreement.
     * @param user The address of the user.
     * @param agreementId The ID of the agreement.
     * @return hasAccepted True if the user has accepted, false otherwise.
     */
    function hasAccepted(address user, bytes32 agreementId) external view returns (bool hasAccepted);

    /**
     * @dev Retrieves the details of a legal agreement.
     * @param agreementId The ID of the agreement.
     * @return agreementHash The hash of the agreement content.
     * @return agreementType The type of agreement.
     * @return documentURI The URI where the full document can be accessed.
     */
    function getAgreementDetails(bytes32 agreementId) external view returns (bytes32 agreementHash, string memory agreementType, string memory documentURI);

    /**
     * @dev Retrieves a list of all active legal agreements.
     * @return agreementIds An array of all active agreement IDs.
     */
    function getAllAgreements() external view returns (bytes32[] memory agreementIds);
}