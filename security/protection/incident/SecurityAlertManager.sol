// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISecurityAlertManager {
    event AlertRaised(uint256 indexed alertId, string message, uint256 severity);
    event AlertDismissed(uint256 indexed alertId);

    error UnauthorizedAccess(address caller);
    error AlertNotFound(uint256 alertId);

    function raiseAlert(string memory _message, uint256 _severity) external returns (uint256);
    function dismissAlert(uint256 _alertId) external;
    function getAlertDetails(uint256 _alertId) external view returns (string memory message, uint256 severity, bool active);
}