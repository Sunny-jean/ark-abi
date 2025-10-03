// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface KYCRegistry {
    /**
     * @dev Emitted when an address's KYC status is updated.
     * @param user The address whose KYC status was updated.
     * @param status The new KYC status (e.g., 0 for unverified, 1 for verified).
     * @param verifier The address that performed the verification.
     */
    event KYCStatusUpdated(address indexed user, uint256 status, address indexed verifier);

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
     * @dev Thrown when an attempt is made to set an invalid KYC status.
     */
    error InvalidKYCStatus(uint256 status);

    /**
     * @dev Sets or updates the KYC status for a given address.
     * @param user The address whose KYC status is being set.
     * @param status The KYC status to set (e.g., 0 for unverified, 1 for verified).
     */
    function setKYCStatus(address user, uint256 status) external;

    /**
     * @dev Retrieves the KYC status of a given address.
     * @param user The address to query.
     * @return status The KYC status of the user.
     */
    function getKYCStatus(address user) external view returns (uint256 status);

    /**
     * @dev Checks if a user is KYC verified.
     * @param user The address to check.
     * @return isVerified True if the user is KYC verified, false otherwise.
     */
    function isKYCVerified(address user) external view returns (bool isVerified);
}