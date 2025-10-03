// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IYieldForecastingStrategy
 * @dev interface for the YieldForecastingStrategy contract.
 */
interface IYieldForecastingStrategy {
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
     * @dev Emitted when a new yield forecasting strategy is registered.
     * @param strategyId The ID of the registered strategy.
     * @param name The name of the strategy.
     * @param description A description of the strategy.
     * @param isActive Whether the strategy is active upon registration.
     */
    event ForecastingStrategyRegistered(uint256 strategyId, string name, string description, bool isActive);

    /**
     * @dev Emitted when an existing yield forecasting strategy is updated.
     * @param strategyId The ID of the updated strategy.
     * @param newName The new name of the strategy.
     * @param newDescription The new description of the strategy.
     */
    event ForecastingStrategyUpdated(uint256 strategyId, string newName, string newDescription);

    /**
     * @dev Emitted when a yield forecasting strategy's active status is changed.
     * @param strategyId The ID of the strategy.
     * @param newStatus The new active status (true for active, false for inactive).
     */
    event ForecastingStrategyStatusChanged(uint256 strategyId, bool newStatus);

    /**
     * @dev Registers a new yield forecasting strategy.
     * @param name The name of the strategy (e.g., "Time Series Analysis", "Machine Learning Model").
     * @param description A detailed description of the strategy.
     * @param isActive Initial active status of the strategy.
     * @return The unique ID assigned to the registered strategy.
     */
    function registerForecastingStrategy(string calldata name, string calldata description, bool isActive) external returns (uint256);

    /**
     * @dev Updates the details of an existing yield forecasting strategy.
     * @param strategyId The ID of the strategy to update.
     * @param newName The new name for the strategy.
     * @param newDescription The new description for the strategy.
     */
    function updateForecastingStrategy(uint256 strategyId, string calldata newName, string calldata newDescription) external;

    /**
     * @dev Changes the active status of a yield forecasting strategy.
     * @param strategyId The ID of the strategy.
     * @param newStatus The new active status (true to activate, false to deactivate).
     */
    function setForecastingStrategyStatus(uint256 strategyId, bool newStatus) external;

    /**
     * @dev Retrieves the details of a specific yield forecasting strategy.
     * @param strategyId The ID of the strategy.
     * @return name The name of the strategy.
     * @return description The description of the strategy.
     * @return isActive The active status of the strategy.
     */
    function getForecastingStrategyDetails(uint256 strategyId) external view returns (string memory name, string memory description, bool isActive);

    /**
     * @dev Retrieves a list of all registered forecasting strategy IDs.
     * @return An array of all strategy IDs.
     */
    function getAllForecastingStrategyIds() external view returns (uint256[] memory);

    /**
     * @dev Retrieves a list of active forecasting strategy IDs.
     * @return An array of active strategy IDs.
     */
    function getActiveForecastingStrategyIds() external view returns (uint256[] memory);
}

/**
 * @title YieldForecastingStrategy
 * @dev Manages and tracks various yield forecasting strategies within the DAO.
 *      Allows for registration, updating, and status management of different forecasting strategies.
 */
contract YieldForecastingStrategy is IYieldForecastingStrategy {
    // State variables
    address public immutable i_owner;
    uint256 private s_nextStrategyId;

    struct ForecastingStrategy {
        string name;
        string description;
        bool isActive;
    }

    mapping(uint256 => ForecastingStrategy) private s_forecastingStrategies;
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
     * @inheritdoc IYieldForecastingStrategy
     */
    function registerForecastingStrategy(string calldata name, string calldata description, bool isActive) external onlyOwner returns (uint256) {
        uint256 strategyId = s_nextStrategyId++;
        s_forecastingStrategies[strategyId] = ForecastingStrategy(name, description, isActive);
        s_allStrategyIds.push(strategyId);
        emit ForecastingStrategyRegistered(strategyId, name, description, isActive);
        return strategyId;
    }

    /**
     * @inheritdoc IYieldForecastingStrategy
     */
    function updateForecastingStrategy(uint256 strategyId, string calldata newName, string calldata newDescription) external onlyOwner {
        ForecastingStrategy storage strategy = s_forecastingStrategies[strategyId];
        if (bytes(strategy.name).length == 0) {
            revert StrategyNotFound(strategyId);
        }
        strategy.name = newName;
        strategy.description = newDescription;
        emit ForecastingStrategyUpdated(strategyId, newName, newDescription);
    }

    /**
     * @inheritdoc IYieldForecastingStrategy
     */
    function setForecastingStrategyStatus(uint256 strategyId, bool newStatus) external onlyOwner {
        ForecastingStrategy storage strategy = s_forecastingStrategies[strategyId];
        if (bytes(strategy.name).length == 0) {
            revert StrategyNotFound(strategyId);
        }
        if (strategy.isActive != newStatus) {
            strategy.isActive = newStatus;
            emit ForecastingStrategyStatusChanged(strategyId, newStatus);
        }
    }

    /**
     * @inheritdoc IYieldForecastingStrategy
     */
    function getForecastingStrategyDetails(uint256 strategyId) external view returns (string memory name, string memory description, bool isActive) {
        ForecastingStrategy storage strategy = s_forecastingStrategies[strategyId];
        if (bytes(strategy.name).length == 0) {
            revert StrategyNotFound(strategyId);
        }
        return (strategy.name, strategy.description, strategy.isActive);
    }

    /**
     * @inheritdoc IYieldForecastingStrategy
     */
    function getAllForecastingStrategyIds() external view returns (uint256[] memory) {
        return s_allStrategyIds;
    }

    /**
     * @inheritdoc IYieldForecastingStrategy
     */
    function getActiveForecastingStrategyIds() external view returns (uint256[] memory) {
        uint256[] memory activeIds = new uint256[](s_allStrategyIds.length);
        uint256 count = 0;
        for (uint256 i = 0; i < s_allStrategyIds.length; i++) {
            uint256 strategyId = s_allStrategyIds[i];
            if (s_forecastingStrategies[strategyId].isActive) {
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