// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface TrainingRewardDistributor {
    /**
     * @dev Emitted when training rewards are distributed to a user.
     * @param user The address of the user.
     * @param rewardAmount The amount of rewards distributed.
     * @param rewardType The type of training activity that earned the reward.
     */
    event TrainingRewardsDistributed(address indexed user, uint256 rewardAmount, string indexed rewardType);

    /**
     * @dev Emitted when a training reward rule is updated.
     * @param ruleId The ID of the updated rule.
     * @param ruleHash A hash of the new rule definition.
     */
    event TrainingRewardRuleUpdated(bytes32 indexed ruleId, bytes32 ruleHash);

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
     * @dev Distributes rewards to a user based on their training activities.
     * @param user The address of the user to reward.
     * @param activityType The type of training activity (e.g., "course_completion", "skill_mastery").
     * @param activityData Additional data related to the activity.
     */
    function distributeTrainingRewards(address user, string calldata activityType, bytes calldata activityData) external;

    /**
     * @dev Updates the rules for training reward distribution.
     * @param ruleId The unique ID of the rule to update.
     * @param ruleDefinition The new definition of the training reward rule.
     */
    function updateTrainingRewardRule(bytes32 ruleId, bytes calldata ruleDefinition) external;

    /**
     * @dev Retrieves the total training rewards earned by a user.
     * @param user The address of the user.
     * @return totalRewards The total rewards earned.
     */
    function getTotalTrainingRewards(address user) external view returns (uint256 totalRewards);
}