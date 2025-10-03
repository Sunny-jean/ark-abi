// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface KYCProviderRegistry {
    /**
     * @dev Emitted when a new KYC provider is registered.
     * @param providerAddress The address of the registered KYC provider.
     * @param name The name of the KYC provider.
     */
    event KYCProviderRegistered(address indexed providerAddress, string name);

    /**
     * @dev Emitted when a KYC provider's registration is revoked.
     * @param providerAddress The address of the revoked KYC provider.
     */
    event KYCProviderRevoked(address indexed providerAddress);

    /**
     * @dev Emitted when a user's KYC status is updated by a provider.
     * @param user The address of the user whose KYC status was updated.
     * @param provider The address of the KYC provider.
     * @param isApproved True if the user is KYC approved, false otherwise.
     */
    event UserKYCStatusUpdated(address indexed user, address indexed provider, bool isApproved);

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
     * @dev Thrown when attempting to register a provider that is already registered.
     */
    error ProviderAlreadyRegistered(address providerAddress);

    /**
     * @dev Thrown when attempting to revoke a provider that is not registered.
     */
    error ProviderNotRegistered(address providerAddress);

    /**
     * @dev Registers a new KYC provider.
     * Only callable by authorized addresses (e.g., governance).
     * @param providerAddress The address of the KYC provider.
     * @param name The name of the KYC provider.
     */
    function registerProvider(address providerAddress, string calldata name) external;

    /**
     * @dev Revokes the registration of an existing KYC provider.
     * Only callable by authorized addresses.
     * @param providerAddress The address of the KYC provider to revoke.
     */
    function revokeProvider(address providerAddress) external;

    /**
     * @dev Sets the KYC approval status for a user.
     * Only callable by registered KYC providers.
     * @param user The address of the user.
     * @param isApproved True if the user is KYC approved, false otherwise.
     */
    function setKYCStatus(address user, bool isApproved) external;

    /**
     * @dev Checks if a user is KYC approved.
     * @param user The address of the user to check.
     * @return isApproved True if the user is KYC approved, false otherwise.
     */
    function isKYCApproved(address user) external view returns (bool isApproved);

    /**
     * @dev Retrieves the details of a registered KYC provider.
     * @param providerAddress The address of the KYC provider.
     * @return name The name of the provider.
     * @return isRegistered True if the provider is registered, false otherwise.
     */
    function getProviderDetails(address providerAddress) external view returns (string memory name, bool isRegistered);

    /**
     * @dev Retrieves a list of all registered KYC providers.
     * @return providers An array of addresses of all registered KYC providers.
     */
    function getAllProviders() external view returns (address[] memory providers);
}