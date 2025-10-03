// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface TimeLock {
    /**
     * @dev Emitted when an operation is scheduled.
     * @param id The unique ID of the scheduled operation.
     * @param target The address of the target contract.
     * @param value The amount of Ether to send with the operation.
     * @param signature The function signature to call.
     * @param data The calldata for the function call.
     * @param eta The timestamp at which the operation can be executed.
     */
    event CallScheduled(bytes32 indexed id, address indexed target, uint256 value, bytes4 signature, bytes data, uint256 eta);

    /**
     * @dev Emitted when a scheduled operation is cancelled.
     * @param id The unique ID of the cancelled operation.
     */
    event CallCancelled(bytes32 indexed id);

    /**
     * @dev Emitted when a scheduled operation is executed.
     * @param id The unique ID of the executed operation.
     * @param target The address of the target contract.
     * @param value The amount of Ether sent with the operation.
     * @param signature The function signature called.
     * @param data The calldata for the function call.
     */
    event CallExecuted(bytes32 indexed id, address indexed target, uint256 value, bytes4 signature, bytes data);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a required parameter is missing or invalid.
     */
    error InvalidParameter(string parameterName, string description);

    /**
     * @dev Thrown when an operation is scheduled with an ETA that is too soon or too far in the future.
     */
    error InvalidETA(uint256 eta);

    /**
     * @dev Thrown when an operation is not ready for execution.
     */
    error CallNotReady(bytes32 id);

    /**
     * @dev Thrown when an operation with the given ID is not found or already executed/cancelled.
     */
    error CallNotFound(bytes32 id);

    /**
     * @dev Schedules an operation to be executed after a specified delay.
     * @param target The address of the target contract.
     * @param value The amount of Ether to send with the operation.
     * @param signature The function signature to call (e.g., `bytes4(keccak256("myFunction(uint256)"))`).
     * @param data The calldata for the function call.
     * @param eta The timestamp at which the operation can be executed.
     * @return id The unique ID of the scheduled operation.
     */
    function schedule(address target, uint256 value, bytes4 signature, bytes calldata data, uint256 eta) external returns (bytes32 id);

    /**
     * @dev Cancels a previously scheduled operation.
     * @param id The unique ID of the operation to cancel.
     */
    function cancel(bytes32 id) external;

    /**
     * @dev Executes a scheduled operation that has passed its `eta`.
     * @param id The unique ID of the operation to execute.
     */
    function execute(bytes32 id) external;

    /**
     * @dev Checks if an operation is scheduled and its current status.
     * @param id The unique ID of the operation.
     * @return isScheduled True if the operation is scheduled, false otherwise.
     * @return eta The timestamp at which the operation can be executed.
     * @return executed True if the operation has been executed, false otherwise.
     * @return cancelled True if the operation has been cancelled, false otherwise.
     */
    function getOperationState(bytes32 id) external view returns (bool isScheduled, uint256 eta, bool executed, bool cancelled);
}