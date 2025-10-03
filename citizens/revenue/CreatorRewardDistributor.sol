// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface CreatorRewardDistributor {
    /**
     * @dev Emitted when rewards are distributed to a creator.
     * @param creatorId The unique ID of the creator.
     * @param amount The amount of rewards distributed.
     * @param currency The currency of the rewards.
     */
    event RewardsDistributed(bytes32 indexed creatorId, uint256 amount, address indexed currency);

    /**
     * @dev Emitted when reward rules are updated.
     * @param ruleId The ID of the updated rule.
     * @param ruleHash A hash of the new rule definition.
     */
    event RewardRuleUpdated(bytes32 indexed ruleId, bytes32 ruleHash);

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
     * @dev Thrown when the specified creator is not found.
     */
    error CreatorNotFound(bytes32 creatorId);

    /**
     * @dev Thrown when reward distribution fails.
     */
    error DistributionFailed(bytes32 creatorId, string reason);

    /**
     * @dev Distributes rewards to a specific creator based on predefined rules.
     * @param creatorId The unique ID of the creator to reward.
     * @param amount The amount of rewards to distribute.
     * @param currency The address of the ERC-20 token for rewards.
     */
    function distributeRewards(bytes32 creatorId, uint256 amount, address currency) external;

    /**
     * @dev Updates the rules for reward distribution.
     * @param ruleId The unique ID of the rule to update.
     * @param ruleDefinition The new definition of the reward rule.
     */
    function updateRewardRule(bytes32 ruleId, bytes calldata ruleDefinition) external;

    /**
     * @dev Retrieves the total accumulated rewards for a creator.
     * @param creatorId The unique ID of the creator.
     * @param currency The currency to check.
     * @return totalRewards The total rewards accumulated.
     */
    function getCreatorRewards(bytes32 creatorId, address currency) external view returns (uint256 totalRewards);
}