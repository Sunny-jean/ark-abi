// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRunwayAlertManager {
    event AlertTriggered(string indexed alertType, string indexed message, uint256 timestamp);

    error AlertFailed(string message);

    function triggerAlert(string calldata _alertType, string calldata _message) external;
    function getAlertStatus(string calldata _alertType) external view returns (bool isActive, uint256 lastTriggered);
}