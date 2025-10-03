// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IYieldAlertSystem
 * @dev interface for the YieldAlertSystem contract.
 */
interface IYieldAlertSystem {
    /**
     * @dev Error indicating that the caller is not authorized to perform the action.
     */
    error Unauthorized();

    /**
     * @dev Error indicating that an alert rule with the given ID does not exist.
     * @param ruleId The ID of the non-existent alert rule.
     */
    error AlertRuleNotFound(uint256 ruleId);

    /**
     * @dev Error indicating that an alert rule with the given ID already exists.
     * @param ruleId The ID of the existing alert rule.
     */
    error AlertRuleAlreadyExists(uint256 ruleId);

    /**
     * @dev Emitted when a new yield alert rule is registered.
     * @param ruleId The ID of the registered rule.
     * @param name The name of the rule.
     * @param description A description of the rule.
     * @param isActive Whether the rule is active upon registration.
     */
    event AlertRuleRegistered(uint256 ruleId, string name, string description, bool isActive);

    /**
     * @dev Emitted when an existing yield alert rule is updated.
     * @param ruleId The ID of the updated rule.
     * @param newName The new name of the rule.
     * @param newDescription The new description of the rule.
     */
    event AlertRuleUpdated(uint256 ruleId, string newName, string newDescription);

    /**
     * @dev Emitted when a yield alert rule's active status is changed.
     * @param ruleId The ID of the rule.
     * @param newStatus The new active status (true for active, false for inactive).
     */
    event AlertRuleStatusChanged(uint256 ruleId, bool newStatus);

    /**
     * @dev Emitted when a yield alert is triggered.
     * @param ruleId The ID of the rule that triggered the alert.
     * @param message A message describing the alert.
     * @param timestamp The timestamp when the alert was triggered.
     */
    event YieldAlertTriggered(uint256 ruleId, string message, uint256 timestamp);

    /**
     * @dev Registers a new yield alert rule.
     * @param name The name of the rule (e.g., "Low Yield Alert", "High Volatility Alert").
     * @param description A detailed description of the rule.
     * @param isActive Initial active status of the rule.
     * @return The unique ID assigned to the registered rule.
     */
    function registerAlertRule(string calldata name, string calldata description, bool isActive) external returns (uint256);

    /**
     * @dev Updates the details of an existing yield alert rule.
     * @param ruleId The ID of the rule to update.
     * @param newName The new name for the rule.
     * @param newDescription The new description for the rule.
     */
    function updateAlertRule(uint256 ruleId, string calldata newName, string calldata newDescription) external;

    /**
     * @dev Changes the active status of a yield alert rule.
     * @param ruleId The ID of the rule.
     * @param newStatus The new active status (true to activate, false to deactivate).
     */
    function setAlertRuleStatus(uint256 ruleId, bool newStatus) external;

    /**
     * @dev Triggers an alert for a specific rule.
     * @param ruleId The ID of the rule that is being triggered.
     * @param message A message describing the alert.
     */
    function triggerAlert(uint256 ruleId, string calldata message) external;

    /**
     * @dev Retrieves the details of a specific yield alert rule.
     * @param ruleId The ID of the rule.
     * @return name The name of the rule.
     * @return description The description of the rule.
     * @return isActive The active status of the rule.
     */
    function getAlertRuleDetails(uint256 ruleId) external view returns (string memory name, string memory description, bool isActive);

    /**
     * @dev Retrieves a list of all registered alert rule IDs.
     * @return An array of all rule IDs.
     */
    function getAllAlertRuleIds() external view returns (uint256[] memory);

    /**
     * @dev Retrieves a list of active alert rule IDs.
     * @return An array of active rule IDs.
     */
    function getActiveAlertRuleIds() external view returns (uint256[] memory);
}

/**
 * @title YieldAlertSystem
 * @dev Manages and tracks various yield alert rules within the DAO.
 *      Allows for registration, updating, status management, and triggering of alerts.
 */
contract YieldAlertSystem is IYieldAlertSystem {
    // State variables
    address public immutable i_owner;
    uint256 private s_nextRuleId;

    struct AlertRule {
        string name;
        string description;
        bool isActive;
    }

    mapping(uint256 => AlertRule) private s_alertRules;
    uint256[] private s_allRuleIds;

    // Constructor
    constructor() {
        i_owner = msg.sender;
        s_nextRuleId = 1;
    }

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Unauthorized();
        }
        _;
    }

    /**
     * @inheritdoc IYieldAlertSystem
     */
    function registerAlertRule(string calldata name, string calldata description, bool isActive) external onlyOwner returns (uint256) {
        uint256 ruleId = s_nextRuleId++;
        s_alertRules[ruleId] = AlertRule(name, description, isActive);
        s_allRuleIds.push(ruleId);
        emit AlertRuleRegistered(ruleId, name, description, isActive);
        return ruleId;
    }

    /**
     * @inheritdoc IYieldAlertSystem
     */
    function updateAlertRule(uint256 ruleId, string calldata newName, string calldata newDescription) external onlyOwner {
        AlertRule storage rule = s_alertRules[ruleId];
        if (bytes(rule.name).length == 0) {
            revert AlertRuleNotFound(ruleId);
        }
        rule.name = newName;
        rule.description = newDescription;
        emit AlertRuleUpdated(ruleId, newName, newDescription);
    }

    /**
     * @inheritdoc IYieldAlertSystem
     */
    function setAlertRuleStatus(uint256 ruleId, bool newStatus) external onlyOwner {
        AlertRule storage rule = s_alertRules[ruleId];
        if (bytes(rule.name).length == 0) {
            revert AlertRuleNotFound(ruleId);
        }
        if (rule.isActive != newStatus) {
            rule.isActive = newStatus;
            emit AlertRuleStatusChanged(ruleId, newStatus);
        }
    }

    /**
     * @inheritdoc IYieldAlertSystem
     */
    function triggerAlert(uint256 ruleId, string calldata message) external onlyOwner {
        AlertRule storage rule = s_alertRules[ruleId];
        if (bytes(rule.name).length == 0) {
            revert AlertRuleNotFound(ruleId);
        }
        emit YieldAlertTriggered(ruleId, message, block.timestamp);
    }

    /**
     * @inheritdoc IYieldAlertSystem
     */
    function getAlertRuleDetails(uint256 ruleId) external view returns (string memory name, string memory description, bool isActive) {
        AlertRule storage rule = s_alertRules[ruleId];
        if (bytes(rule.name).length == 0) {
            revert AlertRuleNotFound(ruleId);
        }
        return (rule.name, rule.description, rule.isActive);
    }

    /**
     * @inheritdoc IYieldAlertSystem
     */
    function getAllAlertRuleIds() external view returns (uint256[] memory) {
        return s_allRuleIds;
    }

    /**
     * @inheritdoc IYieldAlertSystem
     */
    function getActiveAlertRuleIds() external view returns (uint256[] memory) {
        uint256[] memory activeIds = new uint256[](s_allRuleIds.length);
        uint256 count = 0;
        for (uint256 i = 0; i < s_allRuleIds.length; i++) {
            uint256 ruleId = s_allRuleIds[i];
            if (s_alertRules[ruleId].isActive) {
                activeIds[count] = ruleId;
                count++;
            }
        }
        assembly {
            mstore(activeIds, count)
        }
        return activeIds;
    }
}