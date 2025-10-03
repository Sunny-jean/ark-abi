// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Event Queue Manager
/// @notice Manages event queues for asynchronous event processing
interface IEventQueueManager {
    function enqueueEvent(bytes32 eventType_, bytes calldata data_) external returns (uint256);
    function dequeueEvent(uint256 queueId_, uint256 eventId_) external;
    function getQueueLength(uint256 queueId_) external view returns (uint256);
    function getNextEvent(uint256 queueId_) external view returns (uint256, bytes32, bytes memory);
}

contract EventQueueManager is IEventQueueManager {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event QueueCreated(uint256 indexed queueId, string name, address indexed owner);
    event QueueDeleted(uint256 indexed queueId);
    event EventEnqueued(uint256 indexed queueId, uint256 indexed eventId, bytes32 indexed eventType, bytes data);
    event EventDequeued(uint256 indexed queueId, uint256 indexed eventId);
    event EventProcessed(uint256 indexed queueId, uint256 indexed eventId, bool success);
    event QueuePaused(uint256 indexed queueId);
    event QueueResumed(uint256 indexed queueId);
    event QueueOwnerChanged(uint256 indexed queueId, address indexed oldOwner, address indexed newOwner);
    event ProcessorAdded(uint256 indexed queueId, address indexed processor);
    event ProcessorRemoved(uint256 indexed queueId, address indexed processor);
    event QueueManagerAdminChanged(address indexed oldAdmin, address indexed newAdmin);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error EventQueueManager_OnlyAdmin(address caller_);
    error EventQueueManager_OnlyQueueOwner(uint256 queueId_, address caller_);
    error EventQueueManager_OnlyProcessor(uint256 queueId_, address caller_);
    error EventQueueManager_InvalidAddress(address addr_);
    error EventQueueManager_QueueNotFound(uint256 queueId_);
    error EventQueueManager_QueuePaused(uint256 queueId_);
    error EventQueueManager_QueueNotPaused(uint256 queueId_);
    error EventQueueManager_EventNotFound(uint256 queueId_, uint256 eventId_);
    error EventQueueManager_QueueEmpty(uint256 queueId_);
    error EventQueueManager_QueueFull(uint256 queueId_);
    error EventQueueManager_ProcessorAlreadyAdded(uint256 queueId_, address processor_);
    error EventQueueManager_ProcessorNotFound(uint256 queueId_, address processor_);
    error EventQueueManager_InvalidQueueConfiguration();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct QueueConfig {
        string name;
        address owner;
        uint256 maxSize;
        bool isPaused;
        uint256 createdAt;
        uint256 processingTimeout; // Time in seconds after which an event can be reprocessed
    }

    struct QueuedEvent {
        uint256 id;
        bytes32 eventType;
        bytes data;
        uint256 enqueuedAt;
        bool isProcessing;
        uint256 processingStartedAt;
        bool isProcessed;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    
    // Queue management
    mapping(uint256 => QueueConfig) public queues;
    uint256 public queueCount;
    mapping(address => uint256[]) public queuesByOwner;
    
    // Event storage
    mapping(uint256 => QueuedEvent[]) public queuedEvents;
    mapping(uint256 => mapping(uint256 => uint256)) public eventIndexInQueue; // queueId => eventId => index
    mapping(uint256 => uint256) public nextEventId; // queueId => nextEventId
    
    // Processors
    mapping(uint256 => mapping(address => bool)) public isProcessor;
    mapping(uint256 => address[]) public processors;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert EventQueueManager_OnlyAdmin(msg.sender);
        _;
    }

    modifier onlyQueueOwner(uint256 queueId_) {
        if (!_queueExists(queueId_)) revert EventQueueManager_QueueNotFound(queueId_);
        if (msg.sender != queues[queueId_].owner) {
            revert EventQueueManager_OnlyQueueOwner(queueId_, msg.sender);
        }
        _;
    }

    modifier onlyProcessor(uint256 queueId_) {
        if (!_queueExists(queueId_)) revert EventQueueManager_QueueNotFound(queueId_);
        if (!isProcessor[queueId_][msg.sender] && msg.sender != queues[queueId_].owner) {
            revert EventQueueManager_OnlyProcessor(queueId_, msg.sender);
        }
        _;
    }

    modifier queueExists(uint256 queueId_) {
        if (!_queueExists(queueId_)) revert EventQueueManager_QueueNotFound(queueId_);
        _;
    }

    modifier queueNotPaused(uint256 queueId_) {
        if (!_queueExists(queueId_)) revert EventQueueManager_QueueNotFound(queueId_);
        if (queues[queueId_].isPaused) revert EventQueueManager_QueuePaused(queueId_);
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_) {
        if (admin_ == address(0)) revert EventQueueManager_InvalidAddress(admin_);
        
        admin = admin_;
        
        // Create default system queue
        _createQueue(
            "System Events",
            admin_,
            1000, // Max 1000 events
            3600  // 1 hour processing timeout
        );
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Enqueue an event
    /// @param eventType_ The event type
    /// @param data_ The event data
    /// @return The event ID
    function enqueueEvent(
        bytes32 eventType_,
        bytes calldata data_
    ) external override queueExists(0) queueNotPaused(0) returns (uint256) {
        return _enqueueEvent(0, eventType_, data_);
    }

    /// @notice Enqueue an event to a specific queue
    /// @param queueId_ The queue ID
    /// @param eventType_ The event type
    /// @param data_ The event data
    /// @return The event ID
    function enqueueEventToQueue(
        uint256 queueId_,
        bytes32 eventType_,
        bytes calldata data_
    ) external queueExists(queueId_) queueNotPaused(queueId_) returns (uint256) {
        return _enqueueEvent(queueId_, eventType_, data_);
    }

    /// @notice Dequeue an event
    /// @param queueId_ The queue ID
    /// @param eventId_ The event ID
    function dequeueEvent(
        uint256 queueId_,
        uint256 eventId_
    ) external override onlyProcessor(queueId_) queueExists(queueId_) {
        QueuedEvent[] storage events = queuedEvents[queueId_];
        
        // Check if event exists
        if (eventId_ >= nextEventId[queueId_]) revert EventQueueManager_EventNotFound(queueId_, eventId_);
        
        uint256 index = eventIndexInQueue[queueId_][eventId_];
        if (index >= events.length || events[index].id != eventId_) {
            revert EventQueueManager_EventNotFound(queueId_, eventId_);
        }
        
        // Mark as processing
        events[index].isProcessing = true;
        events[index].processingStartedAt = block.timestamp;
        
        emit EventDequeued(queueId_, eventId_);
    }

    /// @notice Mark an event as processed
    /// @param queueId_ The queue ID
    /// @param eventId_ The event ID
    /// @param success_ Whether processing was successful
    function markEventProcessed(
        uint256 queueId_,
        uint256 eventId_,
        bool success_
    ) external onlyProcessor(queueId_) queueExists(queueId_) {
        QueuedEvent[] storage events = queuedEvents[queueId_];
        
        // Check if event exists
        if (eventId_ >= nextEventId[queueId_]) revert EventQueueManager_EventNotFound(queueId_, eventId_);
        
        uint256 index = eventIndexInQueue[queueId_][eventId_];
        if (index >= events.length || events[index].id != eventId_) {
            revert EventQueueManager_EventNotFound(queueId_, eventId_);
        }
        
        // Check if event is being processed
        if (!events[index].isProcessing) revert EventQueueManager_EventNotFound(queueId_, eventId_);
        
        // Mark as processed
        events[index].isProcessed = true;
        
        // Remove from queue
        if (index < events.length - 1) {
            // Move the last element to the removed position
            events[index] = events[events.length - 1];
            // Update the index mapping for the moved event
            eventIndexInQueue[queueId_][events[index].id] = index;
        }
        
        // Remove the last element
        events.pop();
        
        emit EventProcessed(queueId_, eventId_, success_);
    }

    /// @notice Create a new queue
    /// @param name_ The queue name
    /// @param maxSize_ The maximum queue size
    /// @param processingTimeout_ The processing timeout in seconds
    /// @return The queue ID
    function createQueue(
        string calldata name_,
        uint256 maxSize_,
        uint256 processingTimeout_
    ) external returns (uint256) {
        return _createQueue(name_, msg.sender, maxSize_, processingTimeout_);
    }

    /// @notice Delete a queue
    /// @param queueId_ The queue ID
    function deleteQueue(uint256 queueId_) external onlyQueueOwner(queueId_) {
        if (queueId_ == 0) revert EventQueueManager_QueueNotFound(queueId_); // Can't delete system queue
        
        // Delete queue
        delete queues[queueId_];
        delete queuedEvents[queueId_];
        delete processors[queueId_];
        
        // Remove from owner's queues
        address owner = queues[queueId_].owner;
        uint256[] storage ownerQueues = queuesByOwner[owner];
        for (uint256 i = 0; i < ownerQueues.length; i++) {
            if (ownerQueues[i] == queueId_) {
                ownerQueues[i] = ownerQueues[ownerQueues.length - 1];
                ownerQueues.pop();
                break;
            }
        }
        
        emit QueueDeleted(queueId_);
    }

    /// @notice Pause a queue
    /// @param queueId_ The queue ID
    function pauseQueue(uint256 queueId_) external onlyQueueOwner(queueId_) {
        if (queues[queueId_].isPaused) revert EventQueueManager_QueuePaused(queueId_);
        
        queues[queueId_].isPaused = true;
        
        emit QueuePaused(queueId_);
    }

    /// @notice Resume a queue
    /// @param queueId_ The queue ID
    function resumeQueue(uint256 queueId_) external onlyQueueOwner(queueId_) {
        if (!queues[queueId_].isPaused) revert EventQueueManager_QueueNotPaused(queueId_);
        
        queues[queueId_].isPaused = false;
        
        emit QueueResumed(queueId_);
    }

    /// @notice Add a processor
    /// @param queueId_ The queue ID
    /// @param processor_ The processor address
    function addProcessor(uint256 queueId_, address processor_) external onlyQueueOwner(queueId_) {
        if (processor_ == address(0)) revert EventQueueManager_InvalidAddress(processor_);
        if (isProcessor[queueId_][processor_]) {
            revert EventQueueManager_ProcessorAlreadyAdded(queueId_, processor_);
        }
        
        isProcessor[queueId_][processor_] = true;
        processors[queueId_].push(processor_);
        
        emit ProcessorAdded(queueId_, processor_);
    }

    /// @notice Remove a processor
    /// @param queueId_ The queue ID
    /// @param processor_ The processor address
    function removeProcessor(uint256 queueId_, address processor_) external onlyQueueOwner(queueId_) {
        if (!isProcessor[queueId_][processor_]) {
            revert EventQueueManager_ProcessorNotFound(queueId_, processor_);
        }
        
        isProcessor[queueId_][processor_] = false;
        
        // Remove from array
        address[] storage queueProcessors = processors[queueId_];
        for (uint256 i = 0; i < queueProcessors.length; i++) {
            if (queueProcessors[i] == processor_) {
                queueProcessors[i] = queueProcessors[queueProcessors.length - 1];
                queueProcessors.pop();
                break;
            }
        }
        
        emit ProcessorRemoved(queueId_, processor_);
    }

    /// @notice Transfer queue ownership
    /// @param queueId_ The queue ID
    /// @param newOwner_ The new owner address
    function transferQueueOwnership(uint256 queueId_, address newOwner_) external onlyQueueOwner(queueId_) {
        if (newOwner_ == address(0)) revert EventQueueManager_InvalidAddress(newOwner_);
        
        address oldOwner = queues[queueId_].owner;
        queues[queueId_].owner = newOwner_;
        
        // Update owner mappings
        uint256[] storage oldOwnerQueues = queuesByOwner[oldOwner];
        for (uint256 i = 0; i < oldOwnerQueues.length; i++) {
            if (oldOwnerQueues[i] == queueId_) {
                oldOwnerQueues[i] = oldOwnerQueues[oldOwnerQueues.length - 1];
                oldOwnerQueues.pop();
                break;
            }
        }
        
        queuesByOwner[newOwner_].push(queueId_);
        
        emit QueueOwnerChanged(queueId_, oldOwner, newOwner_);
    }

    /// @notice Change the admin
    /// @param newAdmin_ The new admin address
    function changeAdmin(address newAdmin_) external onlyAdmin {
        if (newAdmin_ == address(0)) revert EventQueueManager_InvalidAddress(newAdmin_);
        
        address oldAdmin = admin;
        admin = newAdmin_;
        
        emit QueueManagerAdminChanged(oldAdmin, newAdmin_);
    }

    /// @notice Get the queue length
    /// @param queueId_ The queue ID
    /// @return The number of events in the queue
    function getQueueLength(uint256 queueId_) external view override queueExists(queueId_) returns (uint256) {
        return queuedEvents[queueId_].length;
    }

    /// @notice Get the next event in the queue
    /// @param queueId_ The queue ID
    /// @return eventId The event ID
    /// @return eventType The event type
    /// @return data The event data
    function getNextEvent(
        uint256 queueId_
    ) external view override queueExists(queueId_) returns (uint256, bytes32, bytes memory) {
        QueuedEvent[] storage events = queuedEvents[queueId_];
        
        if (events.length == 0) revert EventQueueManager_QueueEmpty(queueId_);
        
        // Find the first non-processing event or the oldest processing event that has timed out
        uint256 processingTimeout = queues[queueId_].processingTimeout;
        uint256 oldestProcessingIndex = 0;
        uint256 oldestProcessingTime = type(uint256).max;
        
        for (uint256 i = 0; i < events.length; i++) {
            if (!events[i].isProcessing) {
                // Found a non-processing event
                return (events[i].id, events[i].eventType, events[i].data);
            } else if (block.timestamp > events[i].processingStartedAt + processingTimeout) {
                // Found a processing event that has timed out
                if (events[i].processingStartedAt < oldestProcessingTime) {
                    oldestProcessingIndex = i;
                    oldestProcessingTime = events[i].processingStartedAt;
                }
            }
        }
        
        // If we found a timed out event
        if (oldestProcessingTime != type(uint256).max) {
            QueuedEvent storage event_ = events[oldestProcessingIndex];
            return (event_.id, event_.eventType, event_.data);
        }
        
        // All events are being processed and none have timed out
        revert EventQueueManager_QueueEmpty(queueId_);
    }

    /// @notice Get event details
    /// @param queueId_ The queue ID
    /// @param eventId_ The event ID
    /// @return id The event ID
    /// @return eventType The event type
    /// @return data The event data
    /// @return enqueuedAt When the event was enqueued
    /// @return isProcessing Whether the event is being processed
    /// @return processingStartedAt When processing started
    /// @return isProcessed Whether the event has been processed
    function getEventDetails(
        uint256 queueId_,
        uint256 eventId_
    ) external view queueExists(queueId_) returns (
        uint256 id,
        bytes32 eventType,
        bytes memory data,
        uint256 enqueuedAt,
        bool isProcessing,
        uint256 processingStartedAt,
        bool isProcessed
    ) {
        // Check if event exists
        if (eventId_ >= nextEventId[queueId_]) revert EventQueueManager_EventNotFound(queueId_, eventId_);
        
        QueuedEvent[] storage events = queuedEvents[queueId_];
        uint256 index = eventIndexInQueue[queueId_][eventId_];
        
        if (index >= events.length || events[index].id != eventId_) {
            revert EventQueueManager_EventNotFound(queueId_, eventId_);
        }
        
        QueuedEvent storage event_ = events[index];
        return (
            event_.id,
            event_.eventType,
            event_.data,
            event_.enqueuedAt,
            event_.isProcessing,
            event_.processingStartedAt,
            event_.isProcessed
        );
    }

    /// @notice Get queue details
    /// @param queueId_ The queue ID
    /// @return name The queue name
    /// @return owner The queue owner
    /// @return maxSize The maximum queue size
    /// @return isPaused Whether the queue is paused
    /// @return createdAt When the queue was created
    /// @return processingTimeout The processing timeout
    function getQueueDetails(uint256 queueId_) external view queueExists(queueId_) returns (
        string memory name,
        address owner,
        uint256 maxSize,
        bool isPaused,
        uint256 createdAt,
        uint256 processingTimeout
    ) {
        QueueConfig storage queue = queues[queueId_];
        return (
            queue.name,
            queue.owner,
            queue.maxSize,
            queue.isPaused,
            queue.createdAt,
            queue.processingTimeout
        );
    }

    /// @notice Get queues by owner
    /// @param owner_ The owner address
    /// @return Array of queue IDs
    function getQueuesByOwner(address owner_) external view returns (uint256[] memory) {
        return queuesByOwner[owner_];
    }

    /// @notice Get processors for a queue
    /// @param queueId_ The queue ID
    /// @return Array of processor addresses
    function getProcessors(uint256 queueId_) external view queueExists(queueId_) returns (address[] memory) {
        return processors[queueId_];
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Internal function to create a queue
    /// @param name_ The queue name
    /// @param owner_ The queue owner
    /// @param maxSize_ The maximum queue size
    /// @param processingTimeout_ The processing timeout
    /// @return The queue ID
    function _createQueue(
        string memory name_,
        address owner_,
        uint256 maxSize_,
        uint256 processingTimeout_
    ) internal returns (uint256) {
        if (owner_ == address(0)) revert EventQueueManager_InvalidAddress(owner_);
        if (maxSize_ == 0 || processingTimeout_ == 0) {
            revert EventQueueManager_InvalidQueueConfiguration();
        }
        
        uint256 queueId = queueCount++;
        
        // Create queue
        queues[queueId] = QueueConfig({
            name: name_,
            owner: owner_,
            maxSize: maxSize_,
            isPaused: false,
            createdAt: block.timestamp,
            processingTimeout: processingTimeout_
        });
        
        // Add to owner's queues
        queuesByOwner[owner_].push(queueId);
        
        // Add owner as processor
        isProcessor[queueId][owner_] = true;
        processors[queueId].push(owner_);
        
        emit QueueCreated(queueId, name_, owner_);
        emit ProcessorAdded(queueId, owner_);
        
        return queueId;
    }

    /// @notice Internal function to enqueue an event
    /// @param queueId_ The queue ID
    /// @param eventType_ The event type
    /// @param data_ The event data
    /// @return The event ID
    function _enqueueEvent(
        uint256 queueId_,
        bytes32 eventType_,
        bytes calldata data_
    ) internal returns (uint256) {
        QueuedEvent[] storage events = queuedEvents[queueId_];
        
        // Check if queue is full
        if (events.length >= queues[queueId_].maxSize) {
            revert EventQueueManager_QueueFull(queueId_);
        }
        
        // Get next event ID
        uint256 eventId = nextEventId[queueId_]++;
        
        // Create event
        QueuedEvent memory newEvent = QueuedEvent({
            id: eventId,
            eventType: eventType_,
            data: data_,
            enqueuedAt: block.timestamp,
            isProcessing: false,
            processingStartedAt: 0,
            isProcessed: false
        });
        
        // Add to queue
        eventIndexInQueue[queueId_][eventId] = events.length;
        events.push(newEvent);
        
        emit EventEnqueued(queueId_, eventId, eventType_, data_);
        
        return eventId;
    }

    /// @notice Check if a queue exists
    /// @param queueId_ The queue ID
    /// @return Whether the queue exists
    function _queueExists(uint256 queueId_) internal view returns (bool) {
        return queueId_ < queueCount && queues[queueId_].owner != address(0);
    }
}