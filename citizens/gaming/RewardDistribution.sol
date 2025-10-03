// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface RewardDistribution {
    /**
     * @dev Emitted when rewards are distributed to a player.
     * @param player The address of the player who received rewards.
     * @param amount The amount of rewards distributed.
     * @param rewardType The type of reward (e.g., token, NFT).
     */
    event RewardsDistributed(address indexed player, uint256 amount, string rewardType);

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
     * @dev Thrown when there are insufficient rewards available for distribution.
     */
    error InsufficientRewards(uint256 available, uint256 requested);

    /**
     * @dev Distributes rewards to a player.
     * @param player The address of the player to receive rewards.
     * @param amount The amount of rewards to distribute.
     * @param rewardType The type of reward (e.g., "ERC20", "ERC721").
     */
    function distributeRewards(address player, uint256 amount, string calldata rewardType) external;

    /**
     * @dev Returns the total amount of rewards available for distribution for a given type.
     * @param rewardType The type of reward.
     * @return availableRewards The total available rewards.
     */
    function getAvailableRewards(string calldata rewardType) external view returns (uint256 availableRewards);
}