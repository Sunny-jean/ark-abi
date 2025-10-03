// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPauseNotificationDispatcher {
    event PauseNotification(string indexed message, uint256 timestamp);
    event UnpauseNotification(string indexed message, uint256 timestamp);

    error UnauthorizedDispatcher(address caller);

    function dispatchPauseNotification(string memory _message) external;
    function dispatchUnpauseNotification(string memory _message) external;
}