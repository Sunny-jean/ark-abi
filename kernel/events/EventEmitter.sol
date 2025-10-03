// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Event Emitter
/// @notice Centralized event emission service for the system
interface IEventEmitter {
    function emitEvent(bytes32 eventType_, bytes memory data_) external;
    function getEventCount() external view returns (uint256);
    function getEventTypeCount(bytes32 eventType_) external view returns (uint256);
    function isEventTypeRegistered(bytes32 eventType_) external view returns (bool);
}

contract EventEmitter is IEventEmitter {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event EventEmitted(bytes32 indexed eventType, address indexed emitter, bytes data, uint256 timestamp);
    event EventTypeRegistered(bytes32 indexed eventType, string name, string description);
    event EventTypeDeregistered(bytes32 indexed eventType);
    event EmitterAuthorized(address indexed emitter, bytes32 indexed eventType);
    event EmitterDeauthorized(address indexed emitter, bytes32 indexed eventType);
    event EmitterAdminChanged(address indexed oldAdmin, address indexed newAdmin);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error EventEmitter_OnlyAdmin(address caller_);
    error EventEmitter_OnlyAuthorized(address emitter_, bytes32 eventType_);
    error EventEmitter_EventTypeNotRegistered(bytes32 eventType_);
    error EventEmitter_EventTypeAlreadyRegistered(bytes32 eventType_);
    error EventEmitter_InvalidAddress(address addr_);
    error EventEmitter_EmitterAlreadyAuthorized(address emitter_, bytes32 eventType_);
    error EventEmitter_EmitterNotAuthorized(address emitter_, bytes32 eventType_);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct EventType {
        bytes32 id;
        string name;
        string description;
        bool isRegistered;
        uint256 eventCount;
    }

    struct EmittedEvent {
        bytes32 eventType;
        address emitter;
        bytes data;
        uint256 timestamp;
        uint256 blockNumber;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    
    // Event types
    mapping(bytes32 => EventType) public eventTypes;
    mapping(string => bytes32) public eventTypeIdByName;
    bytes32[] public registeredEventTypes;
    
    // Emitted events
    EmittedEvent[] public emittedEvents;
    mapping(bytes32 => uint256[]) public eventsByType;
    
    // Authorized emitters
    mapping(address => mapping(bytes32 => bool)) public isAuthorizedEmitter;
    mapping(bytes32 => address[]) public authorizedEmittersByType;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert EventEmitter_OnlyAdmin(msg.sender);
        _;
    }

    modifier onlyAuthorized(bytes32 eventType_) {
        if (!isAuthorizedEmitter[msg.sender][eventType_]) {
            revert EventEmitter_OnlyAuthorized(msg.sender, eventType_);
        }
        _;
    }

    modifier eventTypeRegistered(bytes32 eventType_) {
        if (!eventTypes[eventType_].isRegistered) {
            revert EventEmitter_EventTypeNotRegistered(eventType_);
        }
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_) {
        if (admin_ == address(0)) revert EventEmitter_InvalidAddress(admin_);
        
        admin = admin_;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Emit an event
    /// @param eventType_ The event type
    /// @param data_ The event data
    function emitEvent(
        bytes32 eventType_,
        bytes memory data_
    ) external override onlyAuthorized(eventType_) eventTypeRegistered(eventType_) {
        // Create event
        EmittedEvent memory newEvent = EmittedEvent({
            eventType: eventType_,
            emitter: msg.sender,
            data: data_,
            timestamp: block.timestamp,
            blockNumber: block.number
        });
        
        // Add to arrays
        uint256 eventId = emittedEvents.length;
        emittedEvents.push(newEvent);
        eventsByType[eventType_].push(eventId);
        
        // Update count
        eventTypes[eventType_].eventCount++;
        
        emit EventEmitted(eventType_, msg.sender, data_, block.timestamp);
    }

    /// @notice Register an event type
    /// @param eventType_ The event type
    /// @param name_ The event type name
    /// @param description_ The event type description
    function registerEventType(
        bytes32 eventType_,
        string calldata name_,
        string calldata description_
    ) external onlyAdmin {
        if (eventTypes[eventType_].isRegistered) {
            revert EventEmitter_EventTypeAlreadyRegistered(eventType_);
        }
        
        // Register event type
        eventTypes[eventType_] = EventType({
            id: eventType_,
            name: name_,
            description: description_,
            isRegistered: true,
            eventCount: 0
        });
        
        // Map name to ID
        eventTypeIdByName[name_] = eventType_;
        
        // Add to array
        registeredEventTypes.push(eventType_);
        
        emit EventTypeRegistered(eventType_, name_, description_);
    }

    /// @notice Deregister an event type
    /// @param eventType_ The event type
    function deregisterEventType(bytes32 eventType_) external onlyAdmin eventTypeRegistered(eventType_) {
        // Remove name mapping
        delete eventTypeIdByName[eventTypes[eventType_].name];
        
        // Deregister event type
        eventTypes[eventType_].isRegistered = false;
        
        // Remove from array
        for (uint256 i = 0; i < registeredEventTypes.length; i++) {
            if (registeredEventTypes[i] == eventType_) {
                registeredEventTypes[i] = registeredEventTypes[registeredEventTypes.length - 1];
                registeredEventTypes.pop();
                break;
            }
        }
        
        emit EventTypeDeregistered(eventType_);
    }

    /// @notice Authorize an emitter for an event type
    /// @param emitter_ The emitter address
    /// @param eventType_ The event type
    function authorizeEmitter(
        address emitter_,
        bytes32 eventType_
    ) external onlyAdmin eventTypeRegistered(eventType_) {
        if (emitter_ == address(0)) revert EventEmitter_InvalidAddress(emitter_);
        if (isAuthorizedEmitter[emitter_][eventType_]) {
            revert EventEmitter_EmitterAlreadyAuthorized(emitter_, eventType_);
        }
        
        // Authorize emitter
        isAuthorizedEmitter[emitter_][eventType_] = true;
        
        // Add to array
        authorizedEmittersByType[eventType_].push(emitter_);
        
        emit EmitterAuthorized(emitter_, eventType_);
    }

    /// @notice Deauthorize an emitter for an event type
    /// @param emitter_ The emitter address
    /// @param eventType_ The event type
    function deauthorizeEmitter(
        address emitter_,
        bytes32 eventType_
    ) external onlyAdmin eventTypeRegistered(eventType_) {
        if (!isAuthorizedEmitter[emitter_][eventType_]) {
            revert EventEmitter_EmitterNotAuthorized(emitter_, eventType_);
        }
        
        // Deauthorize emitter
        isAuthorizedEmitter[emitter_][eventType_] = false;
        
        // Remove from array
        address[] storage emitters = authorizedEmittersByType[eventType_];
        for (uint256 i = 0; i < emitters.length; i++) {
            if (emitters[i] == emitter_) {
                emitters[i] = emitters[emitters.length - 1];
                emitters.pop();
                break;
            }
        }
        
        emit EmitterDeauthorized(emitter_, eventType_);
    }

    /// @notice Change the admin
    /// @param newAdmin_ The new admin address
    function changeAdmin(address newAdmin_) external onlyAdmin {
        if (newAdmin_ == address(0)) revert EventEmitter_InvalidAddress(newAdmin_);
        
        address oldAdmin = admin;
        admin = newAdmin_;
        
        emit EmitterAdminChanged(oldAdmin, newAdmin_);
    }

    /// @notice Get the total event count
    /// @return The total number of events
    function getEventCount() external view override returns (uint256) {
        return emittedEvents.length;
    }

    /// @notice Get the event count for a specific type
    /// @param eventType_ The event type
    /// @return The number of events of this type
    function getEventTypeCount(bytes32 eventType_) external view override returns (uint256) {
        return eventTypes[eventType_].eventCount;
    }

    /// @notice Check if an event type is registered
    /// @param eventType_ The event type
    /// @return Whether the event type is registered
    function isEventTypeRegistered(bytes32 eventType_) external view override returns (bool) {
        return eventTypes[eventType_].isRegistered;
    }

    /// @notice Get events by type
    /// @param eventType_ The event type
    /// @param offset_ The offset
    /// @param limit_ The limit
    /// @return Array of event IDs
    function getEventsByType(
        bytes32 eventType_,
        uint256 offset_,
        uint256 limit_
    ) external view eventTypeRegistered(eventType_) returns (uint256[] memory) {
        uint256[] storage events = eventsByType[eventType_];
        
        // Calculate actual limit
        uint256 actualLimit = limit_;
        if (offset_ + actualLimit > events.length) {
            actualLimit = events.length > offset_ ? events.length - offset_ : 0;
        }
        
        // Create result array
        uint256[] memory result = new uint256[](actualLimit);
        
        // Fill result array
        for (uint256 i = 0; i < actualLimit; i++) {
            result[i] = events[offset_ + i];
        }
        
        return result;
    }

    /// @notice Get event details
    /// @param eventId_ The event ID
    /// @return eventType The event type
    /// @return emitter The emitter address
    /// @return data The event data
    /// @return timestamp When the event was emitted
    /// @return blockNumber The block number when the event was emitted
    function getEventDetails(uint256 eventId_) external view returns (
        bytes32 eventType,
        address emitter,
        bytes memory data,
        uint256 timestamp,
        uint256 blockNumber
    ) {
        require(eventId_ < emittedEvents.length, "Event not found");
        
        EmittedEvent memory event_ = emittedEvents[eventId_];
        return (
            event_.eventType,
            event_.emitter,
            event_.data,
            event_.timestamp,
            event_.blockNumber
        );
    }

    /// @notice Get event type details
    /// @param eventType_ The event type
    /// @return id The event type ID
    /// @return name The event type name
    /// @return description The event type description
    /// @return isRegistered Whether the event type is registered
    /// @return eventCount The number of events of this type
    function getEventTypeDetails(bytes32 eventType_) external view returns (
        bytes32 id,
        string memory name,
        string memory description,
        bool isRegistered,
        uint256 eventCount
    ) {
        EventType memory eventType = eventTypes[eventType_];
        return (
            eventType.id,
            eventType.name,
            eventType.description,
            eventType.isRegistered,
            eventType.eventCount
        );
    }

    /// @notice Get all registered event types
    /// @return Array of event type IDs
    function getRegisteredEventTypes() external view returns (bytes32[] memory) {
        return registeredEventTypes;
    }

    /// @notice Get authorized emitters for an event type
    /// @param eventType_ The event type
    /// @return Array of authorized emitter addresses
    function getAuthorizedEmitters(bytes32 eventType_) external view eventTypeRegistered(eventType_) returns (address[] memory) {
        return authorizedEmittersByType[eventType_];
    }

    /// @notice Check if an emitter is authorized for an event type
    /// @param emitter_ The emitter address
    /// @param eventType_ The event type
    /// @return Whether the emitter is authorized
    function checkEmitterAuthorization(address emitter_, bytes32 eventType_) external view returns (bool) {
        return isAuthorizedEmitter[emitter_][eventType_];
    }
}