// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface UserEngagementRewards {
    /**
     * @dev Emitted when a user earns engagement rewards.
     * @param user The address of the user.
     * @param rewardAmount The amount of rewards earned.
     * @param rewardType The type of engagement that earned the reward.
     */
    event EngagementRewardEarned(address indexed user, uint256 rewardAmount, string indexed rewardType);

    /**
     * @dev Emitted when an engagement rule is updated.
     * @param ruleId The ID of the updated rule.
     * @param ruleHash A hash of the new rule definition.
     */
    event EngagementRuleUpdated(bytes32 indexed ruleId, bytes32 ruleHash);

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
     * @dev Thrown when the specified user is not found.
     */
    error UserNotFound(address user);

    /**
     * @dev Thrown when reward distribution fails.
     */
    error RewardDistributionFailed(address user, string reason);

    /**
     * @dev Records user engagement and distributes rewards based on predefined rules.
     * @param user The address of the engaging user.
     * @param engagementType The type of engagement (e.g., "module_use", "feedback_submission").
     * @param engagementData Additional data related to the engagement.
     */
    function recordEngagementAndReward(address user, string calldata engagementType, bytes calldata engagementData) external;

    /**
     * @dev Updates the rules for calculating engagement rewards.
     * @param ruleId The unique ID of the rule to update.
     * @param ruleDefinition The new definition of the engagement rule.
     */
    function updateEngagementRule(bytes32 ruleId, bytes calldata ruleDefinition) external;

    /**
     * @dev Retrieves the total engagement rewards earned by a user.
     * @param user The address of the user.
     * @return totalRewards The total rewards earned.
     */
    function getTotalEngagementRewards(address user) external view returns (uint256 totalRewards);
}