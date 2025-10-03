// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface SocialProfile {
    /**
     * @dev Emitted when a user's profile is created or updated.
     * @param user The address of the user.
     * @param profileHash The hash of the updated profile data.
     */
    event ProfileUpdated(address indexed user, bytes32 profileHash);

    /**
     * @dev Emitted when a user follows another user.
     * @param follower The address of the follower.
     * @param followed The address of the user being followed.
     */
    event Followed(address indexed follower, address indexed followed);

    /**
     * @dev Emitted when a user unfollows another user.
     * @param unfollower The address of the unfollower.
     * @param unfollowed The address of the user being unfollowed.
     */
    event Unfollowed(address indexed unfollower, address indexed unfollowed);

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
     * @dev Thrown when a profile for the given user is not found.
     */
    error ProfileNotFound(address user);

    /**
     * @dev Thrown when a user tries to follow themselves.
     */
    error CannotFollowSelf();

    /**
     * @dev Thrown when a user tries to follow someone they already follow.
     */
    error AlreadyFollowing();

    /**
     * @dev Thrown when a user tries to unfollow someone they are not following.
     */
    error NotFollowing();

    /**
     * @dev Sets or updates a user's social profile.
     * @param name The user's display name.
     * @param bio A short biography of the user.
     * @param profilePictureURI A URI to the user's profile picture.
     */
    function setProfile(string calldata name, string calldata bio, string calldata profilePictureURI) external;

    /**
     * @dev Retrieves a user's social profile.
     * @param user The address of the user.
     * @return name The user's display name.
     * @return bio A short biography of the user.
     * @return profilePictureURI A URI to the user's profile picture.
     */
    function getProfile(address user) external view returns (string memory name, string memory bio, string memory profilePictureURI);

    /**
     * @dev Allows a user to follow another user.
     * @param userToFollow The address of the user to follow.
     */
    function follow(address userToFollow) external;

    /**
     * @dev Allows a user to unfollow another user.
     * @param userToUnfollow The address of the user to unfollow.
     */
    function unfollow(address userToUnfollow) external;

    /**
     * @dev Returns the list of users that a given user is following.
     * @param user The address of the user.
     * @return followingList An array of addresses that the user is following.
     */
    function getFollowing(address user) external view returns (address[] memory followingList);

    /**
     * @dev Returns the list of users that are following a given user.
     * @param user The address of the user.
     * @return followersList An array of addresses that are following the user.
     */
    function getFollowers(address user) external view returns (address[] memory followersList);
}