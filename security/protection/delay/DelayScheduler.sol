// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDelayScheduler {
    event TaskScheduled(bytes32 indexed taskId, uint256 executeAt, bytes data);
    event TaskExecuted(bytes32 indexed taskId);

    error UnauthorizedScheduler(address caller);
    error TaskNotFound(bytes32 taskId);
    error TaskNotReady(bytes32 taskId);

    function scheduleTask(bytes32 _taskId, uint256 _delaySeconds, bytes calldata _data) external;
    function executeTask(bytes32 _taskId) external;
    function getScheduledTask(bytes32 _taskId) external view returns (uint256 executeAt, bytes memory data);
}