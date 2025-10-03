// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IExecutionTimingManager {
    event ExecutionWindowSet(bytes32 indexed operationId, uint256 startTime, uint256 endTime);
    event ExecutionAttempted(bytes32 indexed operationId, uint256 timestamp);

    error UnauthorizedManager(address caller);
    error OutsideExecutionWindow(bytes32 operationId);

    function setExecutionWindow(bytes32 _operationId, uint256 _startTime, uint256 _endTime) external;
    function checkExecutionWindow(bytes32 _operationId) external view returns (bool);
    function getExecutionWindow(bytes32 _operationId) external view returns (uint256 startTime, uint256 endTime);
}