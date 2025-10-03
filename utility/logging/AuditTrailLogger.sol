// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAuditTrailLogger {
    event AuditLog(address indexed caller, string indexed action, bytes data, uint256 timestamp);

    function logAction(string memory _action, bytes memory _data) external;
}