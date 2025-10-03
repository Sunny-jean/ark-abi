// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ComplianceManager {
    /**
     * @dev Emitted when a new compliance rule is added or updated.
     * @param ruleId The unique ID of the compliance rule.
     * @param ruleType The type of rule (e.g., "sanction_list", "transaction_limit").
     * @param enforcedBy The address that enforces this rule.
     */
    event ComplianceRuleUpdated(bytes32 indexed ruleId, string indexed ruleType, address indexed enforcedBy);

    /**
     * @dev Emitted when a transaction or action is flagged for compliance review.
     * @param transactionId The ID of the transaction or action.
     * @param ruleId The ID of the rule that was triggered.
     * @param reason The reason for the flag.
     */
    event ComplianceFlagged(bytes32 indexed transactionId, bytes32 indexed ruleId, string reason);

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
     * @dev Thrown when a compliance rule with the given ID is not found.
     */
    error ComplianceRuleNotFound(bytes32 ruleId);

    /**
     * @dev Thrown when an action violates a compliance rule.
     */
    error ComplianceViolation(bytes32 ruleId, string reason);

    /**
     * @dev Adds or updates a compliance rule.
     * @param ruleId The unique ID for the rule.
     * @param ruleType The type of rule (e.g., "sanction_list", "transaction_limit").
     * @param ruleData A bytes array containing rule-specific data (e.g., address list, limit value).
     */
    function addOrUpdateRule(bytes32 ruleId, string calldata ruleType, bytes calldata ruleData) external;

    /**
     * @dev Checks if a given action complies with all active rules.
     * @param actionType The type of action being performed (e.g., "transfer", "mint").
     * @param actor The address initiating the action.
     * @param target The address or entity being acted upon.
     * @param amount The amount involved in the action.
     * @return isCompliant True if the action complies, false otherwise.
     */
    function checkCompliance(string calldata actionType, address actor, address target, uint256 amount) external view returns (bool isCompliant);

    /**
     * @dev Retrieves the details of a specific compliance rule.
     * @param ruleId The unique ID of the rule.
     * @return ruleType The type of rule.
     * @return ruleData A bytes array containing rule-specific data.
     * @return isActive True if the rule is active, false otherwise.
     */
    function getRuleDetails(bytes32 ruleId) external view returns (string memory ruleType, bytes memory ruleData, bool isActive);

    /**
     * @dev Flags a transaction or action for compliance review.
     * @param transactionId The ID of the transaction or action.
     * @param ruleId The ID of the rule that was triggered.
     * @param reason The reason for the flag.
     */
    function flagForReview(bytes32 transactionId, bytes32 ruleId, string calldata reason) external;
}