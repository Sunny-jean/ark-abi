// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface SecurityAudit {
    /**
     * @dev Emitted when a new audit report is submitted.
     * @param reportId The unique ID of the audit report.
     * @param auditor The address of the auditor.
     * @param timestamp The timestamp when the report was submitted.
     */
    event AuditReportSubmitted(bytes32 indexed reportId, address indexed auditor, uint256 timestamp);

    /**
     * @dev Emitted when an audit finding is logged.
     * @param reportId The ID of the audit report.
     * @param findingId The unique ID of the finding.
     * @param severity The severity of the finding (e.g., "critical", "high", "medium", "low").
     */
    event AuditFindingLogged(bytes32 indexed reportId, bytes32 indexed findingId, string indexed severity);

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
     * @dev Thrown when an audit report with the given ID is not found.
     */
    error AuditReportNotFound(bytes32 reportId);

    /**
     * @dev Thrown when an audit finding with the given ID is not found.
     */
    error AuditFindingNotFound(bytes32 findingId);

    /**
     * @dev Submits a new security audit report.
     * @param reportId The unique ID for the audit report.
     * @param auditor The address of the auditor.
     * @param reportURI A URI pointing to the full audit report (e.g., IPFS hash).
     */
    function submitAuditReport(bytes32 reportId, address auditor, string calldata reportURI) external;

    /**
     * @dev Logs a specific finding within an audit report.
     * @param reportId The ID of the audit report this finding belongs to.
     * @param findingId The unique ID for this finding.
     * @param severity The severity of the finding (e.g., "critical", "high", "medium", "low").
     * @param descriptionHash A hash of the finding's description.
     */
    function logAuditFinding(bytes32 reportId, bytes32 findingId, string calldata severity, bytes32 descriptionHash) external;

    /**
     * @dev Retrieves the details of a specific audit report.
     * @param reportId The unique ID of the audit report.
     * @return auditor The address of the auditor.
     * @return reportURI A URI pointing to the full audit report.
     * @return timestamp The timestamp when the report was submitted.
     */
    function getAuditReportDetails(bytes32 reportId) external view returns (address auditor, string memory reportURI, uint256 timestamp);

    /**
     * @dev Retrieves the details of a specific audit finding.
     * @param findingId The unique ID of the finding.
     * @return reportId The ID of the audit report this finding belongs to.
     * @return severity The severity of the finding.
     * @return descriptionHash A hash of the finding's description.
     */
    function getAuditFindingDetails(bytes32 findingId) external view returns (bytes32 reportId, string memory severity, bytes32 descriptionHash);

    /**
     * @dev Retrieves all findings for a given audit report.
     * @param reportId The ID of the audit report.
     * @return findingIds An array of finding IDs associated with the report.
     */
    function getFindingsForReport(bytes32 reportId) external view returns (bytes32[] memory findingIds);
}