// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface UserProfile {
    /**
     * @dev Emitted when a user's profile is created or updated.
     * @param user The address of the user.
     * @param username The new username.
     * @param bio The new biography.
     * @param profilePictureHash The IPFS hash of the profile picture.
     */
    event ProfileUpdated(address indexed user, string username, string bio, string profilePictureHash);

    /**
     * @dev Emitted when a user's profile is deleted.
     * @param user The address of the user.
     */
    event ProfileDeleted(address indexed user);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a username is already taken.
     */
    error UsernameTaken(string username);

    /**
     * @dev Thrown when a profile for the given user is not found.
     */
    error ProfileNotFound(address user);

    /**
     * @dev Creates or updates a user's profile.
     * @param username The desired username. Must be unique.
     * @param bio A short biography for the user.
     * @param profilePictureHash An IPFS hash or URL to the user's profile picture.
     */
    function setProfile(string calldata username, string calldata bio, string calldata profilePictureHash) external;

    /**
     * @dev Deletes a user's profile.
     * Only the user themselves or an authorized administrator can delete a profile.
     */
    function deleteProfile() external;

    /**
     * @dev Retrieves a user's profile details.
     * @param user The address of the user to query.
     * @return username The username of the user.
     * @return bio The biography of the user.
     * @return profilePictureHash The IPFS hash of the profile picture.
     */
    function getProfile(address user) external view returns (string memory username, string memory bio, string memory profilePictureHash);

    /**
     * @dev Retrieves the address associated with a given username.
     * @param username The username to query.
     * @return user The address of the user.
     */
    function getAddressByUsername(string calldata username) external view returns (address user);
}