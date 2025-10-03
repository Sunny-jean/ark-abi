// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRunwayAlertManager {
    event AlertTriggered(string indexed alertType, string indexed message, uint256 timestamp);

    error AlertFailed(string message);

    function triggerAlert(string calldata _alertType, string calldata _message) external;
    function setAlertThreshold(string calldata _alertType, uint256 _threshold) external;
}

contract RunwayAlertManager is IRunwayAlertManager, Ownable {
    mapping(string => uint256) private s_alertThresholds;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function triggerAlert(string calldata _alertType, string calldata _message) external onlyOwner {

        // This would involve checking thresholds and dispatching alerts.
        bool success = true; // Simulate alert success
        if (!success) {
            revert AlertFailed("Failed to trigger alert.");
        }
        emit AlertTriggered(_alertType, _message, block.timestamp);
    }

    function setAlertThreshold(string calldata _alertType, uint256 _threshold) external onlyOwner {
        s_alertThresholds[_alertType] = _threshold;
    }
}