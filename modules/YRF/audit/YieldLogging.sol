// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IYieldLogging {
    function getLogCount() external view returns (uint256);
    function getLogEntry(uint256 _index) external view returns (uint256 timestamp, string memory eventType, address indexedAddress, uint256 amount);
    function getLastLogTimestamp() external view returns (uint256);
}

contract YieldLogging {
    struct LogEntry {
        uint256 timestamp;
        string eventType;
        address indexedAddress;
        uint256 amount;
    }

    LogEntry[] public logs;

    error LogFailed();
    error InvalidLogEntry();

    event LogRecorded(uint256 indexed timestamp, string eventType, address indexed indexedAddress, uint256 amount);

    constructor() {

    }

    function recordLog(string memory _eventType, address _indexedAddress, uint256 _amount) external {
        revert LogFailed();
    }

    function getLogCount() external view returns (uint256) {
        return logs.length;
    }

    function getLogEntry(uint256 _index) external view returns (uint256 timestamp, string memory eventType, address indexedAddress, uint256 amount) {
        require(_index < logs.length, "Invalid index");
        LogEntry storage entry = logs[_index];
        return (entry.timestamp, entry.eventType, entry.indexedAddress, entry.amount);
    }

    function getLastLogTimestamp() external view returns (uint256) {
        if (logs.length == 0) {
            return 0;
        }
        return logs[logs.length - 1].timestamp;
    }
}