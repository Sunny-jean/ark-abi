// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface SecurityAuditor {
    /**
     * @dev Emitted when a security audit is initiated.
     * @param auditId The unique ID of the audit.
     * @param targetAddress The address of the contract/module being audited.
     * @param auditor The address of the entity performing the audit.
     */
    event AuditInitiated(bytes32 indexed auditId, address indexed targetAddress, address indexed auditor);

    /**
     * @dev Emitted when an audit report is submitted.
     * @param auditId The unique ID of the audit.
     * @param reportHash A hash of the audit report.
     * @param findingsCount The number of findings in the report.
     */
    event AuditReportSubmitted(bytes32 indexed auditId, bytes32 reportHash, uint256 findingsCount);

    /**
     * @dev Emitted when a vulnerability is identified.
     * @param auditId The unique ID of the audit.
     * @param vulnerabilityId The unique ID of the vulnerability.
     * @param severity The severity of the vulnerability.
     */
    event VulnerabilityIdentified(bytes32 indexed auditId, bytes32 indexed vulnerabilityId, uint256 severity);

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
     * @dev Thrown when an audit with the given ID does not exist.
     */
    error AuditNotFound(bytes32 auditId);

    /**
     * @dev Initiates a security audit for a specified contract or module.
     * @param targetAddress The address of the contract or module to be audited.
     * @param auditor The address of the entity performing the audit.
     * @return auditId The unique ID generated for this audit.
     */
    function initiateAudit(address targetAddress, address auditor) external returns (bytes32 auditId);

    /**
     * @dev Submits a security audit report.
     * @param auditId The unique ID of the audit.
     * @param reportHash A hash of the full audit report, typically stored off-chain.
     * @param findingsCount The number of security findings/vulnerabilities identified.
     */
    function submitAuditReport(bytes32 auditId, bytes32 reportHash, uint256 findingsCount) external;

    /**
     * @dev Records a specific vulnerability identified during an audit.
     * @param auditId The unique ID of the audit.
     * @param vulnerabilityId A unique ID for the vulnerability.
     * @param descriptionHash A hash of the vulnerability description.
     * @param severity The severity level of the vulnerability (e.g., 1-5).
     */
    function recordVulnerability(bytes32 auditId, bytes32 vulnerabilityId, bytes32 descriptionHash, uint256 severity) external;

    /**
     * @dev Retrieves the status and details of a security audit.
     * @param auditId The unique ID of the audit.
     * @return targetAddress The address of the audited contract.
     * @return auditor The address of the auditor.
     * @return reportHash The hash of the audit report.
     * @return findingsCount The number of findings.
     */
    function getAuditDetails(bytes32 auditId) external view returns (address targetAddress, address auditor, bytes32 reportHash, uint256 findingsCount);
}