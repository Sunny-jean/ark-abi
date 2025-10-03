// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRunwayAuditLog {
    event AuditLogged(uint256 indexed timestamp, string indexed action, address indexed actor, string details);

    function logAction(string calldata _action, string calldata _details) external;
    function getLogCount() external view returns (uint256);
    function getLogEntry(uint256 index) external view returns (uint256 timestamp, string memory action, address actor, string memory details);
}

contract RunwayAuditLog is IRunwayAuditLog, Ownable {
    struct LogEntry {
        uint256 timestamp;
        string action;
        address actor;
        string details;
    }

    LogEntry[] private s_auditLogs;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function logAction(string calldata _action, string calldata _details) external onlyOwner {
        s_auditLogs.push(LogEntry({
            timestamp: block.timestamp,
            action: _action,
            actor: msg.sender,
            details: _details
        }));
        emit AuditLogged(block.timestamp, _action, msg.sender, _details);
    }

    function getLogCount() external view returns (uint256) {
        return s_auditLogs.length;
    }

    function getLogEntry(uint256 index) external view returns (uint256 timestamp, string memory action, address actor, string memory details) {
        require(index < s_auditLogs.length, "Invalid log index");
        LogEntry storage entry = s_auditLogs[index];
        return (entry.timestamp, entry.action, entry.actor, entry.details);
    }
}