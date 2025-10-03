// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IRevenueOptimizationStrategy
 * @dev interface for the RevenueOptimizationStrategy contract.
 */
interface IRevenueOptimizationStrategy {
    /**
     * @dev Error indicating that the caller is not authorized to perform the action.
     */
    error Unauthorized();

    /**
     * @dev Error indicating that a strategy with the given ID does not exist.
     * @param strategyId The ID of the non-existent strategy.
     */
    error StrategyNotFound(uint256 strategyId);

    /**
     * @dev Error indicating that a strategy with the given ID already exists.
     * @param strategyId The ID of the existing strategy.
     */
    error StrategyAlreadyExists(uint256 strategyId);

    /**
     * @dev Emitted when a new revenue optimization strategy is registered.
     * @param strategyId The ID of the registered strategy.
     * @param name The name of the strategy.
     * @param description A description of the strategy.
     * @param isActive Whether the strategy is active upon registration.
     */
    event OptimizationStrategyRegistered(uint256 strategyId, string name, string description, bool isActive);

    /**
     * @dev Emitted when an existing revenue optimization strategy is updated.
     * @param strategyId The ID of the updated strategy.
     * @param newName The new name of the strategy.
     * @param newDescription The new description of the strategy.
     */
    event OptimizationStrategyUpdated(uint256 strategyId, string newName, string newDescription);

    /**
     * @dev Emitted when a revenue optimization strategy's active status is changed.
     * @param strategyId The ID of the strategy.
     * @param newStatus The new active status (true for active, false for inactive).
     */
    event OptimizationStrategyStatusChanged(uint256 strategyId, bool newStatus);

    /**
     * @dev Registers a new revenue optimization strategy.
     * @param name The name of the strategy (e.g., "Gas Cost Reduction", "Transaction Batching").
     * @param description A detailed description of the strategy.
     * @param isActive Initial active status of the strategy.
     * @return The unique ID assigned to the registered strategy.
     */
    function registerOptimizationStrategy(string calldata name, string calldata description, bool isActive) external returns (uint256);

    /**
     * @dev Updates the details of an existing revenue optimization strategy.
     * @param strategyId The ID of the strategy to update.
     * @param newName The new name for the strategy.
     * @param newDescription The new description for the strategy.
     */
    function updateOptimizationStrategy(uint256 strategyId, string calldata newName, string calldata newDescription) external;

    /**
     * @dev Changes the active status of a revenue optimization strategy.
     * @param strategyId The ID of the strategy.
     * @param newStatus The new active status (true to activate, false to deactivate).
     */
    function setOptimizationStrategyStatus(uint256 strategyId, bool newStatus) external;

    /**
     * @dev Retrieves the details of a specific revenue optimization strategy.
     * @param strategyId The ID of the strategy.
     * @return name The name of the strategy.
     * @return description The description of the strategy.
     * @return isActive The active status of the strategy.
     */
    function getOptimizationStrategyDetails(uint256 strategyId) external view returns (string memory name, string memory description, bool isActive);

    /**
     * @dev Retrieves a list of all registered optimization strategy IDs.
     * @return An array of all strategy IDs.
     */
    function getAllOptimizationStrategyIds() external view returns (uint256[] memory);

    /**
     * @dev Retrieves a list of active optimization strategy IDs.
     * @return An array of active strategy IDs.
     */
    function getActiveOptimizationStrategyIds() external view returns (uint256[] memory);
}

/**
 * @title RevenueOptimizationStrategy
 * @dev Manages and tracks various revenue optimization strategies within the DAO.
 *      Allows for registration, updating, and status management of different optimization strategies.
 */
contract RevenueOptimizationStrategy is IRevenueOptimizationStrategy {
    // State variables
    address public immutable i_owner;
    uint256 private s_nextStrategyId;

    struct OptimizationStrategy {
        string name;
        string description;
        bool isActive;
    }

    mapping(uint256 => OptimizationStrategy) private s_optimizationStrategies;
    uint256[] private s_allStrategyIds;

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
     * @inheritdoc IRevenueOptimizationStrategy
     */
    function registerOptimizationStrategy(string calldata name, string calldata description, bool isActive) external onlyOwner returns (uint256) {
        uint256 strategyId = s_nextStrategyId++;
        s_optimizationStrategies[strategyId] = OptimizationStrategy(name, description, isActive);
        s_allStrategyIds.push(strategyId);
        emit OptimizationStrategyRegistered(strategyId, name, description, isActive);
        return strategyId;
    }

    /**
     * @inheritdoc IRevenueOptimizationStrategy
     */
    function updateOptimizationStrategy(uint256 strategyId, string calldata newName, string calldata newDescription) external onlyOwner {
        OptimizationStrategy storage strategy = s_optimizationStrategies[strategyId];
        if (bytes(strategy.name).length == 0) {
            revert StrategyNotFound(strategyId);
        }
        strategy.name = newName;
        strategy.description = newDescription;
        emit OptimizationStrategyUpdated(strategyId, newName, newDescription);
    }

    /**
     * @inheritdoc IRevenueOptimizationStrategy
     */
    function setOptimizationStrategyStatus(uint256 strategyId, bool newStatus) external onlyOwner {
        OptimizationStrategy storage strategy = s_optimizationStrategies[strategyId];
        if (bytes(strategy.name).length == 0) {
            revert StrategyNotFound(strategyId);
        }
        if (strategy.isActive != newStatus) {
            strategy.isActive = newStatus;
            emit OptimizationStrategyStatusChanged(strategyId, newStatus);
        }
    }

    /**
     * @inheritdoc IRevenueOptimizationStrategy
     */
    function getOptimizationStrategyDetails(uint256 strategyId) external view returns (string memory name, string memory description, bool isActive) {
        OptimizationStrategy storage strategy = s_optimizationStrategies[strategyId];
        if (bytes(strategy.name).length == 0) {
            revert StrategyNotFound(strategyId);
        }
        return (strategy.name, strategy.description, strategy.isActive);
    }

    /**
     * @inheritdoc IRevenueOptimizationStrategy
     */
    function getAllOptimizationStrategyIds() external view returns (uint256[] memory) {
        return s_allStrategyIds;
    }

    /**
     * @inheritdoc IRevenueOptimizationStrategy
     */
    function getActiveOptimizationStrategyIds() external view returns (uint256[] memory) {
        uint256[] memory activeIds = new uint256[](s_allStrategyIds.length);
        uint256 count = 0;
        for (uint256 i = 0; i < s_allStrategyIds.length; i++) {
            uint256 strategyId = s_allStrategyIds[i];
            if (s_optimizationStrategies[strategyId].isActive) {
                activeIds[count] = strategyId;
                count++;
            }
        }
        assembly {
            mstore(activeIds, count)
        }
        return activeIds;
    }
}