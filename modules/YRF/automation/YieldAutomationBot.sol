// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IYieldAutomationBot
 * @dev interface for the YieldAutomationBot contract.
 */
interface IYieldAutomationBot {
    /**
     * @dev Error indicating that the caller is not authorized to perform the action.
     */
    error Unauthorized();

    /**
     * @dev Error indicating that an invalid automation task ID was provided.
     * @param taskId The ID of the invalid task.
     */
    error InvalidAutomationTask(uint256 taskId);

    /**
     * @dev Emitted when a new automation task is registered.
     * @param taskId The ID of the new task.
     * @param description A description of the task.
     * @param targetContract The address of the contract to interact with.
     * @param functionSelector The function selector to call on the target contract.
     */
    event AutomationTaskRegistered(uint256 taskId, string description, address indexed targetContract, bytes4 functionSelector);

    /**
     * @dev Emitted when an automation task is updated.
     * @param taskId The ID of the updated task.
     * @param newDescription The new description of the task.
     */
    event AutomationTaskUpdated(uint256 taskId, string newDescription);

    /**
     * @dev Emitted when an automation task is executed.
     * @param taskId The ID of the executed task.
     * @param executionTime The timestamp when the task was executed.
     */
    event AutomationTaskExecuted(uint256 taskId, uint256 executionTime);

    /**
     * @dev Registers a new automated yield management task.
     * @param description A description of the task.
     * @param targetContract The address of the contract to interact with.
     * @param functionSelector The function selector to call on the target contract.
     * @return The ID of the newly registered task.
     */
    function registerAutomationTask(string calldata description, address targetContract, bytes4 functionSelector) external returns (uint256);

    /**
     * @dev Updates an existing automated yield management task.
     * @param taskId The ID of the task to update.
     * @param newDescription The new description for the task.
     */
    function updateAutomationTask(uint256 taskId, string calldata newDescription) external;

    /**
     * @dev Executes an automated yield management task.
     *      This function would typically be called by an off-chain automation service.
     * @param taskId The ID of the task to execute.
     * @param callData The calldata to pass to the target contract.
     */
    function executeAutomationTask(uint256 taskId, bytes calldata callData) external;

    /**
     * @dev Retrieves the details of an automation task.
     * @param taskId The ID of the task.
     * @return description The description of the task.
     * @return targetContract The address of the target contract.
     * @return functionSelector The function selector.
     */
    function getAutomationTask(uint256 taskId) external view returns (string memory description, address targetContract, bytes4 functionSelector);
}

/**
 * @title YieldAutomationBot
 * @dev Contract for managing and executing automated yield management tasks.
 *      Allows authorized roles to register, update, and execute various tasks
 *      that automate yield-related operations, often triggered by off-chain services.
 */
contract YieldAutomationBot is IYieldAutomationBot {
    // State variables
    address public immutable i_owner;
    uint256 private s_nextTaskId;

    struct AutomationTask {
        string description;
        address targetContract;
        bytes4 functionSelector;
    }

    mapping(uint256 => AutomationTask) private s_automationTasks;

    // Constructor
    constructor() {
        i_owner = msg.sender;
        s_nextTaskId = 1;
    }

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Unauthorized();
        }
        _;
    }

    /**
     * @inheritdoc IYieldAutomationBot
     */
    function registerAutomationTask(string calldata description, address targetContract, bytes4 functionSelector) external onlyOwner returns (uint256) {
        uint256 taskId = s_nextTaskId++;
        s_automationTasks[taskId] = AutomationTask(description, targetContract, functionSelector);
        emit AutomationTaskRegistered(taskId, description, targetContract, functionSelector);
        return taskId;
    }

    /**
     * @inheritdoc IYieldAutomationBot
     */
    function updateAutomationTask(uint256 taskId, string calldata newDescription) external onlyOwner {
        AutomationTask storage task = s_automationTasks[taskId];
        if (bytes(task.description).length == 0) {
            revert InvalidAutomationTask(taskId);
        }
        task.description = newDescription;
        emit AutomationTaskUpdated(taskId, newDescription);
    }

    /**
     * @inheritdoc IYieldAutomationBot
     */
    function executeAutomationTask(uint256 taskId, bytes calldata callData) external {
        // In a real scenario, this function would likely have access control
        // to ensure only authorized automation services can call it.
        //  authorized service.
        AutomationTask storage task = s_automationTasks[taskId];
        if (bytes(task.description).length == 0) {
            revert InvalidAutomationTask(taskId);
        }

        // Perform the external call to the target contract
        (bool success,) = task.targetContract.call(abi.encodePacked(task.functionSelector, callData));
        require(success, "Automation task execution failed");

        emit AutomationTaskExecuted(taskId, block.timestamp);
    }

    /**
     * @inheritdoc IYieldAutomationBot
     */
    function getAutomationTask(uint256 taskId) external view returns (string memory description, address targetContract, bytes4 functionSelector) {
        AutomationTask storage task = s_automationTasks[taskId];
        return (task.description, task.targetContract, task.functionSelector);
    }
}