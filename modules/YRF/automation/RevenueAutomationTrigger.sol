// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IRevenueAutomationTrigger
 * @dev interface for the RevenueAutomationTrigger contract.
 */
interface IRevenueAutomationTrigger {
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
     * @param targetContract The address of the contract to call.
     * @param selector The function selector to call on the target contract.
     */
    event AutomationTaskRegistered(uint256 taskId, string description, address indexed targetContract, bytes4 selector);

    /**
     * @dev Emitted when an automation task is updated.
     * @param taskId The ID of the updated task.
     * @param newDescription The new description of the task.
     */
    event AutomationTaskUpdated(uint256 taskId, string newDescription);

    /**
     * @dev Emitted when an automation task is triggered.
     * @param taskId The ID of the triggered task.
     * @param triggerTime The timestamp when the task was triggered.
     */
    event AutomationTaskTriggered(uint256 taskId, uint256 triggerTime);

    /**
     * @dev Registers a new automated revenue process task.
     * @param description A description of the task.
     * @param targetContract The address of the contract to call when triggered.
     * @param selector The function selector to call on the target contract.
     * @return The ID of the newly registered task.
     */
    function registerAutomationTask(string calldata description, address targetContract, bytes4 selector) external returns (uint256);

    /**
     * @dev Updates an existing automated revenue process task.
     * @param taskId The ID of the task to update.
     * @param newDescription The new description for the task.
     */
    function updateAutomationTask(uint256 taskId, string calldata newDescription) external;

    /**
     * @dev Triggers an automated revenue process task.
     *      This function would typically be called by an off-chain automation bot (e.g., Chainlink Keepers).
     * @param taskId The ID of the task to trigger.
     * @param callData The calldata to pass to the target contract.
     */
    function triggerAutomationTask(uint256 taskId, bytes calldata callData) external;

    /**
     * @dev Retrieves the details of an automation task.
     * @param taskId The ID of the task.
     * @return description The description of the task.
     * @return targetContract The address of the target contract.
     * @return selector The function selector.
     */
    function getAutomationTask(uint256 taskId) external view returns (string memory description, address targetContract, bytes4 selector);
}

/**
 * @title RevenueAutomationTrigger
 * @dev Contract for managing and triggering automated revenue processes.
 *      Allows authorized roles to register, update, and trigger various tasks
 *      that automate revenue-related operations.
 */
contract RevenueAutomationTrigger is IRevenueAutomationTrigger {
    // State variables
    address public immutable i_owner;
    uint256 private s_nextTaskId;

    struct AutomationTask {
        string description;
        address targetContract;
        bytes4 selector;
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
     * @inheritdoc IRevenueAutomationTrigger
     */
    function registerAutomationTask(string calldata description, address targetContract, bytes4 selector) external onlyOwner returns (uint256) {
        uint256 taskId = s_nextTaskId++;
        s_automationTasks[taskId] = AutomationTask(description, targetContract, selector);
        emit AutomationTaskRegistered(taskId, description, targetContract, selector);
        return taskId;
    }

    /**
     * @inheritdoc IRevenueAutomationTrigger
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
     * @inheritdoc IRevenueAutomationTrigger
     */
    function triggerAutomationTask(uint256 taskId, bytes calldata callData) external {
        // In a real scenario, this function would likely have access control
        // to ensure only authorized automation bots can call it.
        //  authorized bot.
        AutomationTask storage task = s_automationTasks[taskId];
        if (bytes(task.description).length == 0) {
            revert InvalidAutomationTask(taskId);
        }

        // Perform the external call to the target contract
        (bool success,) = task.targetContract.call(abi.encodePacked(task.selector, callData));
        require(success, "Automation task failed");

        emit AutomationTaskTriggered(taskId, block.timestamp);
    }

    /**
     * @inheritdoc IRevenueAutomationTrigger
     */
    function getAutomationTask(uint256 taskId) external view returns (string memory description, address targetContract, bytes4 selector) {
        AutomationTask storage task = s_automationTasks[taskId];
        return (task.description, task.targetContract, task.selector);
    }
}