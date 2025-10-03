// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IYieldConditionEvaluator
 * @dev interface for the YieldConditionEvaluator contract.
 */
interface IYieldConditionEvaluator {
    /**
     * @dev Error indicating that the caller is not authorized to perform the action.
     */
    error Unauthorized();

    /**
     * @dev Error indicating that an invalid condition ID was provided.
     * @param conditionId The ID of the invalid condition.
     */
    error InvalidCondition(uint256 conditionId);

    /**
     * @dev Emitted when a new yield condition is registered.
     * @param conditionId The ID of the new condition.
     * @param description A description of the condition.
     * @param conditionType The type of condition (e.g., "PriceThreshold", "TVLChange").
     */
    event YieldConditionRegistered(uint256 conditionId, string description, string conditionType);

    /**
     * @dev Emitted when a yield condition is updated.
     * @param conditionId The ID of the updated condition.
     * @param newDescription The new description of the condition.
     */
    event YieldConditionUpdated(uint256 conditionId, string newDescription);

    /**
     * @dev Emitted when a yield condition is met.
     * @param conditionId The ID of the met condition.
     * @param timestamp The timestamp when the condition was met.
     */
    event YieldConditionMet(uint256 conditionId, uint256 timestamp);

    /**
     * @dev Registers a new yield-related condition for evaluation.
     * @param description A description of the condition.
     * @param conditionType The type of condition (e.g., "PriceThreshold", "TVLChange", "TimeElapsed").
     * @return The ID of the newly registered condition.
     */
    function registerYieldCondition(string calldata description, string calldata conditionType) external returns (uint256);

    /**
     * @dev Updates an existing yield condition.
     * @param conditionId The ID of the condition to update.
     * @param newDescription The new description for the condition.
     */
    function updateYieldCondition(uint256 conditionId, string calldata newDescription) external;

    /**
     * @dev Evaluates a specific yield condition.
     *      This function would typically be called by an off-chain oracle or another contract
     *      to check if a condition has been met.
     * @param conditionId The ID of the condition to evaluate.
     * @param data Additional data required for evaluation (e.g., current price, TVL).
     * @return True if the condition is met, false otherwise.
     */
    function evaluateYieldCondition(uint256 conditionId, bytes calldata data) external returns (bool);

    /**
     * @dev Retrieves the details of a yield condition.
     * @param conditionId The ID of the condition.
     * @return description The description of the condition.
     * @return conditionType The type of the condition.
     */
    function getYieldCondition(uint256 conditionId) external view returns (string memory description, string memory conditionType);
}

/**
 * @title YieldConditionEvaluator
 * @dev Contract for evaluating various conditions related to yield management.
 *      Allows authorized roles to register, update, and evaluate conditions
 *      that might trigger automated actions or inform decision-making processes.
 */
contract YieldConditionEvaluator is IYieldConditionEvaluator {
    // State variables
    address public immutable i_owner;
    uint256 private s_nextConditionId;

    struct YieldCondition {
        string description;
        string conditionType;
    }

    mapping(uint256 => YieldCondition) private s_yieldConditions;

    // Constructor
    constructor() {
        i_owner = msg.sender;
        s_nextConditionId = 1;
    }

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Unauthorized();
        }
        _;
    }

    /**
     * @inheritdoc IYieldConditionEvaluator
     */
    function registerYieldCondition(string calldata description, string calldata conditionType) external onlyOwner returns (uint256) {
        uint256 conditionId = s_nextConditionId++;
        s_yieldConditions[conditionId] = YieldCondition(description, conditionType);
        emit YieldConditionRegistered(conditionId, description, conditionType);
        return conditionId;
    }

    /**
     * @inheritdoc IYieldConditionEvaluator
     */
    function updateYieldCondition(uint256 conditionId, string calldata newDescription) external onlyOwner {
        YieldCondition storage condition = s_yieldConditions[conditionId];
        if (bytes(condition.description).length == 0) {
            revert InvalidCondition(conditionId);
        }
        condition.description = newDescription;
        emit YieldConditionUpdated(conditionId, newDescription);
    }

    /**
     * @inheritdoc IYieldConditionEvaluator
     */
    function evaluateYieldCondition(uint256 conditionId, bytes calldata data) external returns (bool) {
        // based on its type and the provided data.
        YieldCondition storage condition = s_yieldConditions[conditionId];
        if (bytes(condition.description).length == 0) {
            revert InvalidCondition(conditionId);
        }

        // Example: If conditionType is "PriceThreshold", 'data' might contain the current price.
        emit YieldConditionMet(conditionId, block.timestamp);
        return true;
    }

    /**
     * @inheritdoc IYieldConditionEvaluator
     */
    function getYieldCondition(uint256 conditionId) external view returns (string memory description, string memory conditionType) {
        YieldCondition storage condition = s_yieldConditions[conditionId];
        return (condition.description, condition.conditionType);
    }
}