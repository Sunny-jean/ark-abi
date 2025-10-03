// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface SecurityAuditLog {
    /**
     * @dev Emitted when a security-relevant event is logged.
     * @param eventType The type of security event (e.g., "access_granted", "vulnerability_found", "attack_attempt").
     * @param actor The address that initiated the event, if applicable.
     * @param target The address or component affected by the event, if applicable.
     * @param detailsHash A hash of additional details about the event (e.g., IPFS hash of log data).
     * @param timestamp The timestamp when the event occurred.
     */
    event SecurityEventLogged(string indexed eventType, address indexed actor, address indexed target, bytes32 detailsHash, uint256 timestamp);

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
     * @dev Logs a security-relevant event.
     * @param eventType The type of security event.
     * @param actor The address that initiated the event.
     * @param target The address or component affected.
     * @param detailsHash A hash of additional details.
     */
    function logSecurityEvent(string calldata eventType, address actor, address target, bytes32 detailsHash) external;

    /**
     * @dev Retrieves a list of security events by type.
     * @param eventType The type of security event to query.
     * @return events An array of SecurityEvent structs.
     */
    function getEventsByType(string calldata eventType) external view returns (SecurityEvent[] memory events);

    /**
     * @dev Retrieves a list of security events involving a specific actor.
     * @param actor The address of the actor to query.
     * @return events An array of SecurityEvent structs.
     */
    function getEventsByActor(address actor) external view returns (SecurityEvent[] memory events);

    /**
     * @dev Retrieves a list of security events affecting a specific target.
     * @param target The address or component target to query.
     * @return events An array of SecurityEvent structs.
     */
    function getEventsByTarget(address target) external view returns (SecurityEvent[] memory events);

    /**
     * @dev Struct representing a logged security event.
     */
    struct SecurityEvent {
        string eventType;
        address actor;
        address target;
        bytes32 detailsHash;
        uint256 timestamp;
    }
}