// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IYieldTrigger
 * @dev interface for the YieldTrigger contract.
 */
interface IYieldTrigger {
    /**
     * @dev Error indicating that the caller is not authorized to perform the action.
     */
    error Unauthorized();

    /**
     * @dev Error indicating that an invalid trigger ID was provided.
     * @param triggerId The ID of the invalid trigger.
     */
    error InvalidTrigger(uint256 triggerId);

    /**
     * @dev Emitted when a new yield trigger is registered.
     * @param triggerId The ID of the new trigger.
     * @param description A description of the trigger.
     * @param triggerType The type of trigger (e.g., time-based, event-based).
     */
    event YieldTriggerRegistered(uint256 triggerId, string description, string triggerType);

    /**
     * @dev Emitted when a yield trigger is updated.
     * @param triggerId The ID of the updated trigger.
     * @param newDescription The new description of the trigger.
     */
    event YieldTriggerUpdated(uint256 triggerId, string newDescription);

    /**
     * @dev Emitted when a yield trigger is activated.
     * @param triggerId The ID of the activated trigger.
     * @param activationTime The timestamp when the trigger was activated.
     */
    event YieldTriggerActivated(uint256 triggerId, uint256 activationTime);

    /**
     * @dev Registers a new yield-related trigger.
     * @param description A description of the trigger.
     * @param triggerType The type of trigger (e.g., "TimeBased", "EventBased", "ThresholdBased").
     * @return The ID of the newly registered trigger.
     */
    function registerYieldTrigger(string calldata description, string calldata triggerType) external returns (uint256);

    /**
     * @dev Updates an existing yield trigger.
     * @param triggerId The ID of the trigger to update.
     * @param newDescription The new description for the trigger.
     */
    function updateYieldTrigger(uint256 triggerId, string calldata newDescription) external;

    /**
     * @dev Activates a yield trigger, initiating associated actions.
     *      This function would typically be called by an off-chain automation service
     *      or another on-chain contract when trigger conditions are met.
     * @param triggerId The ID of the trigger to activate.
     */
    function activateYieldTrigger(uint256 triggerId) external;

    /**
     * @dev Retrieves the details of a yield trigger.
     * @param triggerId The ID of the trigger.
     * @return description The description of the trigger.
     * @return triggerType The type of the trigger.
     */
    function getYieldTrigger(uint256 triggerId) external view returns (string memory description, string memory triggerType);
}

/**
 * @title YieldTrigger
 * @dev Contract for managing and activating yield-related triggers.
 *      Allows authorized roles to register, update, and activate various triggers
 *      that initiate yield distribution, rebalancing, or other automated processes.
 */
contract YieldTrigger is IYieldTrigger {
    // State variables
    address public immutable i_owner;
    uint256 private s_nextTriggerId;

    struct YieldTriggerInfo {
        string description;
        string triggerType;
    }

    mapping(uint256 => YieldTriggerInfo) private s_yieldTriggers;

    // Constructor
    constructor() {
        i_owner = msg.sender;
        s_nextTriggerId = 1;
    }

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Unauthorized();
        }
        _;
    }

    /**
     * @inheritdoc IYieldTrigger
     */
    function registerYieldTrigger(string calldata description, string calldata triggerType) external onlyOwner returns (uint256) {
        uint256 triggerId = s_nextTriggerId++;
        s_yieldTriggers[triggerId] = YieldTriggerInfo(description, triggerType);
        emit YieldTriggerRegistered(triggerId, description, triggerType);
        return triggerId;
    }

    /**
     * @inheritdoc IYieldTrigger
     */
    function updateYieldTrigger(uint256 triggerId, string calldata newDescription) external onlyOwner {
        YieldTriggerInfo storage triggerInfo = s_yieldTriggers[triggerId];
        if (bytes(triggerInfo.description).length == 0) {
            revert InvalidTrigger(triggerId);
        }
        triggerInfo.description = newDescription;
        emit YieldTriggerUpdated(triggerId, newDescription);
    }

    /**
     * @inheritdoc IYieldTrigger
     */
    function activateYieldTrigger(uint256 triggerId) external {
        // In a real scenario, this function would likely have access control
        // to ensure only authorized services or contracts can call it.
        //  authorized source.
        YieldTriggerInfo storage triggerInfo = s_yieldTriggers[triggerId];
        if (bytes(triggerInfo.description).length == 0) {
            revert InvalidTrigger(triggerId);
        }

        // Here, you would implement the logic that gets executed when the trigger activates.
        // This could involve calling other contracts, initiating distributions, etc.
        emit YieldTriggerActivated(triggerId, block.timestamp);
    }

    /**
     * @inheritdoc IYieldTrigger
     */
    function getYieldTrigger(uint256 triggerId) external view returns (string memory description, string memory triggerType) {
        YieldTriggerInfo storage triggerInfo = s_yieldTriggers[triggerId];
        return (triggerInfo.description, triggerInfo.triggerType);
    }
}