// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface Timelock {
    /**
     * @dev Emitted when a new operation is scheduled.
     */
    event CallScheduled(bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data, bytes32 predecessor, uint256 delay);

    /**
     * @dev Emitted when a scheduled operation is canceled.
     */
    event CallCanceled(bytes32 indexed id, uint256 indexed index, address target, uint256 value, bytes data, bytes32 predecessor, uint256 delay);

    /**
     * @dev Emitted when a scheduled operation is executed.
     */

    /**
     * @dev Emitted when the min delay is updated.
     */

    /**
     * @dev Error when an operation is not found.
     */
    error OperationNotFound(bytes32 id);

    /**
     * @dev Error when an operation is already scheduled.
     */
    error OperationAlreadyScheduled(bytes32 id);

    /**
     * @dev Error when an operation is not ready for execution.
     */
    error OperationNotReady(bytes32 id);

    /**
     * @dev Error when an operation is not pending.
     */
    error OperationNotPending(bytes32 id);

    /**
     * @dev Schedules an operation to be executed after a delay.
     * @param target The address of the target contract.
     * @param value The amount of native currency to send with the call.
     * @param data The calldata to send with the call.
     * @param predecessor The id of the operation that must be executed before this one.
     * @param salt A random value to prevent replay attacks.
     * @param delay The delay before the operation can be executed.
     * @return The id of the scheduled operation.
     */
    function schedule(address target, uint256 value, bytes calldata data, bytes32 predecessor, bytes32 salt, uint256 delay) external returns (bytes32);

    /**
     * @dev Cancels a scheduled operation.
     * @param id The id of the operation to cancel.
     */
    function cancel(bytes32 id) external;

    /**
     * @dev Executes a scheduled operation.
     * @param target The address of the target contract.
     * @param value The amount of native currency to send with the call.
     * @param data The calldata to send with the call.
     * @param predecessor The id of the operation that must be executed before this one.
     * @param salt A random value to prevent replay attacks.
     * @return The id of the executed operation.
     */
    function execute(address target, uint256 value, bytes calldata data, bytes32 predecessor, bytes32 salt) external returns (bytes32);

    /**
     * @dev Returns the minimum delay for operations.
     * @return The minimum delay.
     */
    function getMinDelay() external view returns (uint256);

    /**
     * @dev Returns the timestamp when an operation is ready for execution.
     * @param id The id of the operation.
     * @return The timestamp when the operation is ready.
     */
    function getTimestamp(bytes32 id) external view returns (uint256);

    /**
     * @dev Checks if an operation is scheduled.
     * @param id The id of the operation.
     * @return True if the operation is scheduled, false otherwise.
     */
    function isScheduled(bytes32 id) external view returns (bool);
}