// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface AnalyticsDashboard {
    /**
     * @dev Emitted when a new data point is recorded for analytics.
     * @param metricName The name of the metric.
     * @param value The value of the metric.
     * @param timestamp The timestamp when the data point was recorded.
     */
    event DataPointRecorded(string indexed metricName, uint256 value, uint256 timestamp);

    /**
     * @dev Emitted when a new report is generated.
     * @param reportId The unique ID of the report.
     * @param reportType The type of report.
     * @param generatedBy The address that generated the report.
     */
    event ReportGenerated(bytes32 indexed reportId, string indexed reportType, address indexed generatedBy);

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
     * @dev Thrown when a metric with the given name is not found.
     */
    error MetricNotFound(string metricName);

    /**
     * @dev Records a data point for a specific metric.
     * @param metricName The name of the metric (e.g., "total_users", "transactions_per_day").
     * @param value The value of the data point.
     */
    function recordDataPoint(string calldata metricName, uint256 value) external;

    /**
     * @dev Generates an on-chain analytics report.
     * @param reportType The type of report to generate (e.g., "daily_summary", "weekly_active_users").
     * @param parameters Additional parameters for report generation.
     * @return reportId The unique ID of the generated report.
     */
    function generateReport(string calldata reportType, bytes calldata parameters) external returns (bytes32 reportId);

    /**
     * @dev Retrieves the latest value for a specific metric.
     * @param metricName The name of the metric.
     * @return value The latest recorded value.
     * @return timestamp The timestamp of the latest recording.
     */
    function getLatestMetricValue(string calldata metricName) external view returns (uint256 value, uint256 timestamp);

    /**
     * @dev Retrieves historical data points for a metric within a time range.
     * @param metricName The name of the metric.
     * @param startTime The start timestamp of the range.
     * @param endTime The end timestamp of the range.
     * @return values An array of recorded values.
     * @return timestamps An array of timestamps corresponding to the values.
     */
    function getMetricHistory(string calldata metricName, uint256 startTime, uint256 endTime) external view returns (uint256[] memory values, uint256[] memory timestamps);
}