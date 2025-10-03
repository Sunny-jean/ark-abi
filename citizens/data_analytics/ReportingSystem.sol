// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ReportingSystem {
    /**
     * @dev Emitted when a new report is submitted.
     * @param reportId The unique ID of the report.
     * @param reporter The address that submitted the report.
     * @param reportType The type of report.
     * @param timestamp The timestamp when the report was submitted.
     */
    event ReportSubmitted(bytes32 indexed reportId, address indexed reporter, string indexed reportType, uint256 timestamp);

    /**
     * @dev Emitted when a report's status is updated.
     * @param reportId The unique ID of the report.
     * @param newStatus The new status of the report.
     * @param updater The address that updated the status.
     */
    event ReportStatusUpdated(bytes32 indexed reportId, string indexed newStatus, address indexed updater);

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
     * @dev Thrown when a report with the given ID is not found.
     */
    error ReportNotFound(bytes32 reportId);

    /**
     * @dev Thrown when attempting to submit a report that already exists.
     */
    error ReportAlreadyExists(bytes32 reportId);

    /**
     * @dev Submits a new report to the system.
     * @param reportId The unique ID for the report.
     * @param reportType The type of report (e.g., "bug_report", "feedback", "incident").
     * @param contentHash A hash of the report content, allowing for off-chain storage.
     * @param metadataURI A URI pointing to additional metadata about the report.
     */
    function submitReport(bytes32 reportId, string calldata reportType, bytes32 contentHash, string calldata metadataURI) external;

    /**
     * @dev Updates the status of an existing report.
     * @param reportId The unique ID of the report to update.
     * @param newStatus The new status of the report (e.g., "pending", "resolved", "closed").
     * @param reason A reason for the status update.
     */
    function updateReportStatus(bytes32 reportId, string calldata newStatus, string calldata reason) external;

    /**
     * @dev Retrieves the details of a specific report.
     * @param reportId The unique ID of the report.
     * @return reporter The address that submitted the report.
     * @return reportType The type of report.
     * @return contentHash The hash of the report content.
     * @return metadataURI A URI pointing to additional metadata.
     * @return currentStatus The current status of the report.
     * @return lastStatusUpdate The timestamp of the last status update.
     */
    function getReportDetails(bytes32 reportId) external view returns (address reporter, string memory reportType, bytes32 contentHash, string memory metadataURI, string memory currentStatus, uint256 lastStatusUpdate);

    /**
     * @dev Retrieves all reports of a specific type with a given status.
     * @param reportType The type of reports to retrieve.
     * @param status The status of reports to retrieve.
     * @return reportIds An array of report IDs matching the criteria.
     */
    function getReportsByStatus(string calldata reportType, string calldata status) external view returns (bytes32[] memory reportIds);
}