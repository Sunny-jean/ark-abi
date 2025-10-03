// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INotificationDispatcher {
    event NotificationDispatched(string indexed platform, address indexed recipient, string indexed message, uint256 timestamp);

    error DispatchFailed(string message);

    function dispatchNotification(string calldata _platform, address _recipient, string calldata _message) external;
    function getSupportedPlatforms() external view returns (string[] memory);
}