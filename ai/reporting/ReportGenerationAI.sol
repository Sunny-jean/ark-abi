// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ReportGenerationAI {
    /**
     * @dev Emitted when a report generation request is initiated.
     * @param reportId A unique identifier for the report.
     * @param reportType The type of report being generated.
     * @param requestedBy The address that requested the report.
     */
    event ReportGenerationRequested(bytes32 reportId, string reportType, address requestedBy);

    /**
     * @dev Emitted when a report is successfully generated and available.
     * @param reportId The unique identifier for the report.
     * @param reportHash A hash of the generated report content.
     * @param timestamp The time at which the report was generated.
     */
    event ReportGenerated(bytes32 reportId, bytes32 reportHash, uint256 timestamp);

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
     * @dev Thrown when a report generation fails.
     */
    error ReportGenerationFailed(bytes32 reportId, string reason);

    /**
     * @dev Generates a specific type of report based on provided parameters.
     * This function would typically trigger an off-chain AI process to compile data and format the report.
     * @param reportType The type of report to generate (e.g., "FinancialSummary", "PerformanceAnalysis", "AuditLog").
     * @param parameters Specific parameters required for report generation (e.g., date range, entity ID).
     * @return reportId A unique identifier for the generated report.
     */
    function generateReport(string calldata reportType, bytes calldata parameters) external returns (bytes32 reportId);

    /**
     * @dev Retrieves the status of a previously requested report generation.
     * @param reportId The unique identifier for the report.
     * @return status The current status of the report (e.g., "Pending", "InProgress", "Completed", "Failed").
     * @return reportHash A hash of the generated report content if completed, otherwise zero.
     * @return message A descriptive message about the report status or error.
     */
    function getReportStatus(bytes32 reportId) external view returns (string memory status, bytes32 reportHash, string memory message);

    /**
     * @dev Retrieves the content of a generated report given its hash.
     * This function would typically provide a URI or direct access to the off-chain report storage.
     * @param reportHash The hash of the report content.
     * @return reportContentUri A URI or link to access the report content.
     */
    function getReportContent(bytes32 reportHash) external view returns (string memory reportContentUri);

    /**
     * @dev Configures report templates or data sources for the AI.
     * @param reportType The type of report to configure.
     * @param templateHash A hash of the report template or configuration.
     */
    function configureReportTemplate(string calldata reportType, bytes32 templateHash) external;
}