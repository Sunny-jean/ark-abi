// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ModuleSubscriptionManager {
    /**
     * @dev Emitted when a user subscribes to a module.
     * @param subscriber The address of the subscriber.
     * @param moduleId The ID of the module subscribed to.
     * @param subscriptionId The unique ID of the subscription.
     */
    event ModuleSubscribed(address indexed subscriber, bytes32 indexed moduleId, bytes32 indexed subscriptionId);

    /**
     * @dev Emitted when a user unsubscribes from a module.
     * @param subscriber The address of the subscriber.
     * @param moduleId The ID of the module unsubscribed from.
     * @param subscriptionId The unique ID of the subscription.
     */
    event ModuleUnsubscribed(address indexed subscriber, bytes32 indexed moduleId, bytes32 indexed subscriptionId);

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
     * @dev Allows a user to subscribe to a specific module.
     * @param moduleId The unique ID of the module to subscribe to.
     * @param paymentDetails Encoded payment information (e.g., amount, currency, duration).
     * @return subscriptionId The unique ID generated for the new subscription.
     */
    function subscribeToModule(bytes32 moduleId, bytes calldata paymentDetails) external returns (bytes32 subscriptionId);

    /**
     * @dev Allows a user to unsubscribe from a specific module.
     * @param moduleId The unique ID of the module to unsubscribe from.
     */
    function unsubscribeFromModule(bytes32 moduleId) external;

    /**
     * @dev Checks the subscription status of a user for a given module.
     * @param user The address of the user.
     * @param moduleId The unique ID of the module.
     * @return isActive True if the user has an active subscription, false otherwise.
     * @return expiryTime The timestamp when the subscription expires (0 if not active).
     */
    function getSubscriptionStatus(address user, bytes32 moduleId) external view returns (bool isActive, uint256 expiryTime);
}