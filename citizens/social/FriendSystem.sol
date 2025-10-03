// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface FriendSystem {
    /**
     * @dev Emitted when a friend request is sent.
     * @param sender The address of the sender.
     * @param receiver The address of the receiver.
     */
    event FriendRequestSent(address indexed sender, address indexed receiver);

    /**
     * @dev Emitted when a friend request is accepted.
     * @param accepter The address that accepted the request.
     * @param requester The address that sent the request.
     */
    event FriendRequestAccepted(address indexed accepter, address indexed requester);

    /**
     * @dev Emitted when a friend request is rejected.
     * @param rejecter The address that rejected the request.
     * @param requester The address that sent the request.
     */
    event FriendRequestRejected(address indexed rejecter, address indexed requester);

    /**
     * @dev Emitted when a friendship is removed.
     * @param remover The address that initiated the removal.
     * @param removed The address that was removed.
     */

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a friend request is sent to oneself.
     */
    error CannotBefriendSelf();

    /**
     * @dev Thrown when a friend request is sent to an existing friend.
     */
    error AlreadyFriends(address user1, address user2);

    /**
     * @dev Thrown when a duplicate friend request is sent.
     */
    error DuplicateFriendRequest(address sender, address receiver);

    /**
     * @dev Thrown when a friend request is not found.
     */
    error FriendRequestNotFound(address sender, address receiver);

    /**
     * @dev Sends a friend request to another user.
     * @param receiver The address of the user to send the request to.
     */
    function sendFriendRequest(address receiver) external;

    /**
     * @dev Accepts a pending friend request.
     * @param requester The address of the user who sent the request.
     */
    function acceptFriendRequest(address requester) external;

    /**
     * @dev Rejects a pending friend request.
     * @param requester The address of the user who sent the request.
     */
    function rejectFriendRequest(address requester) external;

    /**
     * @dev Removes an existing friend.
     * @param friendAddress The address of the friend to remove.
     */
    function removeFriend(address friendAddress) external;

    /**
     * @dev Retrieves a list of a user's friends.
     * @param user The address of the user to query.
     * @return friends An array of friend addresses.
     */
    function getFriends(address user) external view returns (address[] memory friends);

    /**
     * @dev Retrieves a list of pending incoming friend requests for a user.
     * @param user The address of the user to query.
     * @return requests An array of addresses that sent friend requests to the user.
     */
    function getPendingRequests(address user) external view returns (address[] memory requests);

    /**
     * @dev Checks if two users are friends.
     * @param user1 The address of the first user.
     * @param user2 The address of the second user.
     * @return True if they are friends, false otherwise.
     */
    function areFriends(address user1, address user2) external view returns (bool);
}