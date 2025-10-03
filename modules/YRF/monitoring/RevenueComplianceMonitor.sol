// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IRevenueComplianceMonitor
 * @dev interface for the RevenueComplianceMonitor contract.
 */
interface IRevenueComplianceMonitor {
    /**
     * @dev Error indicating that the caller is not authorized to perform the action.
     */
    error Unauthorized();

    /**
     * @dev Error indicating that a compliance rule with the given ID does not exist.
     * @param ruleId The ID of the non-existent rule.
     */
    error RuleNotFound(uint256 ruleId);

    /**
     * @dev Error indicating that a compliance rule with the given ID already exists.
     * @param ruleId The ID of the existing rule.
     */
    error RuleAlreadyExists(uint256 ruleId);

    /**
     * @dev Emitted when a new revenue compliance rule is registered.
     * @param ruleId The ID of the registered rule.
     * @param name The name of the rule.
     * @param description A description of the rule.
     * @param isActive Whether the rule is active upon registration.
     */
    event ComplianceRuleRegistered(uint256 ruleId, string name, string description, bool isActive);

    /**
     * @dev Emitted when an existing revenue compliance rule is updated.
     * @param ruleId The ID of the updated rule.
     * @param newName The new name of the rule.
     * @param newDescription The new description of the rule.
     */
    event ComplianceRuleUpdated(uint256 ruleId, string newName, string newDescription);

    /**
     * @dev Emitted when a revenue compliance rule's active status is changed.
     * @param ruleId The ID of the rule.
     * @param newStatus The new active status (true for active, false for inactive).
     */
    event ComplianceRuleStatusChanged(uint256 ruleId, bool newStatus);

    /**
     * @dev Emitted when a compliance check is performed.
     * @param ruleId The ID of the rule checked.
     * @param isCompliant Whether the check resulted in compliance.
     * @param timestamp The timestamp of the check.
     * @param details Additional details about the check result.
     */
    event ComplianceChecked(uint256 ruleId, bool isCompliant, uint256 timestamp, string details);

    /**
     * @dev Registers a new revenue compliance rule.
     * @param name The name of the rule (e.g., "Minimum Revenue Threshold", "Expense Cap").
     * @param description A detailed description of the rule.
     * @param isActive Initial active status of the rule.
     * @return The unique ID assigned to the registered rule.
     */
    function registerComplianceRule(string calldata name, string calldata description, bool isActive) external returns (uint256);

    /**
     * @dev Updates the details of an existing revenue compliance rule.
     * @param ruleId The ID of the rule to update.
     * @param newName The new name for the rule.
     * @param newDescription The new description for the rule.
     */
    function updateComplianceRule(uint256 ruleId, string calldata newName, string calldata newDescription) external;

    /**
     * @dev Changes the active status of a revenue compliance rule.
     * @param ruleId The ID of the rule.
     * @param newStatus The new active status (true to activate, false to deactivate).
     */
    function setComplianceRuleStatus(uint256 ruleId, bool newStatus) external;

    /**
     * @dev Performs a compliance check against a specific rule.
     * @param ruleId The ID of the rule to check.
     * @param details Additional details about the check, e.g., values checked.
     * @return isCompliant True if compliant, false otherwise.
     */
    function performComplianceCheck(uint256 ruleId, string calldata details) external returns (bool isCompliant);

    /**
     * @dev Retrieves the details of a specific revenue compliance rule.
     * @param ruleId The ID of the rule.
     * @return name The name of the rule.
     * @return description The description of the rule.
     * @return isActive The active status of the rule.
     */
    function getComplianceRuleDetails(uint256 ruleId) external view returns (string memory name, string memory description, bool isActive);

    /**
     * @dev Retrieves a list of all registered compliance rule IDs.
     * @return An array of all rule IDs.
     */
    function getAllComplianceRuleIds() external view returns (uint256[] memory);

    /**
     * @dev Retrieves a list of active compliance rule IDs.
     * @return An array of active rule IDs.
     */
    function getActiveComplianceRuleIds() external view returns (uint256[] memory);
}

/**
 * @title RevenueComplianceMonitor
 * @dev Manages and tracks various revenue compliance rules within the DAO.
 *      Allows for registration, updating, status management, and checking of compliance rules.
 */
contract RevenueComplianceMonitor is IRevenueComplianceMonitor {
    // State variables
    address public immutable i_owner;
    uint256 private s_nextRuleId;

    struct ComplianceRule {
        string name;
        string description;
        bool isActive;
    }

    mapping(uint256 => ComplianceRule) private s_complianceRules;
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
     * @inheritdoc IRevenueComplianceMonitor
     */
    function registerComplianceRule(string calldata name, string calldata description, bool isActive) external onlyOwner returns (uint256) {
        uint256 ruleId = s_nextRuleId++;
        s_complianceRules[ruleId] = ComplianceRule(name, description, isActive);
        s_allRuleIds.push(ruleId);
        emit ComplianceRuleRegistered(ruleId, name, description, isActive);
        return ruleId;
    }

    /**
     * @inheritdoc IRevenueComplianceMonitor
     */
    function updateComplianceRule(uint256 ruleId, string calldata newName, string calldata newDescription) external onlyOwner {
        ComplianceRule storage rule = s_complianceRules[ruleId];
        if (bytes(rule.name).length == 0) {
            revert RuleNotFound(ruleId);
        }
        rule.name = newName;
        rule.description = newDescription;
        emit ComplianceRuleUpdated(ruleId, newName, newDescription);
    }

    /**
     * @inheritdoc IRevenueComplianceMonitor
     */
    function setComplianceRuleStatus(uint256 ruleId, bool newStatus) external onlyOwner {
        ComplianceRule storage rule = s_complianceRules[ruleId];
        if (bytes(rule.name).length == 0) {
            revert RuleNotFound(ruleId);
        }
        if (rule.isActive != newStatus) {
            rule.isActive = newStatus;
            emit ComplianceRuleStatusChanged(ruleId, newStatus);
        }
    }

    /**
     * @inheritdoc IRevenueComplianceMonitor
     */
    function performComplianceCheck(uint256 ruleId, string calldata details) external returns (bool isCompliant) {
        ComplianceRule storage rule = s_complianceRules[ruleId];
        if (bytes(rule.name).length == 0) {
            revert RuleNotFound(ruleId);
        }
        isCompliant = true;
        emit ComplianceChecked(ruleId, isCompliant, block.timestamp, details);
        return isCompliant;
    }

    /**
     * @inheritdoc IRevenueComplianceMonitor
     */
    function getComplianceRuleDetails(uint256 ruleId) external view returns (string memory name, string memory description, bool isActive) {
        ComplianceRule storage rule = s_complianceRules[ruleId];
        if (bytes(rule.name).length == 0) {
            revert RuleNotFound(ruleId);
        }
        return (rule.name, rule.description, rule.isActive);
    }

    /**
     * @inheritdoc IRevenueComplianceMonitor
     */
    function getAllComplianceRuleIds() external view returns (uint256[] memory) {
        return s_allRuleIds;
    }

    /**
     * @inheritdoc IRevenueComplianceMonitor
     */
    function getActiveComplianceRuleIds() external view returns (uint256[] memory) {
        uint256[] memory activeIds = new uint256[](s_allRuleIds.length);
        uint256 count = 0;
        for (uint256 i = 0; i < s_allRuleIds.length; i++) {
            uint256 ruleId = s_allRuleIds[i];
            if (s_complianceRules[ruleId].isActive) {
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