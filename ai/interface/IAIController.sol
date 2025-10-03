// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAIController {
    /**
     * @dev Emitted when an AI component is registered with the controller.
     * @param componentId A unique identifier for the AI component.
     * @param componentAddress The address of the AI component contract.
     * @param componentType The type of AI component (e.g., "Model", "Agent", "Oracle").
     */
    event AIComponentRegistered(bytes32 componentId, address componentAddress, string componentType);

    /**
     * @dev Emitted when a command is sent to an AI component.
     * @param componentId The ID of the target AI component.
     * @param commandType The type of command sent.
     * @param commandHash A hash of the command parameters.
     */
    event CommandSent(bytes32 componentId, string commandType, bytes32 commandHash);

    /**
     * @dev Emitted when an AI component reports its status.
     * @param componentId The ID of the reporting AI component.
     * @param status The reported status (e.g., "Active", "Idle", "Error").
     * @param message A descriptive message about the status.
     */
    event ComponentStatusReported(bytes32 componentId, string status, string message);

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
     * @dev Thrown when an AI component is not found.
     */
    error ComponentNotFound(bytes32 componentId);

    /**
     * @dev Registers an AI component with the controller.
     * This allows the controller to manage and interact with the component.
     * @param componentId A unique identifier for the AI component.
     * @param componentAddress The address of the AI component contract.
     * @param componentType The type of AI component (e.g., "Model", "Agent", "Oracle").
     */
    function registerAIComponent(bytes32 componentId, address componentAddress, string calldata componentType) external;

    /**
     * @dev Sends a command to a registered AI component.
     * The command and its parameters are specific to the target AI component.
     * @param componentId The unique identifier of the target AI component.
     * @param commandType The type of command to send (e.g., "Execute", "UpdateConfig", "Query").
     * @param commandParameters Parameters for the command, encoded as bytes.
     * @return success True if the command was successfully sent/processed by the component.
     */
    function sendCommandToAI(bytes32 componentId, string calldata commandType, bytes calldata commandParameters) external returns (bool success);

    /**
     * @dev Retrieves the address of a registered AI component.
     * @param componentId The unique identifier for the AI component.
     * @return componentAddress The address of the AI component contract.
     */
    function getAIComponentAddress(bytes32 componentId) external view returns (address componentAddress);

    /**
     * @dev Deregisters an AI component from the controller.
     * @param componentId The unique identifier for the AI component to deregister.
     */
    function deregisterAIComponent(bytes32 componentId) external;
}