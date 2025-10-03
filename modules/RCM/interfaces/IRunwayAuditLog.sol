// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRunwayAuditLog {
    event LogEntry(string indexed eventType, address indexed caller, uint256 timestamp, bytes data);

    function log(string calldata _eventType, address _caller, bytes calldata _data) external;
    function getLogEntry(uint256 _index) external view returns (string memory eventType, address caller, uint256 timestamp, bytes memory data);
    function getLogCount() external view returns (uint256);
}