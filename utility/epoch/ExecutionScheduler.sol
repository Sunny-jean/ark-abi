// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IExecutionScheduler {
    event TaskScheduled(bytes32 indexed taskId, uint256 indexed scheduledTime, address indexed target);
    event TaskExecuted(bytes32 indexed taskId);
    event TaskCancelled(bytes32 indexed taskId);

    error TaskNotFound(bytes32 taskId);
    error TaskAlreadyExecuted(bytes32 taskId);
    error TaskNotReadyForExecution(bytes32 taskId);

    function scheduleTask(address _target, bytes memory _data, uint256 _executionTime) external returns (bytes32);
    function executeTask(bytes32 _taskId) external;
    function cancelTask(bytes32 _taskId) external;
    function getTaskDetails(bytes32 _taskId) external view returns (address target, bytes memory data, uint256 executionTime, bool executed);
}