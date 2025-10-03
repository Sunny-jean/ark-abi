// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEmergencyBrakeModule {
    event EmergencyBrakeActivated(uint256 timestamp);
    event EmergencyBrakeDeactivated(uint256 timestamp);

    error AlreadyInEmergency(string message);
    error NotInEmergency(string message);

    function activateEmergencyBrake() external;
    function deactivateEmergencyBrake() external;
    function isEmergencyActive() external view returns (bool);
}