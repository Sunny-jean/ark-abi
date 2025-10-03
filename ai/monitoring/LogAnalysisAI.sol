// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface LogAnalysisAI {
    /**
     * @dev Emitted when a log analysis is completed.
     * @param timestamp The time at which the analysis was completed.
     * @param reportHash A hash of the detailed analysis report.
     * @param summary A brief summary of the analysis findings.
     */
    event LogAnalysisCompleted(uint256 timestamp, bytes32 reportHash, string summary);

    /**
     * @dev Emitted when a specific log event pattern is detected.
     * @param patternId A unique identifier for the detected pattern.
     * @param description A description of the detected pattern.
     * @param count The number of times the pattern was observed.
     */
    event LogPatternDetected(bytes32 patternId, string description, uint256 count);

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
     * @dev Thrown when a log analysis operation fails.
     */
    error AnalysisFailed(string reason);

    /**
     * @dev Analyzes system logs to identify patterns, anomalies, and potential issues.
     * This function would typically trigger an off-chain AI process to ingest and process log data.
     * @param logSource A string identifying the source of the logs (e.g., "blockchain_events", "server_logs").
     * @param timeRangeStart The start timestamp for the log analysis.
     * @param timeRangeEnd The end timestamp for the log analysis.
     * @return reportHash A hash of the detailed log analysis report, accessible off-chain.
     */
    function analyzeLogs(string calldata logSource, uint256 timeRangeStart, uint256 timeRangeEnd) external returns (bytes32 reportHash);

    /**
     * @dev Retrieves a detailed report of a completed log analysis.
     * @param reportHash The hash of the log analysis report.
     * @return summary A brief summary of the analysis findings.
     * @return detectedPatterns An array of detected log patterns.
     * @return issuesIdentified An array of identified issues or anomalies.
     */
    function getAnalysisReport(bytes32 reportHash) external view returns (string memory summary, string[] memory detectedPatterns, string[] memory issuesIdentified);

    /**
     * @dev Submits log data for analysis. This could be called by off-chain loggers.
     * @param logData The raw log data to be analyzed.
     * @param logSource The source of the log data.
     */
    function submitLogData(bytes calldata logData, string calldata logSource) external;

    /**
     * @dev Configures rules or patterns for the AI to look for during log analysis.
     * @param patternId A unique identifier for the pattern.
     * @param regexPattern The regular expression or pattern to detect.
     * @param description A description of what this pattern signifies.
     */
    function configureLogPattern(bytes32 patternId, string calldata regexPattern, string calldata description) external;
}