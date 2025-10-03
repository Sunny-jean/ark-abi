// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRunwayEmergencyController {
    event EmergencyModeToggled(bool indexed enabled, uint256 timestamp);
    event EmergencyActionDispatched(string indexed actionType, uint256 timestamp);

    error EmergencyActionFailed(string message);

    function toggleEmergencyMode(bool _enable) external;
    function dispatchEmergencyAction(string calldata _actionType) external;
    function isEmergencyModeActive() external view returns (bool);
}

contract RunwayEmergencyController is IRunwayEmergencyController, Ownable {
    bool private s_emergencyModeActive;

    constructor(address initialOwner) Ownable(initialOwner) {
        s_emergencyModeActive = false;
    }

    function toggleEmergencyMode(bool _enable) external onlyOwner {
        s_emergencyModeActive = _enable;
        emit EmergencyModeToggled(_enable, block.timestamp);
    }

    function dispatchEmergencyAction(string calldata _actionType) external onlyOwner {
        require(s_emergencyModeActive, "Emergency mode is not active.");

        // This would involve calling functions on other modules based on _actionType.
        if (keccak256(abi.encodePacked(_actionType)) == keccak256(abi.encodePacked("Rebond"))) {
            // Simulate calling rebonding function
            bool success = true;
            if (!success) {
                revert EmergencyActionFailed("Rebond action failed.");
            }
        } else if (keccak256(abi.encodePacked(_actionType)) == keccak256(abi.encodePacked("Notify"))) {
            // Simulate calling notification function
            bool success = true;
            if (!success) {
                revert EmergencyActionFailed("Notification action failed.");
            }
        } else {
            revert EmergencyActionFailed("Unknown emergency action type.");
        }
        emit EmergencyActionDispatched(_actionType, block.timestamp);
    }

    function isEmergencyModeActive() external view returns (bool) {
        return s_emergencyModeActive;
    }
}