// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ComplianceMonitoringAI {
    /**
     * @dev Emitted when a compliance check is completed.
     * @param timestamp The time at which the check was completed.
     * @param policyId The ID of the policy being checked.
     * @param isCompliant True if compliant, false otherwise.
     * @param details A message detailing the compliance status.
     */
    event ComplianceCheckCompleted(uint256 timestamp, bytes32 policyId, bool isCompliant, string details);

    /**
     * @dev Emitted when a compliance violation is detected.
     * @param violationId A unique identifier for the violation.
     * @param policyId The ID of the policy that was violated.
     * @param severity The severity of the violation (e.g., "Critical", "Warning").
     * @param description A description of the violation.
     */
    event ComplianceViolationDetected(bytes32 violationId, bytes32 policyId, string severity, string description);

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
     * @dev Thrown when a specified policy is not found.
     */
    error PolicyNotFound(bytes32 policyId);

    /**
     * @dev Monitors adherence to specified regulatory and internal policies.
     * This function would typically trigger an off-chain AI process to audit system activities and data.
     * @param policyId The ID of the policy to monitor.
     * @param scope A string defining the scope of the monitoring (e.g., "all_transactions", "user_data").
     * @return isCompliant True if the system is compliant with the policy within the given scope, false otherwise.
     * @return details A message detailing the compliance status.
     */
    function monitorCompliance(bytes32 policyId, string calldata scope) external returns (bool isCompliant, string memory details);

    /**
     * @dev Retrieves a detailed compliance report for a specific policy or overall system.
     * @param policyId The ID of the policy for which to get the report. If zero, gets overall report.
     * @return reportHash A hash of the detailed compliance report, accessible off-chain.
     * @return summary A brief summary of the compliance status.
     */
    function getComplianceReport(bytes32 policyId) external view returns (bytes32 reportHash, string memory summary);

    /**
     * @dev Registers a new compliance policy with the AI system.
     * @param policyId A unique identifier for the policy.
     * @param policyName The name of the policy.
     * @param policyRules A description or hash of the policy rules.
     */
    function registerPolicy(bytes32 policyId, string calldata policyName, bytes calldata policyRules) external;

    /**
     * @dev Updates the status of a detected compliance violation.
     * @param violationId The unique identifier for the violation.
     * @param newStatus The new status (e.g., "UnderReview", "Remediated", "Closed").
     * @param notes Additional notes about the update.
     */
    function updateViolationStatus(bytes32 violationId, string calldata newStatus, string calldata notes) external;
}