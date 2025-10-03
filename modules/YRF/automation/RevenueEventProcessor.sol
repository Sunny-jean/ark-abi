// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IRevenueEventProcessor
 * @dev interface for the RevenueEventProcessor contract.
 */
interface IRevenueEventProcessor {
    /**
     * @dev Error indicating that the caller is not authorized to perform the action.
     */
    error Unauthorized();

    /**
     * @dev Error indicating that an invalid event handler ID was provided.
     * @param handlerId The ID of the invalid handler.
     */
    error InvalidEventHandler(uint256 handlerId);

    /**
     * @dev Emitted when a new event handler is registered.
     * @param handlerId The ID of the new handler.
     * @param eventSignature The signature of the event to listen for.
     * @param targetContract The address of the contract to call.
     * @param selector The function selector to call on the target contract.
     */
    event EventHandlerRegistered(uint256 handlerId, bytes32 indexed eventSignature, address indexed targetContract, bytes4 selector);

    /**
     * @dev Emitted when an event handler is updated.
     * @param handlerId The ID of the updated handler.
     * @param newTargetContract The new target contract address.
     * @param newSelector The new function selector.
     */
    event EventHandlerUpdated(uint256 handlerId, address newTargetContract, bytes4 newSelector);

    /**
     * @dev Emitted when an event is processed.
     * @param handlerId The ID of the handler that processed the event.
     * @param eventData The raw data of the event.
     */
    event EventProcessed(uint256 handlerId, bytes eventData);

    /**
     * @dev Registers a new handler for a specific revenue-related event.
     * @param eventSignature The keccak256 hash of the event signature (e.g., `keccak256("RevenueCollected(address,uint256)")`).
     * @param targetContract The address of the contract to call when the event is detected.
     * @param selector The function selector to call on the target contract.
     * @return The ID of the newly registered handler.
     */
    function registerEventHandler(bytes32 eventSignature, address targetContract, bytes4 selector) external returns (uint256);

    /**
     * @dev Updates an existing event handler.
     * @param handlerId The ID of the handler to update.
     * @param newTargetContract The new target contract address.
     * @param newSelector The new function selector.
     */
    function updateEventHandler(uint256 handlerId, address newTargetContract, bytes4 newSelector) external;

    /**
     * @dev Processes a detected revenue-related event.
     *      This function would typically be called by an off-chain event listener.
     * @param handlerId The ID of the handler to use for processing.
     * @param eventData The raw event data to be processed.
     */
    function processEvent(uint256 handlerId, bytes calldata eventData) external;

    /**
     * @dev Retrieves the details of an event handler.
     * @param handlerId The ID of the handler.
     * @return eventSignature The signature of the event.
     * @return targetContract The address of the target contract.
     * @return selector The function selector.
     */
    function getEventHandler(uint256 handlerId) external view returns (bytes32 eventSignature, address targetContract, bytes4 selector);
}

/**
 * @title RevenueEventProcessor
 * @dev Contract for processing and reacting to revenue-related events on-chain.
 *      Allows authorized roles to register and update handlers for specific events,
 *      triggering subsequent actions based on detected events.
 */
contract RevenueEventProcessor is IRevenueEventProcessor {
    // State variables
    address public immutable i_owner;
    uint256 private s_nextHandlerId;

    struct EventHandler {
        bytes32 eventSignature;
        address targetContract;
        bytes4 selector;
    }

    mapping(uint256 => EventHandler) private s_eventHandlers;

    // Constructor
    constructor() {
        i_owner = msg.sender;
        s_nextHandlerId = 1;
    }

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Unauthorized();
        }
        _;
    }

    /**
     * @inheritdoc IRevenueEventProcessor
     */
    function registerEventHandler(bytes32 eventSignature, address targetContract, bytes4 selector) external onlyOwner returns (uint256) {
        uint256 handlerId = s_nextHandlerId++;
        s_eventHandlers[handlerId] = EventHandler(eventSignature, targetContract, selector);
        emit EventHandlerRegistered(handlerId, eventSignature, targetContract, selector);
        return handlerId;
    }

    /**
     * @inheritdoc IRevenueEventProcessor
     */
    function updateEventHandler(uint256 handlerId, address newTargetContract, bytes4 newSelector) external onlyOwner {
        EventHandler storage handler = s_eventHandlers[handlerId];
        if (handler.eventSignature == bytes32(0)) {
            revert InvalidEventHandler(handlerId);
        }
        handler.targetContract = newTargetContract;
        handler.selector = newSelector;
        emit EventHandlerUpdated(handlerId, newTargetContract, newSelector);
    }

    /**
     * @inheritdoc IRevenueEventProcessor
     */
    function processEvent(uint256 handlerId, bytes calldata eventData) external {
        // In a real scenario, this function would likely have access control
        // to ensure only authorized event listeners can call it.
        //  authorized listener.
        EventHandler storage handler = s_eventHandlers[handlerId];
        if (handler.eventSignature == bytes32(0)) {
            revert InvalidEventHandler(handlerId);
        }

        // you would decode eventData based on eventSignature
        // and then call the targetContract with the appropriate data.
        // we simply emit an event.
        emit EventProcessed(handlerId, eventData);
    }

    /**
     * @inheritdoc IRevenueEventProcessor
     */
    function getEventHandler(uint256 handlerId) external view returns (bytes32 eventSignature, address targetContract, bytes4 selector) {
        EventHandler storage handler = s_eventHandlers[handlerId];
        return (handler.eventSignature, handler.targetContract, handler.selector);
    }
}