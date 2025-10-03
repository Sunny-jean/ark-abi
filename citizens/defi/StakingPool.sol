// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface StakingPool {
    /**
     * @dev Emitted when tokens are staked.
     * @param user The address of the user who staked.
     * @param amount The amount of tokens staked.
     */
    event Staked(address indexed user, uint256 amount);

    /**
     * @dev Emitted when staked tokens are withdrawn.
     * @param user The address of the user who withdrew.
     * @param amount The amount of tokens withdrawn.
     */
    event Withdrawn(address indexed user, uint256 amount);

    /**
     * @dev Emitted when rewards are claimed.
     * @param user The address of the user who claimed rewards.
     * @param amount The amount of rewards claimed.
     */
    event RewardsClaimed(address indexed user, uint256 amount);

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
     * @dev Thrown when the staking amount is zero.
     */
    error ZeroStakingAmount();

    /**
     * @dev Thrown when the withdrawal amount exceeds the staked balance.
     */
    error InsufficientStakedBalance(uint256 available, uint256 requested);

    /**
     * @dev Thrown when there are no rewards to claim.
     */
    error NoRewardsToClaim();

    /**
     * @dev Stakes `amount` of tokens into the pool.
     * @param amount The amount of tokens to stake.
     */
    function stake(uint256 amount) external;

    /**
     * @dev Withdraws `amount` of staked tokens from the pool.
     * @param amount The amount of tokens to withdraw.
     */
    function withdraw(uint256 amount) external;

    /**
     * @dev Claims accumulated rewards.
     */
    function claimRewards() external;

    /**
     * @dev Returns the amount of tokens staked by `user`.
     * @param user The address of the user.
     * @return stakedAmount The amount of tokens staked by the user.
     */
    function stakedBalanceOf(address user) external view returns (uint256 stakedAmount);

    /**
     * @dev Returns the amount of pending rewards for `user`.
     * @param user The address of the user.
     * @return rewardsAmount The amount of pending rewards for the user.
     */
    function pendingRewards(address user) external view returns (uint256 rewardsAmount);
}