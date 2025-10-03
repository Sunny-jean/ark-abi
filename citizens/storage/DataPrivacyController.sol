// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface DataPrivacyController {
    /**
     * @dev Emitted when a user's data access consent is updated.
     * @param user The address of the user.
     * @param dataType The type of data (e.g., "personal_info", "usage_data").
     * @param hasConsent True if consent is granted, false otherwise.
     */
    event ConsentUpdated(address indexed user, string indexed dataType, bool hasConsent);

    /**
     * @dev Emitted when a data access request is granted or denied.
     * @param requestId The unique ID of the request.
     * @param granter The address that granted/denied the request.
     * @param granted True if the request was granted, false if denied.
     */
    event DataAccessRequestProcessed(bytes32 indexed requestId, address indexed granter, bool granted);

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
     * @dev Thrown when a data access request with the given ID is not found.
     */
    error RequestNotFound(bytes32 requestId);

    /**
     * @dev Sets or updates a user's consent for a specific type of data.
     * @param dataType The type of data for which consent is being set (e.g., "personal_info", "usage_data").
     * @param hasConsent True to grant consent, false to revoke.
     */
    function updateConsent(string calldata dataType, bool hasConsent) external;

    /**
     * @dev Checks if a user has granted consent for a specific type of data.
     * @param user The address of the user.
     * @param dataType The type of data to check consent for.
     * @return hasConsent True if consent is granted, false otherwise.
     */
    function checkConsent(address user, string calldata dataType) external view returns (bool hasConsent);

    /**
     * @dev Submits a request to access a user's private data.
     * @param user The address of the user whose data is requested.
     * @param dataType The type of data being requested.
     * @param purpose A description of the purpose for the data access.
     * @return requestId The unique ID generated for this request.
     */
    function requestDataAccess(address user, string calldata dataType, string calldata purpose) external returns (bytes32 requestId);

    /**
     * @dev Processes a data access request (e.g., by a data custodian).
     * @param requestId The unique ID of the data access request.
     * @param grantAccess True to grant access, false to deny.
     */
    function processDataAccessRequest(bytes32 requestId, bool grantAccess) external;
}