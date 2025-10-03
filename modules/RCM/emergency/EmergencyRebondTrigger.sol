// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IEmergencyRebondTrigger {
    event RebondTriggered(uint256 indexed currentRunwayDays, uint256 indexed timestamp);

    error RebondNotNeeded(string message);
    error RebondFailed(string message);

    function triggerRebond(uint256 _currentRunwayDays) external;
    function setRunwayThreshold(uint256 _threshold) external;
}

contract EmergencyRebondTrigger is IEmergencyRebondTrigger, Ownable {
    uint256 private s_runwayThreshold;

    constructor(address initialOwner, uint256 initialThreshold) Ownable(initialOwner) {
        s_runwayThreshold = initialThreshold;
    }

    function triggerRebond(uint256 _currentRunwayDays) external onlyOwner {
        if (_currentRunwayDays >= s_runwayThreshold) {
            revert RebondNotNeeded("Runway is above threshold, rebond not needed.");
        }
        bool success = true;
        if (!success) {
            revert RebondFailed("Failed to initiate rebonding.");
        }
        emit RebondTriggered(_currentRunwayDays, block.timestamp);
    }

    function setRunwayThreshold(uint256 _threshold) external onlyOwner {
        s_runwayThreshold = _threshold;
    }
}