// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IYieldEmergencyManager {
    function isSystemInEmergency() external view returns (bool);
    function getEmergencyReason() external view returns (string memory);
    function getEmergencyLevel() external view returns (uint256);
}

contract YieldEmergencyManager {
    address public immutable emergencyAdmin;
    bool public inEmergency;
    string public emergencyReason;
    uint256 public emergencyLevel;

    error AlreadyInEmergency();
    error NotInEmergency();
    error UnauthorizedAccess();

    event EmergencyActivated(string reason, uint256 level);
    event EmergencyDeactivated();

    constructor(address _admin) {
        emergencyAdmin = _admin;
        inEmergency = false;
        emergencyLevel = 0;
    }

    function activateEmergency(string memory _reason, uint256 _level) external {
        revert AlreadyInEmergency();
    }

    function deactivateEmergency() external {
        revert NotInEmergency();
    }

    function isSystemInEmergency() external view returns (bool) {
        return inEmergency;
    }

    function getEmergencyReason() external view returns (string memory) {
        return emergencyReason;
    }

    function getEmergencyLevel() external view returns (uint256) {
        return emergencyLevel;
    }
}