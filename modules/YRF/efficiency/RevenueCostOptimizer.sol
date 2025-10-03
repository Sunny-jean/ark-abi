// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IRevenueCostOptimizer
 * @dev interface for the RevenueCostOptimizer contract.
 */
interface IRevenueCostOptimizer {
    /**
     * @dev Error indicating that the caller is not authorized to perform the action.
     */
    error Unauthorized();

    /**
     * @dev Error indicating that an invalid cost optimization strategy was provided.
     * @param strategyId The ID of the invalid strategy.
     */
    error InvalidCostOptimizationStrategy(uint256 strategyId);

    /**
     * @dev Emitted when a new cost optimization strategy is added.
     * @param strategyId The ID of the new strategy.
     * @param description A description of the strategy.
     */
    event CostOptimizationStrategyAdded(uint256 strategyId, string description);

    /**
     * @dev Emitted when a cost optimization strategy is updated.
     * @param strategyId The ID of the updated strategy.
     * @param newDescription The new description of the strategy.
     */
    event CostOptimizationStrategyUpdated(uint256 strategyId, string newDescription);

    /**
     * @dev Emitted when a cost is optimized.
     * @param costCategory The category of the cost.
     * @param amount The amount of cost optimized.
     * @param strategyId The ID of the strategy used for optimization.
     */
    event CostOptimized(string indexed costCategory, uint256 amount, uint256 strategyId);

    /**
     * @dev Adds a new revenue cost optimization strategy.
     * @param description A description of the strategy.
     * @return The ID of the newly added strategy.
     */
    function addCostOptimizationStrategy(string calldata description) external returns (uint256);

    /**
     * @dev Updates an existing revenue cost optimization strategy.
     * @param strategyId The ID of the strategy to update.
     * @param newDescription The new description for the strategy.
     */
    function updateCostOptimizationStrategy(uint256 strategyId, string calldata newDescription) external;

    /**
     * @dev Optimizes a specific cost category using a given strategy.
     * @param costCategory The category of the cost to optimize.
     * @param amount The amount of cost to optimize.
     * @param strategyId The ID of the cost optimization strategy to use.
     */
    function optimizeCost(string calldata costCategory, uint256 amount, uint256 strategyId) external;

    /**
     * @dev Retrieves the description of a cost optimization strategy.
     * @param strategyId The ID of the strategy.
     * @return The description of the strategy.
     */
    function getCostOptimizationStrategy(uint256 strategyId) external view returns (string memory);
}

/**
 * @title RevenueCostOptimizer
 * @dev Contract for managing and applying revenue cost optimization strategies.
 *      Allows authorized roles to add, update, and apply various strategies
 *      to minimize operational costs and maximize net revenue.
 */
contract RevenueCostOptimizer is IRevenueCostOptimizer {
    // State variables
    address public immutable i_owner;
    uint256 private s_nextStrategyId;
    mapping(uint256 => string) private s_costOptimizationStrategies;

    // Constructor
    constructor() {
        i_owner = msg.sender;
        s_nextStrategyId = 1;
    }

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Unauthorized();
        }
        _;
    }

    /**
     * @inheritdoc IRevenueCostOptimizer
     */
    function addCostOptimizationStrategy(string calldata description) external onlyOwner returns (uint256) {
        uint256 strategyId = s_nextStrategyId++;
        s_costOptimizationStrategies[strategyId] = description;
        emit CostOptimizationStrategyAdded(strategyId, description);
        return strategyId;
    }

    /**
     * @inheritdoc IRevenueCostOptimizer
     */
    function updateCostOptimizationStrategy(uint256 strategyId, string calldata newDescription) external onlyOwner {
        if (bytes(s_costOptimizationStrategies[strategyId]).length == 0) {
            revert InvalidCostOptimizationStrategy(strategyId);
        }
        s_costOptimizationStrategies[strategyId] = newDescription;
        emit CostOptimizationStrategyUpdated(strategyId, newDescription);
    }

    /**
     * @inheritdoc IRevenueCostOptimizer
     */
    function optimizeCost(string calldata costCategory, uint256 amount, uint256 strategyId) external onlyOwner {
        // In a real scenario, this function would contain logic to apply the cost optimization strategy.
        // This might involve interacting with other contracts, adjusting parameters, etc.
        // we simply emit an event.
        if (bytes(s_costOptimizationStrategies[strategyId]).length == 0) {
            revert InvalidCostOptimizationStrategy(strategyId);
        }
        emit CostOptimized(costCategory, amount, strategyId);
    }

    /**
     * @inheritdoc IRevenueCostOptimizer
     */
    function getCostOptimizationStrategy(uint256 strategyId) external view returns (string memory) {
        return s_costOptimizationStrategies[strategyId];
    }
}