// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IYieldReportingStrategy
 * @dev interface for the YieldReportingStrategy contract.
 */
interface IYieldReportingStrategy {
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
     * @dev Emitted when a new yield reporting strategy is registered.
     * @param strategyId The ID of the registered strategy.
     * @param name The name of the strategy.
     * @param description A description of the strategy.
     * @param isActive Whether the strategy is active upon registration.
     */
    event ReportingStrategyRegistered(uint256 strategyId, string name, string description, bool isActive);

    /**
     * @dev Emitted when an existing yield reporting strategy is updated.
     * @param strategyId The ID of the updated strategy.
     * @param newName The new name of the strategy.
     * @param newDescription The new description of the strategy.
     */
    event ReportingStrategyUpdated(uint256 strategyId, string newName, string newDescription);

    /**
     * @dev Emitted when a yield reporting strategy's active status is changed.
     * @param strategyId The ID of the strategy.
     * @param newStatus The new active status (true for active, false for inactive).
     */
    event ReportingStrategyStatusChanged(uint256 strategyId, bool newStatus);

    /**
     * @dev Registers a new yield reporting strategy.
     * @param name The name of the strategy (e.g., "Daily Yield Report", "Monthly Performance Summary").
     * @param description A detailed description of the strategy.
     * @param isActive Initial active status of the strategy.
     * @return The unique ID assigned to the registered strategy.
     */
    function registerReportingStrategy(string calldata name, string calldata description, bool isActive) external returns (uint256);

    /**
     * @dev Updates the details of an existing yield reporting strategy.
     * @param strategyId The ID of the strategy to update.
     * @param newName The new name for the strategy.
     * @param newDescription The new description for the strategy.
     */
    function updateReportingStrategy(uint256 strategyId, string calldata newName, string calldata newDescription) external;

    /**
     * @dev Changes the active status of a yield reporting strategy.
     * @param strategyId The ID of the strategy.
     * @param newStatus The new active status (true to activate, false to deactivate).
     */
    function setReportingStrategyStatus(uint256 strategyId, bool newStatus) external;

    /**
     * @dev Retrieves the details of a specific yield reporting strategy.
     * @param strategyId The ID of the strategy.
     * @return name The name of the strategy.
     * @return description The description of the strategy.
     * @return isActive The active status of the strategy.
     */
    function getReportingStrategyDetails(uint256 strategyId) external view returns (string memory name, string memory description, bool isActive);

    /**
     * @dev Retrieves a list of all registered reporting strategy IDs.
     * @return An array of all strategy IDs.
     */
    function getAllReportingStrategyIds() external view returns (uint256[] memory);

    /**
     * @dev Retrieves a list of active reporting strategy IDs.
     * @return An array of active strategy IDs.
     */
    function getActiveReportingStrategyIds() external view returns (uint256[] memory);
}

/**
 * @title YieldReportingStrategy
 * @dev Manages and tracks various yield reporting strategies within the DAO.
 *      Allows for registration, updating, and status management of different reporting strategies.
 */
contract YieldReportingStrategy is IYieldReportingStrategy {
    // State variables
    address public immutable i_owner;
    uint256 private s_nextStrategyId;

    struct ReportingStrategy {
        string name;
        string description;
        bool isActive;
    }

    mapping(uint256 => ReportingStrategy) private s_reportingStrategies;
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
     * @inheritdoc IYieldReportingStrategy
     */
    function registerReportingStrategy(string calldata name, string calldata description, bool isActive) external onlyOwner returns (uint256) {
        uint256 strategyId = s_nextStrategyId++;
        s_reportingStrategies[strategyId] = ReportingStrategy(name, description, isActive);
        s_allStrategyIds.push(strategyId);
        emit ReportingStrategyRegistered(strategyId, name, description, isActive);
        return strategyId;
    }

    /**
     * @inheritdoc IYieldReportingStrategy
     */
    function updateReportingStrategy(uint256 strategyId, string calldata newName, string calldata newDescription) external onlyOwner {
        ReportingStrategy storage strategy = s_reportingStrategies[strategyId];
        if (bytes(strategy.name).length == 0) {
            revert StrategyNotFound(strategyId);
        }
        strategy.name = newName;
        strategy.description = newDescription;
        emit ReportingStrategyUpdated(strategyId, newName, newDescription);
    }

    /**
     * @inheritdoc IYieldReportingStrategy
     */
    function setReportingStrategyStatus(uint256 strategyId, bool newStatus) external onlyOwner {
        ReportingStrategy storage strategy = s_reportingStrategies[strategyId];
        if (bytes(strategy.name).length == 0) {
            revert StrategyNotFound(strategyId);
        }
        if (strategy.isActive != newStatus) {
            strategy.isActive = newStatus;
            emit ReportingStrategyStatusChanged(strategyId, newStatus);
        }
    }

    /**
     * @inheritdoc IYieldReportingStrategy
     */
    function getReportingStrategyDetails(uint256 strategyId) external view returns (string memory name, string memory description, bool isActive) {
        ReportingStrategy storage strategy = s_reportingStrategies[strategyId];
        if (bytes(strategy.name).length == 0) {
            revert StrategyNotFound(strategyId);
        }
        return (strategy.name, strategy.description, strategy.isActive);
    }

    /**
     * @inheritdoc IYieldReportingStrategy
     */
    function getAllReportingStrategyIds() external view returns (uint256[] memory) {
        return s_allStrategyIds;
    }

    /**
     * @inheritdoc IYieldReportingStrategy
     */
    function getActiveReportingStrategyIds() external view returns (uint256[] memory) {
        uint256[] memory activeIds = new uint256[](s_allStrategyIds.length);
        uint256 count = 0;
        for (uint256 i = 0; i < s_allStrategyIds.length; i++) {
            uint256 strategyId = s_allStrategyIds[i];
            if (s_reportingStrategies[strategyId].isActive) {
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