// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISystemEventTracker {
    event SystemEvent(string indexed eventType, bytes data, uint256 timestamp);

    function trackEvent(string memory _eventType, bytes memory _data) external;
}