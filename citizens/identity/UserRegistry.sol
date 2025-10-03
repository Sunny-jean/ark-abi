// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface UserRegistry {
    /**
     * @dev Emitted when a new user is registered.
     * @param userId The unique ID of the registered user.
     * @param userAddress The blockchain address of the user.
     * @param registrationTime The timestamp of registration.
     */
    event UserRegistered(bytes32 indexed userId, address indexed userAddress, uint256 registrationTime);

    /**
     * @dev Emitted when a user's profile is updated.
     * @param userId The unique ID of the user.
     * @param newProfileHash A hash of the updated user profile data.
     */
    event UserProfileUpdated(bytes32 indexed userId, bytes32 newProfileHash);

    /**
     * @dev Emitted when a user's account is deactivated.
     * @param userId The unique ID of the user.
     * @param deactivationTime The timestamp of deactivation.
     */
    event UserDeactivated(bytes32 indexed userId, uint256 deactivationTime);

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
     * @dev Thrown when a user with the given ID or address already exists.
     */
    error UserAlreadyExists(bytes32 userId, address userAddress);

    /**
     * @dev Thrown when a user with the given ID or address is not found.
     */
    error UserNotFound(bytes32 userIdOrAddress);

    /**
     * @dev Registers a new user in the system.
     * @param userAddress The blockchain address of the user.
     * @param profileHash A hash of the user's off-chain profile data.
     * @return userId The unique ID assigned to the registered user.
     */
    function registerUser(address userAddress, bytes32 profileHash) external returns (bytes32 userId);

    /**
     * @dev Updates the profile hash for an existing user.
     * @param userId The unique ID of the user.
     * @param newProfileHash The new hash of the user's off-chain profile data.
     */
    function updateUserProfile(bytes32 userId, bytes32 newProfileHash) external;

    /**
     * @dev Deactivates a user's account.
     * @param userId The unique ID of the user to deactivate.
     */
    function deactivateUser(bytes32 userId) external;

    /**
     * @dev Retrieves the blockchain address associated with a user ID.
     * @param userId The unique ID of the user.
     * @return userAddress The blockchain address of the user.
     */
    function getUserAddress(bytes32 userId) external view returns (address userAddress);

    /**
     * @dev Retrieves the user ID associated with a blockchain address.
     * @param userAddress The blockchain address of the user.
     * @return userId The unique ID of the user.
     */
    function getUserId(address userAddress) external view returns (bytes32 userId);

    /**
     * @dev Checks if a user is registered and active.
     * @param userId The unique ID of the user.
     * @return isActive True if the user is registered and active, false otherwise.
     */
    function isUserActive(bytes32 userId) external view returns (bool isActive);
}