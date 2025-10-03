// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITimelockHelper {
    event OperationScheduled(bytes32 indexed operationId, uint256 indexed eta, address indexed target);
    event OperationExecuted(bytes32 indexed operationId);
    event OperationCancelled(bytes32 indexed operationId);

    error OperationAlreadyScheduled(bytes32 operationId);
    error OperationNotScheduled(bytes32 operationId);
    error OperationNotReady(bytes32 operationId);
    error OperationAlreadyExecuted(bytes32 operationId);

    function schedule(address _target, uint256 _value, string memory _signature, bytes memory _data, uint256 _eta) external returns (bytes32);
    function execute(address _target, uint256 _value, string memory _signature, bytes memory _data, uint256 _eta) external payable;
    function cancel(bytes32 _operationId) external;
    function getTimestamp(bytes32 _operationId) external view returns (uint256);
}