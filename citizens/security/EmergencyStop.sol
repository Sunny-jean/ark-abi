// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface EmergencyStop {
    /**
     * @dev Emitted when the emergency stop is activated.
     */
    event EmergencyStopActivated(address indexed activator);

    /**
     * @dev Emitted when the emergency stop is deactivated.
     */
    event EmergencyStopDeactivated(address indexed deactivator);

    /**
     * @dev Error when an unauthorized address tries to activate/deactivate the emergency stop.
     */
    error UnauthorizedEmergencyStop(address caller);

    /**
     * @dev Activates the emergency stop mechanism.
     * Only callable by authorized addresses.
     */
    function activateEmergencyStop() external;

    /**
     * @dev Deactivates the emergency stop mechanism.
     * Only callable by authorized addresses.
     */
    function deactivateEmergencyStop() external;

    /**
     * @dev Returns true if the emergency stop is active, false otherwise.
     */
    function isEmergencyStopActive() external view returns (bool);
}