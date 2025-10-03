// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface PerformanceMetricsReporter {
    /**
     * @dev Emitted when a new performance metric is recorded.
     * @param metricId The unique ID of the metric.
     * @param moduleId The ID of the module the metric is for.
     * @param value The value of the metric.
     */
    event MetricRecorded(bytes32 indexed metricId, bytes32 indexed moduleId, uint256 value);

    /**
     * @dev Emitted when a performance report is generated.
     * @param reportId The unique ID of the report.
     * @param reportHash A hash of the report content.
     */
    event PerformanceReportGenerated(bytes32 indexed reportId, bytes32 reportHash);

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
     * @dev Thrown when the specified module is not found.
     */
    error ModuleNotFound(bytes32 moduleId);

    /**
     * @dev Thrown when a report is not found.
     */
    error ReportNotFound(bytes32 reportId);

    /**
     * @dev Records a performance metric for a specific module or system component.
     * @param moduleId The unique ID of the module or component.
     * @param metricType The type of metric (e.g., "response_time", "transaction_throughput").
     * @param value The numerical value of the metric.
     * @param timestamp The timestamp when the metric was recorded.
     */
    function recordMetric(bytes32 moduleId, string calldata metricType, uint256 value, uint256 timestamp) external;

    /**
     * @dev Generates a performance report based on collected metrics.
     * @param reportType The type of report to generate (e.g., "daily_summary", "weekly_performance").
     * @param timeRange The time range for the report.
     * @return reportId The unique ID of the generated report.
     */
    function generatePerformanceReport(string calldata reportType, uint256 timeRange) external returns (bytes32 reportId);

    /**
     * @dev Retrieves a previously generated performance report.
     * @param reportId The unique ID of the report to retrieve.
     * @return reportContent The content of the performance report.
     */
    function getPerformanceReport(bytes32 reportId) external view returns (bytes memory reportContent);
}