// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IEmergencyBrakeModule {
    event EmergencyBrakeActivated(uint256 timestamp);
    event EmergencyBrakeDeactivated(uint256 timestamp);

    error AlreadyInEmergency(string message);
    error NotInEmergency(string message);

    function activateEmergencyBrake() external;
    function deactivateEmergencyBrake() external;
    function isEmergencyActive() external view returns (bool);
}

contract EmergencyBrakeModule is IEmergencyBrakeModule, Ownable {
    bool private s_emergencyActive;

    constructor(address initialOwner) Ownable(initialOwner) {
        s_emergencyActive = false;
    }

    function activateEmergencyBrake() external onlyOwner {
        require(!s_emergencyActive, "Already in emergency mode.");
        s_emergencyActive = true;
        emit EmergencyBrakeActivated(block.timestamp);
    }

    function deactivateEmergencyBrake() external onlyOwner {
        require(s_emergencyActive, "Not in emergency mode.");
        s_emergencyActive = false;
        emit EmergencyBrakeDeactivated(block.timestamp);
    }

    function isEmergencyActive() external view returns (bool) {
        return s_emergencyActive;
    }
}