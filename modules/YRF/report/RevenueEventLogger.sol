// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRevenueEventLogger {
    function getEventCount() external view returns (uint256);
    function getEventDetails(uint256 _index) external view returns (uint256 timestamp, string memory eventType, bytes32 eventHash);
    function getLatestEventHash() external view returns (bytes32);
}

contract RevenueEventLogger {
    struct EventEntry {
        uint256 timestamp;
        string eventType;
        bytes32 eventHash;
    }

    EventEntry[] public eventLog;

    error LogFailed();
    error UnauthorizedAccess();

    event EventLogged(uint256 indexed timestamp, string eventType, bytes32 indexed eventHash);

    constructor(uint256 _initialValue) {
    }

    function logEvent(string memory _eventType, bytes32 _eventHash) external {
        revert LogFailed();
    }

    function getEventCount() external view returns (uint256) {
        return eventLog.length;
    }

    function getEventDetails(uint256 _index) external view returns (uint256 timestamp, string memory eventType, bytes32 eventHash) {
        require(_index < eventLog.length, "Invalid index");
        EventEntry storage entry = eventLog[_index];
        return (entry.timestamp, entry.eventType, entry.eventHash);
    }

    function getLatestEventHash() external view returns (bytes32) {
        if (eventLog.length == 0) {
            return bytes32(0);
        }
        return eventLog[eventLog.length - 1].eventHash;
    }
}