// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface SocialFeed {
    /**
     * @dev Emitted when a new post is created.
     * @param postId The unique ID of the post.
     * @param author The address of the author.
     * @param timestamp The timestamp when the post was created.
     * @param contentHash The IPFS hash or content identifier of the post.
     */
    event PostCreated(bytes32 indexed postId, address indexed author, uint256 timestamp, string contentHash);

    /**
     * @dev Emitted when a post is liked or unliked.
     * @param postId The ID of the post.
     * @param liker The address of the user who liked/unliked the post.
     * @param isLiked True if liked, false if unliked.
     */
    event PostLiked(bytes32 indexed postId, address indexed liker, bool isLiked);

    /**
     * @dev Emitted when a post is commented on.
     * @param postId The ID of the post.
     * @param commentId The unique ID of the comment.
     * @param commenter The address of the commenter.
     * @param timestamp The timestamp when the comment was created.
     * @param contentHash The IPFS hash or content identifier of the comment.
     */
    event CommentAdded(bytes32 indexed postId, bytes32 indexed commentId, address indexed commenter, uint256 timestamp, string contentHash);

    /**
     * @dev Emitted when a post is deleted.
     * @param postId The ID of the post.
     * @param deleter The address of the user who deleted the post.
     */
    event PostDeleted(bytes32 indexed postId, address indexed deleter);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a post with the given ID is not found.
     */
    error PostNotFound(bytes32 postId);

    /**
     * @dev Thrown when a comment with the given ID is not found.
     */
    error CommentNotFound(bytes32 commentId);

    /**
     * @dev Thrown when the content hash is empty.
     */
    error EmptyContent();

    /**
     * @dev Creates a new social feed post.
     * The content itself is expected to be stored off-chain (e.g., IPFS) and its hash provided.
     * @param contentHash The IPFS hash or content identifier of the post.
     * @return postId The unique ID of the created post.
     */
    function createPost(string calldata contentHash) external returns (bytes32 postId);

    /**
     * @dev Likes or unlikes a post.
     * @param postId The ID of the post to like/unlike.
     * @param like True to like, false to unlike.
     */
    function likePost(bytes32 postId, bool like) external;

    /**
     * @dev Adds a comment to an existing post.
     * The comment content itself is expected to be stored off-chain (e.g., IPFS) and its hash provided.
     * @param postId The ID of the post to comment on.
     * @param contentHash The IPFS hash or content identifier of the comment.
     * @return commentId The unique ID of the created comment.
     */
    function addComment(bytes32 postId, string calldata contentHash) external returns (bytes32 commentId);

    /**
     * @dev Deletes a post.
     * Only the author or an authorized administrator can delete a post.
     * @param postId The ID of the post to delete.
     */
    function deletePost(bytes32 postId) external;

    /**
     * @dev Retrieves the details of a specific post.
     * @param postId The ID of the post to query.
     * @return author The address of the author.
     * @return timestamp The timestamp when the post was created.
     * @return contentHash The IPFS hash of the post content.
     * @return likeCount The number of likes the post has received.
     * @return commentCount The number of comments the post has received.
     */
    function getPostDetails(bytes32 postId) external view returns (address author, uint256 timestamp, string memory contentHash, uint256 likeCount, uint256 commentCount);

    /**
     * @dev Retrieves all comments for a specific post.
     * @param postId The ID of the post to query.
     * @return commentIds An array of comment IDs for the post.
     */
    function getPostComments(bytes32 postId) external view returns (bytes32[] memory commentIds);

    /**
     * @dev Retrieves the latest posts from the social feed.
     * @param count The number of latest posts to retrieve.
     * @return postIds An array of the latest post IDs.
     */
    function getLatestPosts(uint256 count) external view returns (bytes32[] memory postIds);
}