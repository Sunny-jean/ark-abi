// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ComplianceAudit {
    /**
     * @dev Emitted when a compliance audit report is submitted.
     * @param reportId The unique ID of the audit report.
     * @param auditor The address of the auditor who submitted the report.
     * @param timestamp The timestamp when the report was submitted.
     */
    event AuditReportSubmitted(bytes32 indexed reportId, address indexed auditor, uint256 timestamp);

    /**
     * @dev Emitted when a compliance finding is logged.
     * @param reportId The ID of the audit report.
     * @param findingId The unique ID of the finding.
     * @param severity The severity of the finding (e.g., "critical", "high", "medium", "low").
     * @param descriptionHash A hash of the finding description.
     */
    event ComplianceFindingLogged(bytes32 indexed reportId, bytes32 indexed findingId, string severity, bytes32 descriptionHash);

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
    error ReportNotFound(bytes32 reportId);

    /**
     * @dev Thrown when a finding with the given ID is not found within a report.
     */
    error FindingNotFound(bytes32 findingId);

    /**
     * @dev Submits a new compliance audit report.
     * @param reportId The unique ID for the report.
     * @param auditor The address of the auditor.
     * @param reportHash A hash of the full audit report content (e.g., IPFS hash).
     */
    function submitAuditReport(bytes32 reportId, address auditor, bytes32 reportHash) external;

    /**
     * @dev Logs a specific finding within an audit report.
     * @param reportId The ID of the audit report this finding belongs to.
     * @param findingId The unique ID for the finding.
     * @param severity The severity of the finding.
     * @param descriptionHash A hash of the finding description.
     */
    function logFinding(bytes32 reportId, bytes32 findingId, string calldata severity, bytes32 descriptionHash) external;

    /**
     * @dev Retrieves the details of a compliance audit report.
     * @param reportId The ID of the report.
     * @return auditor The address of the auditor.
     * @return reportHash The hash of the full report content.
     * @return timestamp The submission timestamp.
     */
    function getReportDetails(bytes32 reportId) external view returns (address auditor, bytes32 reportHash, uint256 timestamp);

    /**
     * @dev Retrieves the details of a specific finding within an audit report.
     * @param reportId The ID of the audit report.
     * @param findingId The ID of the finding.
     * @return severity The severity of the finding.
     * @return descriptionHash The hash of the finding description.
     */
    function getFindingDetails(bytes32 reportId, bytes32 findingId) external view returns (string memory severity, bytes32 descriptionHash);

    /**
     * @dev Retrieves all findings associated with a specific audit report.
     * @param reportId The ID of the audit report.
     * @return findingIds An array of finding IDs.
     */
    function getFindingsByReport(bytes32 reportId) external view returns (bytes32[] memory findingIds);
}