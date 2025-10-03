// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface Pausable {
    /**
     * @dev Emitted when the contract is paused.
     * @param account The address that paused the contract.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the contract is unpaused.
     * @param account The address that unpaused the contract.
     */
    event Unpaused(address account);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a function is called while the contract is paused.
     */
    error PausedState();

    /**
     * @dev Thrown when a function is called while the contract is not paused.
     */
    error NotPausedState();

    /**
     * @dev Pauses the contract, preventing certain functions from being called.
     */
    function pause() external;

    /**
     * @dev Unpauses the contract, allowing all functions to be called.
     */
    function unpause() external;

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() external view returns (bool);
}