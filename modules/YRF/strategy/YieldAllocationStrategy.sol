// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IYieldAllocationStrategy
 * @dev interface for the YieldAllocationStrategy contract.
 */
interface IYieldAllocationStrategy {
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
     * @dev Emitted when a new yield allocation strategy is registered.
     * @param strategyId The ID of the registered strategy.
     * @param name The name of the strategy.
     * @param description A description of the strategy.
     * @param isActive Whether the strategy is active upon registration.
     */
    event AllocationStrategyRegistered(uint256 strategyId, string name, string description, bool isActive);

    /**
     * @dev Emitted when an existing yield allocation strategy is updated.
     * @param strategyId The ID of the updated strategy.
     * @param newName The new name of the strategy.
     * @param newDescription The new description of the strategy.
     */
    event AllocationStrategyUpdated(uint256 strategyId, string newName, string newDescription);

    /**
     * @dev Emitted when a yield allocation strategy's active status is changed.
     * @param strategyId The ID of the strategy.
     * @param newStatus The new active status (true for active, false for inactive).
     */
    event AllocationStrategyStatusChanged(uint256 strategyId, bool newStatus);

    /**
     * @dev Registers a new yield allocation strategy.
     * @param name The name of the strategy (e.g., "Staking Pool Rebalancing", "LP Farm Allocation").
     * @param description A detailed description of the strategy.
     * @param isActive Initial active status of the strategy.
     * @return The unique ID assigned to the registered strategy.
     */
    function registerAllocationStrategy(string calldata name, string calldata description, bool isActive) external returns (uint256);

    /**
     * @dev Updates the details of an existing yield allocation strategy.
     * @param strategyId The ID of the strategy to update.
     * @param newName The new name for the strategy.
     * @param newDescription The new description for the strategy.
     */
    function updateAllocationStrategy(uint256 strategyId, string calldata newName, string calldata newDescription) external;

    /**
     * @dev Changes the active status of a yield allocation strategy.
     * @param strategyId The ID of the strategy.
     * @param newStatus The new active status (true to activate, false to deactivate).
     */
    function setAllocationStrategyStatus(uint256 strategyId, bool newStatus) external;

    /**
     * @dev Retrieves the details of a specific yield allocation strategy.
     * @param strategyId The ID of the strategy.
     * @return name The name of the strategy.
     * @return description The description of the strategy.
     * @return isActive The active status of the strategy.
     */
    function getAllocationStrategyDetails(uint256 strategyId) external view returns (string memory name, string memory description, bool isActive);

    /**
     * @dev Retrieves a list of all registered allocation strategy IDs.
     * @return An array of all strategy IDs.
     */
    function getAllAllocationStrategyIds() external view returns (uint256[] memory);

    /**
     * @dev Retrieves a list of active allocation strategy IDs.
     * @return An array of active strategy IDs.
     */
    function getActiveAllocationStrategyIds() external view returns (uint256[] memory);
}

/**
 * @title YieldAllocationStrategy
 * @dev Manages and tracks various yield allocation strategies within the DAO.
 *      Allows for registration, updating, and status management of different allocation strategies.
 */
contract YieldAllocationStrategy is IYieldAllocationStrategy {
    // State variables
    address public immutable i_owner;
    uint256 private s_nextStrategyId;

    struct AllocationStrategy {
        string name;
        string description;
        bool isActive;
    }

    mapping(uint256 => AllocationStrategy) private s_allocationStrategies;
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
     * @inheritdoc IYieldAllocationStrategy
     */
    function registerAllocationStrategy(string calldata name, string calldata description, bool isActive) external onlyOwner returns (uint256) {
        uint256 strategyId = s_nextStrategyId++;
        s_allocationStrategies[strategyId] = AllocationStrategy(name, description, isActive);
        s_allStrategyIds.push(strategyId);
        emit AllocationStrategyRegistered(strategyId, name, description, isActive);
        return strategyId;
    }

    /**
     * @inheritdoc IYieldAllocationStrategy
     */
    function updateAllocationStrategy(uint256 strategyId, string calldata newName, string calldata newDescription) external onlyOwner {
        AllocationStrategy storage strategy = s_allocationStrategies[strategyId];
        if (bytes(strategy.name).length == 0) {
            revert StrategyNotFound(strategyId);
        }
        strategy.name = newName;
        strategy.description = newDescription;
        emit AllocationStrategyUpdated(strategyId, newName, newDescription);
    }

    /**
     * @inheritdoc IYieldAllocationStrategy
     */
    function setAllocationStrategyStatus(uint256 strategyId, bool newStatus) external onlyOwner {
        AllocationStrategy storage strategy = s_allocationStrategies[strategyId];
        if (bytes(strategy.name).length == 0) {
            revert StrategyNotFound(strategyId);
        }
        if (strategy.isActive != newStatus) {
            strategy.isActive = newStatus;
            emit AllocationStrategyStatusChanged(strategyId, newStatus);
        }
    }

    /**
     * @inheritdoc IYieldAllocationStrategy
     */
    function getAllocationStrategyDetails(uint256 strategyId) external view returns (string memory name, string memory description, bool isActive) {
        AllocationStrategy storage strategy = s_allocationStrategies[strategyId];
        if (bytes(strategy.name).length == 0) {
            revert StrategyNotFound(strategyId);
        }
        return (strategy.name, strategy.description, strategy.isActive);
    }

    /**
     * @inheritdoc IYieldAllocationStrategy
     */
    function getAllAllocationStrategyIds() external view returns (uint256[] memory) {
        return s_allStrategyIds;
    }

    /**
     * @inheritdoc IYieldAllocationStrategy
     */
    function getActiveAllocationStrategyIds() external view returns (uint256[] memory) {
        uint256[] memory activeIds = new uint256[](s_allStrategyIds.length);
        uint256 count = 0;
        for (uint256 i = 0; i < s_allStrategyIds.length; i++) {
            uint256 strategyId = s_allStrategyIds[i];
            if (s_allocationStrategies[strategyId].isActive) {
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