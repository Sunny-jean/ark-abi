// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface TokenLock {
    /**
     * @dev Emitted when tokens are locked.
     */
    event TokensLocked(address indexed user, address indexed token, uint256 amount, uint256 unlockTime);

    /**
     * @dev Emitted when locked tokens are released.
     */
    event TokensReleased(address indexed user, address indexed token, uint256 amount);

    /**
     * @dev Error when tokens are not yet unlocked.
     */
    error TokensNotYetUnlocked(uint256 unlockTime);

    /**
     * @dev Error when insufficient locked tokens are available.
     */
    error InsufficientLockedTokens(uint256 requested, uint256 available);

    /**
     * @dev Locks `amount` of `token` for `user` until `unlockTime`.
     * @param user The address of the user locking tokens.
     * @param token The address of the ERC-20 token to lock.
     * @param amount The amount of tokens to lock.
     * @param unlockTime The timestamp when the tokens will be unlocked.
     */
    function lockTokens(address user, address token, uint256 amount, uint256 unlockTime) external;

    /**
     * @dev Releases locked tokens to the `user` after `unlockTime`.
     * @param user The address of the user whose tokens are to be released.
     * @param token The address of the ERC-20 token to release.
     */
    function releaseTokens(address user, address token) external;

    /**
     * @dev Returns the amount of `token` locked by `user`.
     * @param user The address of the user.
     * @param token The address of the ERC-20 token.
     * @return The amount of locked tokens.
     */
    function lockedBalance(address user, address token) external view returns (uint256);

    /**
     * @dev Returns the unlock time for `user`'s `token`.
     * @param user The address of the user.
     * @param token The address of the ERC-20 token.
     * @return The unlock time.
     */
    function getUnlockTime(address user, address token) external view returns (uint256);
}