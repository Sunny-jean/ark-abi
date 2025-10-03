// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface SystemHealthMonitorAI {
    /**
     * @dev Emitted when the system health status is updated.
     * @param timestamp The time at which the health status was updated.
     * @param overallStatus A boolean indicating the overall health status (true for healthy, false for unhealthy).
     * @param message A descriptive message about the system's health.
     */
    event SystemHealthUpdated(uint256 timestamp, bool overallStatus, string message);

    /**
     * @dev Emitted when a specific component's health status is updated.
     * @param componentName The name of the component.
     * @param isHealthy A boolean indicating if the component is healthy.
     * @param message A descriptive message about the component's health.
     */
    event ComponentHealthUpdated(string componentName, bool isHealthy, string message);

    /**
     * @dev Emitted when a critical system alert is triggered.
     * @param alertType The type of alert (e.g., "PerformanceDegradation", "ResourceExhaustion").
     * @param severity The severity of the alert (e.g., "High", "Medium", "Low").
     * @param details A detailed message about the alert.
     */
    event SystemAlertTriggered(string alertType, string severity, string details);

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
     * @dev Thrown when a system component is not found.
     */
    error ComponentNotFound(string componentName);

    /**
     * @dev Monitors the overall health and performance of the system.
     * This function would typically interact with various internal system metrics
     * and external data sources to provide a comprehensive health assessment.
     * @return overallStatus A boolean indicating the overall health status (true for healthy, false for unhealthy).
     * @return message A descriptive message about the system's health.
     */
    function monitorSystemHealth() external returns (bool overallStatus, string memory message);

    /**
     * @dev Retrieves the current status of the system or a specific component.
     * @param componentName The name of the component to check. If empty, returns overall system status.
     * @return isHealthy A boolean indicating if the specified component or system is healthy.
     * @return message A descriptive message about the component's or system's status.
     */
    function getSystemStatus(string calldata componentName) external view returns (bool isHealthy, string memory message);

    /**
     * @dev Submits a health report for a specific system component.
     * This function could be called by off-chain monitoring agents or other smart contracts.
     * @param componentName The name of the component reporting its health.
     * @param isHealthy A boolean indicating if the component is healthy.
     * @param message A descriptive message from the component.
     */
    function submitComponentHealthReport(string calldata componentName, bool isHealthy, string calldata message) external;

    /**
     * @dev Triggers a system alert based on detected anomalies or critical events.
     * @param alertType The type of alert (e.g., "PerformanceDegradation", "ResourceExhaustion").
     * @param severity The severity of the alert (e.g., "High", "Medium", "Low").
     * @param details A detailed message about the alert.
     */
    function triggerSystemAlert(string calldata alertType, string calldata severity, string calldata details) external;
}