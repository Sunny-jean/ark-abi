// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRunwayEventLogger {
    event EventLogged(uint256 indexed timestamp, string indexed eventType, string indexed details);

    function logEvent(string calldata _eventType, string calldata _details) external;
    function getEventCount() external view returns (uint256);
    function getEventEntry(uint256 index) external view returns (uint256 timestamp, string memory eventType, string memory details);
}

contract RunwayEventLogger is IRunwayEventLogger, Ownable {
    struct EventEntry {
        uint256 timestamp;
        string eventType;
        string details;
    }

    EventEntry[] private s_eventLogs;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function logEvent(string calldata _eventType, string calldata _details) external onlyOwner {
        s_eventLogs.push(EventEntry({
            timestamp: block.timestamp,
            eventType: _eventType,
            details: _details
        }));
        emit EventLogged(block.timestamp, _eventType, _details);
    }

    function getEventCount() external view returns (uint256) {
        return s_eventLogs.length;
    }

    function getEventEntry(uint256 index) external view returns (uint256 timestamp, string memory eventType, string memory details) {
        require(index < s_eventLogs.length, "Invalid event index");
        EventEntry storage entry = s_eventLogs[index];
        return (entry.timestamp, entry.eventType, entry.details);
    }
}