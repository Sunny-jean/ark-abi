// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface EmergencyShutdown {
    /**
     * @dev Emitted when the emergency shutdown is activated.
     * @param initiator The address that initiated the shutdown.
     * @param timestamp The time of shutdown activation.
     */
    event ShutdownActivated(address indexed initiator, uint256 timestamp);

    /**
     * @dev Emitted when the emergency shutdown is deactivated.
     * @param initiator The address that deactivated the shutdown.
     * @param timestamp The time of shutdown deactivation.
     */
    event ShutdownDeactivated(address indexed initiator, uint256 timestamp);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when the system is already in the requested state (e.g., trying to activate an already active shutdown).
     */
    error InvalidState();

    /**
     * @dev Activates the emergency shutdown mechanism, pausing critical functions.
     */
    function activateShutdown() external;

    /**
     * @dev Deactivates the emergency shutdown mechanism, resuming normal operations.
     */
    function deactivateShutdown() external;

    /**
     * @dev Checks if the emergency shutdown is currently active.
     * @return isActive True if shutdown is active, false otherwise.
     */
    function isShutdownActive() external view returns (bool isActive);
}