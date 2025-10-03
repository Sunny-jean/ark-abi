// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IYieldRiskStrategy
 * @dev interface for the YieldRiskStrategy contract.
 */
interface IYieldRiskStrategy {
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
     * @dev Emitted when a new yield risk strategy is registered.
     * @param strategyId The ID of the registered strategy.
     * @param name The name of the strategy.
     * @param description A description of the strategy.
     * @param isActive Whether the strategy is active upon registration.
     */
    event RiskStrategyRegistered(uint256 strategyId, string name, string description, bool isActive);

    /**
     * @dev Emitted when an existing yield risk strategy is updated.
     * @param strategyId The ID of the updated strategy.
     * @param newName The new name of the strategy.
     * @param newDescription The new description of the strategy.
     */
    event RiskStrategyUpdated(uint256 strategyId, string newName, string newDescription);

    /**
     * @dev Emitted when a yield risk strategy's active status is changed.
     * @param strategyId The ID of the strategy.
     * @param newStatus The new active status (true for active, false for inactive).
     */
    event RiskStrategyStatusChanged(uint256 strategyId, bool newStatus);

    /**
     * @dev Registers a new yield risk management strategy.
     * @param name The name of the strategy (e.g., "Impermanent Loss Hedging", "Liquidation Protection").
     * @param description A detailed description of the strategy.
     * @param isActive Initial active status of the strategy.
     * @return The unique ID assigned to the registered strategy.
     */
    function registerRiskStrategy(string calldata name, string calldata description, bool isActive) external returns (uint256);

    /**
     * @dev Updates the details of an existing yield risk strategy.
     * @param strategyId The ID of the strategy to update.
     * @param newName The new name for the strategy.
     * @param newDescription The new description for the strategy.
     */
    function updateRiskStrategy(uint256 strategyId, string calldata newName, string calldata newDescription) external;

    /**
     * @dev Changes the active status of a yield risk strategy.
     * @param strategyId The ID of the strategy.
     * @param newStatus The new active status (true to activate, false to deactivate).
     */
    function setRiskStrategyStatus(uint256 strategyId, bool newStatus) external;

    /**
     * @dev Retrieves the details of a specific yield risk strategy.
     * @param strategyId The ID of the strategy.
     * @return name The name of the strategy.
     * @return description The description of the strategy.
     * @return isActive The active status of the strategy.
     */
    function getRiskStrategyDetails(uint256 strategyId) external view returns (string memory name, string memory description, bool isActive);

    /**
     * @dev Retrieves a list of all registered risk strategy IDs.
     * @return An array of all strategy IDs.
     */
    function getAllRiskStrategyIds() external view returns (uint256[] memory);

    /**
     * @dev Retrieves a list of active risk strategy IDs.
     * @return An array of active strategy IDs.
     */
    function getActiveRiskStrategyIds() external view returns (uint256[] memory);
}

/**
 * @title YieldRiskStrategy
 * @dev Manages and tracks various yield risk management strategies within the DAO.
 *      Allows for registration, updating, and status management of different risk strategies.
 */
contract YieldRiskStrategy is IYieldRiskStrategy {
    // State variables
    address public immutable i_owner;
    uint256 private s_nextStrategyId;

    struct RiskStrategy {
        string name;
        string description;
        bool isActive;
    }

    mapping(uint256 => RiskStrategy) private s_riskStrategies;
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
     * @inheritdoc IYieldRiskStrategy
     */
    function registerRiskStrategy(string calldata name, string calldata description, bool isActive) external onlyOwner returns (uint256) {
        uint256 strategyId = s_nextStrategyId++;
        s_riskStrategies[strategyId] = RiskStrategy(name, description, isActive);
        s_allStrategyIds.push(strategyId);
        emit RiskStrategyRegistered(strategyId, name, description, isActive);
        return strategyId;
    }

    /**
     * @inheritdoc IYieldRiskStrategy
     */
    function updateRiskStrategy(uint256 strategyId, string calldata newName, string calldata newDescription) external onlyOwner {
        RiskStrategy storage strategy = s_riskStrategies[strategyId];
        if (bytes(strategy.name).length == 0) {
            revert StrategyNotFound(strategyId);
        }
        strategy.name = newName;
        strategy.description = newDescription;
        emit RiskStrategyUpdated(strategyId, newName, newDescription);
    }

    /**
     * @inheritdoc IYieldRiskStrategy
     */
    function setRiskStrategyStatus(uint256 strategyId, bool newStatus) external onlyOwner {
        RiskStrategy storage strategy = s_riskStrategies[strategyId];
        if (bytes(strategy.name).length == 0) {
            revert StrategyNotFound(strategyId);
        }
        if (strategy.isActive != newStatus) {
            strategy.isActive = newStatus;
            emit RiskStrategyStatusChanged(strategyId, newStatus);
        }
    }

    /**
     * @inheritdoc IYieldRiskStrategy
     */
    function getRiskStrategyDetails(uint256 strategyId) external view returns (string memory name, string memory description, bool isActive) {
        RiskStrategy storage strategy = s_riskStrategies[strategyId];
        if (bytes(strategy.name).length == 0) {
            revert StrategyNotFound(strategyId);
        }
        return (strategy.name, strategy.description, strategy.isActive);
    }

    /**
     * @inheritdoc IYieldRiskStrategy
     */
    function getAllRiskStrategyIds() external view returns (uint256[] memory) {
        return s_allStrategyIds;
    }

    /**
     * @inheritdoc IYieldRiskStrategy
     */
    function getActiveRiskStrategyIds() external view returns (uint256[] memory) {
        uint256[] memory activeIds = new uint256[](s_allStrategyIds.length);
        uint256 count = 0;
        for (uint256 i = 0; i < s_allStrategyIds.length; i++) {
            uint256 strategyId = s_allStrategyIds[i];
            if (s_riskStrategies[strategyId].isActive) {
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