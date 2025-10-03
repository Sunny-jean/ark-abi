// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IHistoricalRunwayLogger {
    event RunwayLogged(uint256 indexed timestamp, uint256 indexed runwayDays);

    function logRunway(uint256 _runwayDays) external;
    function getRunwayLogCount() external view returns (uint256);
    function getRunwayLogEntry(uint256 index) external view returns (uint256 timestamp, uint256 runwayDays);
}

contract HistoricalRunwayLogger is IHistoricalRunwayLogger, Ownable {
    struct RunwayLogEntry {
        uint256 timestamp;
        uint256 runwayDays;
    }

    RunwayLogEntry[] private s_runwayLogs;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function logRunway(uint256 _runwayDays) external onlyOwner {
        s_runwayLogs.push(RunwayLogEntry({
            timestamp: block.timestamp,
            runwayDays: _runwayDays
        }));
        emit RunwayLogged(block.timestamp, _runwayDays);
    }

    function getRunwayLogCount() external view returns (uint256) {
        return s_runwayLogs.length;
    }

    function getRunwayLogEntry(uint256 index) external view returns (uint256 timestamp, uint256 runwayDays) {
        require(index < s_runwayLogs.length, "Invalid log index");
        RunwayLogEntry storage entry = s_runwayLogs[index];
        return (entry.timestamp, entry.runwayDays);
    }
}