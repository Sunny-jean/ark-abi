// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface VotingEscrow {
    /**
     * @dev Emitted when a user locks tokens for voting power.
     * @param user The address of the user.
     * @param amount The amount of tokens locked.
     * @param unlockTime The timestamp when tokens will unlock.
     */
    event TokensLocked(address indexed user, uint256 amount, uint256 unlockTime);

    /**
     * @dev Emitted when a user withdraws unlocked tokens.
     * @param user The address of the user.
     * @param amount The amount of tokens withdrawn.
     */
    event TokensWithdrawn(address indexed user, uint256 amount);

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
     * @dev Thrown when the lock duration is too short or too long.
     */
    error InvalidLockDuration(uint256 duration);

    /**
     * @dev Thrown when tokens are still locked and cannot be withdrawn.
     */
    error TokensStillLocked(uint256 unlockTime);

    /**
     * @dev Locks a specified amount of tokens for a given duration to gain voting power.
     * @param amount The amount of tokens to lock.
     * @param unlockTime The timestamp when the tokens will become unlocked.
     */
    function createLock(uint256 amount, uint256 unlockTime) external;

    /**
     * @dev Increases the amount of tokens locked in an existing lock.
     * @param amount The additional amount of tokens to lock.
     */
    function increaseAmount(uint256 amount) external;

    /**
     * @dev Extends the unlock time of an existing lock.
     * @param newUnlockTime The new timestamp when the tokens will unlock.
     */
    function increaseUnlockTime(uint256 newUnlockTime) external;

    /**
     * @dev Withdraws unlocked tokens from the escrow.
     */
    function withdraw() external;

    /**
     * @dev Returns the current voting power of a user at a specific timestamp.
     * @param user The address of the user.
     * @param timestamp The timestamp at which to query voting power.
     * @return votingPower The voting power of the user.
     */
    function getVotingPower(address user, uint256 timestamp) external view returns (uint256 votingPower);

    /**
     * @dev Returns the amount of tokens locked by a user and their unlock time.
     * @param user The address of the user.
     * @return lockedAmount The amount of tokens locked.
     * @return unlockTime The timestamp when tokens will unlock.
     */
    function getLockedBalance(address user) external view returns (uint256 lockedAmount, uint256 unlockTime);
}