// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IExecutionDelayController {
    event DelaySet(bytes32 indexed operationId, uint256 delaySeconds);
    event ExecutionScheduled(bytes32 indexed operationId, uint256 scheduledTime);

    error UnauthorizedController(address caller);
    error InvalidDelay(uint256 delaySeconds);

    function setExecutionDelay(bytes32 _operationId, uint256 _delaySeconds) external;
    function getExecutionDelay(bytes32 _operationId) external view returns (uint256);
    function isExecutionReady(bytes32 _operationId) external view returns (bool);
}