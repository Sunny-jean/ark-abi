// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface AnomalyDetectionAI {
    /**
     * @dev Emitted when an anomaly is detected.
     * @param timestamp The time at which the anomaly was detected.
     * @param anomalyType A string describing the type of anomaly (e.g., "UnusualActivity", "DataSpike").
     * @param severity The severity of the anomaly (e.g., "Critical", "High", "Medium", "Low").
     * @param details A detailed message about the detected anomaly.
     */
    event AnomalyDetected(uint256 timestamp, string anomalyType, string severity, string details);

    /**
     * @dev Emitted when an anomaly report is generated or updated.
     * @param reportId A unique identifier for the anomaly report.
     * @param status The current status of the report (e.g., "New", "Investigating", "Resolved").
     */
    event AnomalyReportUpdated(bytes32 reportId, string status);

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
     * @dev Thrown when an anomaly detection process fails.
     */
    error DetectionFailed(string reason);

    /**
     * @dev Detects anomalies in system behavior or data patterns.
     * This function would typically trigger an off-chain AI process to analyze incoming data streams.
     * @param dataType A string indicating the type of data being analyzed (e.g., "transaction_volume", "user_activity").
     * @param dataHash A hash of the data or data source being analyzed.
     * @return isAnomaly True if an anomaly is detected, false otherwise.
     * @return anomalyType A string describing the type of anomaly if detected.
     * @return severity The severity of the anomaly if detected.
     */
    function detectAnomaly(string calldata dataType, bytes32 dataHash) external returns (bool isAnomaly, string memory anomalyType, string memory severity);

    /**
     * @dev Retrieves a detailed report for a detected anomaly.
     * @param reportId The unique identifier of the anomaly report.
     * @return anomalyType The type of anomaly.
     * @return severity The severity of the anomaly.
     * @return details A detailed message about the anomaly.
     * @return status The current status of the anomaly (e.g., "New", "Investigating", "Resolved").
     */
    function getAnomalyReport(bytes32 reportId) external view returns (string memory anomalyType, string memory severity, string memory details, string memory status);

    /**
     * @dev Updates the status of an anomaly report.
     * This can be used to mark an anomaly as investigated or resolved.
     * @param reportId The unique identifier of the anomaly report.
     * @param newStatus The new status to set for the report.
     * @param notes Additional notes or comments about the update.
     */
    function updateAnomalyReportStatus(bytes32 reportId, string calldata newStatus, string calldata notes) external;
}