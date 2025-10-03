// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAIAgent {
    /**
     * @dev Emitted when an AI agent initiates a task.
     * @param taskId A unique identifier for the task.
     * @param taskType The type of task being executed.
     * @param initiatedBy The address that initiated the task.
     */
    event TaskInitiated(bytes32 taskId, string taskType, address initiatedBy);

    /**
     * @dev Emitted when an AI agent completes a task.
     * @param taskId The unique identifier for the task.
     * @param status The completion status (e.g., "Success", "Failed", "Partial").
     * @param resultHash A hash of the task's results.
     */
    event TaskCompleted(bytes32 taskId, string status, bytes32 resultHash);

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
     * @dev Thrown when a task execution fails.
     */
    error TaskExecutionFailed(bytes32 taskId, string reason);

    /**
     * @dev Executes a specific task or operation using the AI agent's capabilities.
     * The interpretation of `taskParameters` and `taskResults` depends on the specific agent's implementation.
     * @param taskType The type of task to execute (e.g., "AnalyzeData", "OptimizeStrategy", "ExecuteTrade").
     * @param taskParameters Parameters required for the task, encoded as bytes.
     * @return taskId A unique identifier for the initiated task.
     */
    function executeTask(string calldata taskType, bytes calldata taskParameters) external returns (bytes32 taskId);

    /**
     * @dev Retrieves the current status and results of a previously initiated task.
     * @param taskId The unique identifier for the task.
     * @return status The current status of the task (e.g., "Pending", "InProgress", "Completed", "Failed").
     * @return resultHash A hash of the task's results if completed, otherwise zero.
     * @return message A descriptive message about the task status or error.
     */
    function getTaskStatus(bytes32 taskId) external view returns (string memory status, bytes32 resultHash, string memory message);

    /**
     * @dev Allows for configuration updates to the AI agent.
     * @param configHash A hash of the new configuration data.
     */
    function updateConfiguration(bytes32 configHash) external;

    /**
     * @dev Pauses the AI agent's operations.
     */
    function pause() external;

    /**
     * @dev Resumes the AI agent's operations.
     */
    function resume() external;
}