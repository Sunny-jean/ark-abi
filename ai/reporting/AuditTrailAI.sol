// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface AuditTrailAI {
    /**
     * @dev Emitted when an audit event is recorded.
     * @param eventId A unique identifier for the audit event.
     * @param timestamp The time at which the event occurred.
     * @param actor The address that initiated the event.
     * @param eventType A string describing the type of event (e.g., "Login", "ConfigurationChange", "Transaction").
     * @param details A detailed message about the event.
     */
    event AuditEventRecorded(bytes32 eventId, uint256 timestamp, address actor, string eventType, string details);

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
     * @dev Thrown when an audit event cannot be recorded.
     */
    error AuditRecordFailed(string reason);

    /**
     * @dev Records an auditable event within the system.
     * This function is called by various system components to log significant actions.
     * @param actor The address that initiated the event.
     * @param eventType A string describing the type of event (e.g., "Login", "ConfigurationChange", "Transaction").
     * @param details A detailed message about the event.
     * @param data Additional data relevant to the event (e.g., old/new values, transaction hash).
     * @return eventId A unique identifier for the recorded audit event.
     */
    function recordAuditEvent(address actor, string calldata eventType, string calldata details, bytes calldata data) external returns (bytes32 eventId);

    /**
     * @dev Retrieves the history of audit events based on specified criteria.
     * @param filterType The type of filter to apply (e.g., "actor", "eventType", "timeRange").
     * @param filterValue The value to filter by.
     * @return eventIds An array of unique identifiers for matching audit events.
     */
    function getAuditHistory(string calldata filterType, string calldata filterValue) external view returns (bytes32[] memory eventIds);

    /**
     * @dev Retrieves the full details of a specific audit event.
     * @param eventId The unique identifier for the audit event.
     * @return timestamp The time at which the event occurred.
     * @return actor The address that initiated the event.
     * @return eventType The type of event.
     * @return details A detailed message about the event.
     * @return data Additional data associated with the event.
     */
    function getAuditEventDetails(bytes32 eventId) external view returns (uint256 timestamp, address actor, string memory eventType, string memory details, bytes memory data);

    /**
     * @dev Analyzes audit trails for suspicious activities or compliance breaches.
     * This would typically trigger an off-chain AI process.
     * @param timeRangeStart The start timestamp for the analysis.
     * @param timeRangeEnd The end timestamp for the analysis.
     * @return analysisReportHash A hash of the analysis report.
     */
    function analyzeAuditTrail(uint256 timeRangeStart, uint256 timeRangeEnd) external returns (bytes32 analysisReportHash);
}