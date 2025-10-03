// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface AlertManagementAI {
    /**
     * @dev Emitted when a new alert is raised.
     * @param alertId A unique identifier for the alert.
     * @param alertType The type of alert (e.g., "CriticalError", "PerformanceWarning").
     * @param severity The severity of the alert (e.g., "High", "Medium", "Low").
     * @param timestamp The time at which the alert was raised.
     * @param message A descriptive message about the alert.
     */
    event AlertRaised(bytes32 alertId, string alertType, string severity, uint256 timestamp, string message);

    /**
     * @dev Emitted when an alert's status is updated.
     * @param alertId The unique identifier for the alert.
     * @param newStatus The new status of the alert (e.g., "Acknowledged", "Resolved", "Escalated").
     * @param updatedBy The address that updated the alert status.
     */
    event AlertStatusUpdated(bytes32 alertId, string newStatus, address updatedBy);

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
     * @dev Thrown when an alert with the given ID is not found.
     */
    error AlertNotFound(bytes32 alertId);

    /**
     * @dev Raises a new system alert based on detected issues or anomalies.
     * This function allows various system components or other AIs to report issues.
     * @param alertType The type of alert (e.g., "CriticalError", "PerformanceWarning").
     * @param severity The severity of the alert (e.g., "High", "Medium", "Low").
     * @param message A descriptive message about the alert.
     * @param data Additional data relevant to the alert (e.g., error codes, transaction hashes).
     * @return alertId A unique identifier for the newly raised alert.
     */
    function raiseAlert(string calldata alertType, string calldata severity, string calldata message, bytes calldata data) external returns (bytes32 alertId);

    /**
     * @dev Retrieves the current status and details of a specific alert.
     * @param alertId The unique identifier for the alert.
     * @return alertType The type of alert.
     * @return severity The severity of the alert.
     * @return timestamp The time at which the alert was raised.
     * @return message A descriptive message about the alert.
     * @return status The current status of the alert.
     * @return data Additional data associated with the alert.
     */
    function getAlertStatus(bytes32 alertId) external view returns (string memory alertType, string memory severity, uint256 timestamp, string memory message, string memory status, bytes memory data);

    /**
     * @dev Updates the status of an existing alert (e.g., to acknowledge, resolve, or escalate).
     * @param alertId The unique identifier for the alert.
     * @param newStatus The new status to set for the alert.
     * @param notes Additional notes or comments about the status update.
     */
    function updateAlertStatus(bytes32 alertId, string calldata newStatus, string calldata notes) external;

    /**
     * @dev Retrieves a list of active alerts based on specified criteria.
     * @param filterType The type of filter to apply (e.g., "severity", "status", "type").
     * @param filterValue The value to filter by.
     * @return alertIds An array of unique identifiers for matching alerts.
     */
    function getActiveAlerts(string calldata filterType, string calldata filterValue) external view returns (bytes32[] memory alertIds);
}