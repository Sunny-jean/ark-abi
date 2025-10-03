// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface SubscriptionRevenueManager {
    /**
     * @dev Emitted when a new subscription is created.
     * @param subscriber The address of the subscriber.
     * @param moduleId The ID of the module subscribed to.
     * @param amount The subscription amount.
     * @param currency The currency of the subscription.
     */
    event SubscriptionCreated(address indexed subscriber, bytes32 indexed moduleId, uint256 amount, address indexed currency);

    /**
     * @dev Emitted when a subscription is renewed.
     * @param subscriber The address of the subscriber.
     * @param moduleId The ID of the module.
     * @param newExpiry The new expiry timestamp.
     */
    event SubscriptionRenewed(address indexed subscriber, bytes32 indexed moduleId, uint256 newExpiry);

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
     * @dev Thrown when the module is not found.
     */
    error ModuleNotFound(bytes32 moduleId);

    /**
     * @dev Thrown when a subscription is not active or found.
     */
    error SubscriptionNotFound(address subscriber, bytes32 moduleId);

    /**
     * @dev Creates a new subscription for a module.
     * @param subscriber The address of the user subscribing.
     * @param moduleId The unique ID of the module being subscribed to.
     * @param amount The amount paid for the subscription.
     * @param currency The address of the ERC-20 token used for payment.
     * @param duration The duration of the subscription in seconds.
     */
    function createSubscription(address subscriber, bytes32 moduleId, uint256 amount, address currency, uint256 duration) external;

    /**
     * @dev Renews an existing subscription.
     * @param subscriber The address of the user renewing.
     * @param moduleId The unique ID of the module.
     * @param amount The amount paid for the renewal.
     * @param currency The address of the ERC-20 token used for payment.
     * @param duration The duration to extend the subscription in seconds.
     */
    function renewSubscription(address subscriber, bytes32 moduleId, uint256 amount, address currency, uint256 duration) external;

    /**
     * @dev Checks if a user has an active subscription for a module.
     * @param subscriber The address of the user.
     * @param moduleId The unique ID of the module.
     * @return isActive True if the subscription is active, false otherwise.
     * @return expiryTime The timestamp when the subscription expires.
     */
    function isSubscriptionActive(address subscriber, bytes32 moduleId) external view returns (bool isActive, uint256 expiryTime);
}