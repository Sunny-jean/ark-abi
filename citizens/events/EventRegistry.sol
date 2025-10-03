// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface EventRegistry {
    /**
     * @dev Emitted when a new event is registered.
     */
    event EventRegistered(uint256 indexed eventId, string indexed name, uint256 timestamp, bytes metadata);

    /**
     * @dev Emitted when an event's status is updated.
     */
    event EventStatusUpdated(uint256 indexed eventId, string newStatus);

    /**
     * @dev Error when an event is not found.
     */
    error EventNotFound(uint256 eventId);

    /**
     * @dev Error when an unauthorized address tries to modify an event.
     */
    error UnauthorizedEventModification(uint256 eventId, address caller);

    /**
     * @dev Registers a new event.
     * @param name The name of the event.
     * @param timestamp The timestamp of the event.
     * @param metadata Additional metadata for the event.
     * @return The ID of the registered event.
     */
    function registerEvent(string calldata name, uint256 timestamp, bytes calldata metadata) external returns (uint256);

    /**
     * @dev Updates the status of an existing event.
     * @param eventId The ID of the event to update.
     * @param newStatus The new status of the event.
     */
    function updateEventStatus(uint256 eventId, string calldata newStatus) external;

    /**
     * @dev Retrieves the details of a registered event.
     * @param eventId The ID of the event.
     * @return name The name of the event.
     * @return timestamp The timestamp of the event.
     * @return metadata Additional metadata for the event.
     * @return status The current status of the event.
     */
    function getEventDetails(uint256 eventId) external view returns (
        string memory name,
        uint256 timestamp,
        bytes memory metadata,
        string memory status
    );
}