// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAuditTrail {
    function recordAction(address _actor, string calldata _action, bytes calldata _details) external;
    function getActionRecord(uint256 _recordId) external view returns (address actor, string memory action, bytes memory details, uint256 timestamp);

    event ActionRecorded(uint256 indexed recordId, address indexed actor, string action, uint256 timestamp);

    error RecordNotFound();
}