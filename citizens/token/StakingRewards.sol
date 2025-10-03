// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface StakingRewards {
    /**
     * @dev Emitted when tokens are staked.
     */
    event Staked(address indexed user, uint256 amount);

    /**
     * @dev Emitted when staked tokens are withdrawn.
     */
    event Withdrawn(address indexed user, uint256 amount);

    /**
     * @dev Emitted when rewards are claimed.
     */
    event RewardClaimed(address indexed user, uint256 amount);

    /**
     * @dev Emitted when the reward rate is updated.
     */
    event RewardRateUpdated(uint256 newRate);

    /**
     * @dev Error when insufficient funds are available for staking or withdrawal.
     */
    error InsufficientFunds(uint256 requested, uint256 available);

    /**
     * @dev Error when the staking period has not ended.
     */
    error StakingPeriodNotEnded();

    /**
     * @dev Stakes `amount` of tokens.
     * @param amount The amount of tokens to stake.
     */
    function stake(uint256 amount) external;

    /**
     * @dev Withdraws `amount` of staked tokens.
     * @param amount The amount of tokens to withdraw.
     */
    function withdraw(uint256 amount) external;

    /**
     * @dev Claims available rewards for the caller.
     */
    function claimReward() external;

    /**
     * @dev Returns the amount of tokens staked by `account`.
     * @param account The address of the staker.
     * @return The staked amount.
     */
    function stakedBalance(address account) external view returns (uint256);

    /**
     * @dev Returns the amount of rewards available for `account`.
     * @param account The address of the staker.
     * @return The available rewards.
     */
    function earned(address account) external view returns (uint256);

    /**
     * @dev Updates the reward rate. Only callable by authorized addresses.
     * @param newRate The new reward rate.
     */
    function updateRewardRate(uint256 newRate) external;
}