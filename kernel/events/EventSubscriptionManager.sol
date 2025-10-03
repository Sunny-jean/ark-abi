// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Event Subscription Manager
/// @notice Manages subscriptions to system events
interface IEventSubscriptionManager {
    function subscribe(bytes32 eventType_, address subscriber_) external;
    function unsubscribe(bytes32 eventType_, address subscriber_) external;
    function getSubscriberCount(bytes32 eventType_) external view returns (uint256);
    function getSubscribers(bytes32 eventType_, uint256 offset_, uint256 limit_) external view returns (address[] memory);
}

contract EventSubscriptionManager is IEventSubscriptionManager {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event EventTypeRegistered(bytes32 indexed eventType, string name, string description);
    event EventTypeDeregistered(bytes32 indexed eventType);
    event SubscriptionCreated(bytes32 indexed eventType, address indexed subscriber);
    event SubscriptionCancelled(bytes32 indexed eventType, address indexed subscriber);
    event SubscriptionPaused(bytes32 indexed eventType, address indexed subscriber);
    event SubscriptionResumed(bytes32 indexed eventType, address indexed subscriber);
    event SubscriptionManagerAdminChanged(address indexed oldAdmin, address indexed newAdmin);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error EventSubscriptionManager_OnlyAdmin(address caller_);
    error EventSubscriptionManager_OnlyAuthorized(address caller_);
    error EventSubscriptionManager_InvalidAddress(address addr_);
    error EventSubscriptionManager_EventTypeNotRegistered(bytes32 eventType_);
    error EventSubscriptionManager_EventTypeAlreadyRegistered(bytes32 eventType_);
    error EventSubscriptionManager_AlreadySubscribed(bytes32 eventType_, address subscriber_);
    error EventSubscriptionManager_NotSubscribed(bytes32 eventType_, address subscriber_);
    error EventSubscriptionManager_SubscriptionPaused(bytes32 eventType_, address subscriber_);
    error EventSubscriptionManager_MaxSubscribersReached(bytes32 eventType_);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct EventTypeInfo {
        bytes32 id;
        string name;
        string description;
        bool isRegistered;
        uint256 maxSubscribers; // 0 means unlimited
    }

    struct Subscription {
        bytes32 eventType;
        address subscriber;
        uint256 createdAt;
        bool isPaused;
        uint256 lastNotifiedAt;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    mapping(address => bool) public isAuthorized;
    address[] public authorizedAddresses;
    
    // Event types
    mapping(bytes32 => EventTypeInfo) public eventTypes;
    mapping(string => bytes32) public eventTypeIdByName;
    bytes32[] public registeredEventTypes;
    
    // Subscriptions
    mapping(bytes32 => mapping(address => Subscription)) public subscriptions;
    mapping(bytes32 => address[]) public subscribersByEventType;
    mapping(address => bytes32[]) public eventTypesBySubscriber;
    
    // Subscription counts
    mapping(bytes32 => uint256) public subscriberCount;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert EventSubscriptionManager_OnlyAdmin(msg.sender);
        _;
    }

    modifier onlyAuthorized() {
        if (!isAuthorized[msg.sender] && msg.sender != admin) {
            revert EventSubscriptionManager_OnlyAuthorized(msg.sender);
        }
        _;
    }

    modifier eventTypeRegistered(bytes32 eventType_) {
        if (!eventTypes[eventType_].isRegistered) {
            revert EventSubscriptionManager_EventTypeNotRegistered(eventType_);
        }
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address[] memory initialAuthorized_) {
        if (admin_ == address(0)) revert EventSubscriptionManager_InvalidAddress(admin_);
        
        admin = admin_;
        
        // Add initial authorized addresses
        for (uint256 i = 0; i < initialAuthorized_.length; i++) {
            address auth = initialAuthorized_[i];
            if (auth == address(0)) revert EventSubscriptionManager_InvalidAddress(auth);
            if (!isAuthorized[auth]) {
                isAuthorized[auth] = true;
                authorizedAddresses.push(auth);
            }
        }
        
        // Initialize default event types
        _registerEventType(
            "MODULE_INSTALLED", 
            keccak256("MODULE_INSTALLED"), 
            "Triggered when a new module is installed",
            0 // unlimited subscribers
        );
        _registerEventType(
            "MODULE_UPGRADED", 
            keccak256("MODULE_UPGRADED"), 
            "Triggered when a module is upgraded",
            0 // unlimited subscribers
        );
        _registerEventType(
            "SECURITY_ALERT", 
            keccak256("SECURITY_ALERT"), 
            "Triggered when a security issue is detected",
            100 // max 100 subscribers
        );
        _registerEventType(
            "SYSTEM_STATUS_CHANGE", 
            keccak256("SYSTEM_STATUS_CHANGE"), 
            "Triggered when system status changes",
            0 // unlimited subscribers
        );
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Subscribe to an event type
    /// @param eventType_ The event type ID
    /// @param subscriber_ The subscriber address
    function subscribe(
        bytes32 eventType_,
        address subscriber_
    ) external override onlyAuthorized eventTypeRegistered(eventType_) {
        if (subscriber_ == address(0)) revert EventSubscriptionManager_InvalidAddress(subscriber_);
        
        // Check if already subscribed
        if (subscriptions[eventType_][subscriber_].subscriber != address(0)) {
            // If paused, resume it
            if (subscriptions[eventType_][subscriber_].isPaused) {
                subscriptions[eventType_][subscriber_].isPaused = false;
                emit SubscriptionResumed(eventType_, subscriber_);
                return;
            }
            revert EventSubscriptionManager_AlreadySubscribed(eventType_, subscriber_);
        }
        
        // Check max subscribers
        uint256 maxSubscribers = eventTypes[eventType_].maxSubscribers;
        if (maxSubscribers > 0 && subscriberCount[eventType_] >= maxSubscribers) {
            revert EventSubscriptionManager_MaxSubscribersReached(eventType_);
        }
        
        // Create subscription
        subscriptions[eventType_][subscriber_] = Subscription({
            eventType: eventType_,
            subscriber: subscriber_,
            createdAt: block.timestamp,
            isPaused: false,
            lastNotifiedAt: 0
        });
        
        // Update mappings
        subscribersByEventType[eventType_].push(subscriber_);
        eventTypesBySubscriber[subscriber_].push(eventType_);
        subscriberCount[eventType_]++;
        
        emit SubscriptionCreated(eventType_, subscriber_);
    }

    /// @notice Unsubscribe from an event type
    /// @param eventType_ The event type ID
    /// @param subscriber_ The subscriber address
    function unsubscribe(
        bytes32 eventType_,
        address subscriber_
    ) external override onlyAuthorized eventTypeRegistered(eventType_) {
        if (subscriptions[eventType_][subscriber_].subscriber == address(0)) {
            revert EventSubscriptionManager_NotSubscribed(eventType_, subscriber_);
        }
        
        // Remove subscription
        delete subscriptions[eventType_][subscriber_];
        
        // Update mappings
        _removeFromArray(subscribersByEventType[eventType_], subscriber_);
        _removeFromArray(eventTypesBySubscriber[subscriber_], eventType_);
        subscriberCount[eventType_]--;
        
        emit SubscriptionCancelled(eventType_, subscriber_);
    }

    /// @notice Pause a subscription
    /// @param eventType_ The event type ID
    /// @param subscriber_ The subscriber address
    function pauseSubscription(
        bytes32 eventType_,
        address subscriber_
    ) external onlyAuthorized eventTypeRegistered(eventType_) {
        if (subscriptions[eventType_][subscriber_].subscriber == address(0)) {
            revert EventSubscriptionManager_NotSubscribed(eventType_, subscriber_);
        }
        if (subscriptions[eventType_][subscriber_].isPaused) {
            revert EventSubscriptionManager_SubscriptionPaused(eventType_, subscriber_);
        }
        
        subscriptions[eventType_][subscriber_].isPaused = true;
        
        emit SubscriptionPaused(eventType_, subscriber_);
    }

    /// @notice Resume a subscription
    /// @param eventType_ The event type ID
    /// @param subscriber_ The subscriber address
    function resumeSubscription(
        bytes32 eventType_,
        address subscriber_
    ) external onlyAuthorized eventTypeRegistered(eventType_) {
        if (subscriptions[eventType_][subscriber_].subscriber == address(0)) {
            revert EventSubscriptionManager_NotSubscribed(eventType_, subscriber_);
        }
        if (!subscriptions[eventType_][subscriber_].isPaused) {
            revert EventSubscriptionManager_NotSubscribed(eventType_, subscriber_);
        }
        
        subscriptions[eventType_][subscriber_].isPaused = false;
        
        emit SubscriptionResumed(eventType_, subscriber_);
    }

    /// @notice Register an event type
    /// @param name_ The event type name
    /// @param eventType_ The event type ID
    /// @param description_ The event type description
    /// @param maxSubscribers_ The maximum number of subscribers (0 means unlimited)
    function registerEventType(
        string calldata name_,
        bytes32 eventType_,
        string calldata description_,
        uint256 maxSubscribers_
    ) external onlyAdmin {
        _registerEventType(name_, eventType_, description_, maxSubscribers_);
    }

    /// @notice Deregister an event type
    /// @param eventType_ The event type ID
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

    /// @notice Add an authorized address
    /// @param authorized_ The authorized address
    function addAuthorized(address authorized_) external onlyAdmin {
        if (authorized_ == address(0)) revert EventSubscriptionManager_InvalidAddress(authorized_);
        if (isAuthorized[authorized_]) return; // Already authorized
        
        isAuthorized[authorized_] = true;
        authorizedAddresses.push(authorized_);
    }

    /// @notice Remove an authorized address
    /// @param authorized_ The authorized address
    function removeAuthorized(address authorized_) external onlyAdmin {
        if (!isAuthorized[authorized_]) return; // Not authorized
        
        isAuthorized[authorized_] = false;
        
        // Remove from array
        for (uint256 i = 0; i < authorizedAddresses.length; i++) {
            if (authorizedAddresses[i] == authorized_) {
                authorizedAddresses[i] = authorizedAddresses[authorizedAddresses.length - 1];
                authorizedAddresses.pop();
                break;
            }
        }
    }

    /// @notice Change the admin
    /// @param newAdmin_ The new admin address
    function changeAdmin(address newAdmin_) external onlyAdmin {
        if (newAdmin_ == address(0)) revert EventSubscriptionManager_InvalidAddress(newAdmin_);
        
        address oldAdmin = admin;
        admin = newAdmin_;
        
        emit SubscriptionManagerAdminChanged(oldAdmin, newAdmin_);
    }

    /// @notice Update last notified timestamp for a subscription
    /// @param eventType_ The event type ID
    /// @param subscriber_ The subscriber address
    function updateLastNotified(
        bytes32 eventType_,
        address subscriber_
    ) external onlyAuthorized eventTypeRegistered(eventType_) {
        if (subscriptions[eventType_][subscriber_].subscriber == address(0)) {
            revert EventSubscriptionManager_NotSubscribed(eventType_, subscriber_);
        }
        if (subscriptions[eventType_][subscriber_].isPaused) {
            revert EventSubscriptionManager_SubscriptionPaused(eventType_, subscriber_);
        }
        
        subscriptions[eventType_][subscriber_].lastNotifiedAt = block.timestamp;
    }

    /// @notice Get the subscriber count for an event type
    /// @param eventType_ The event type ID
    /// @return The number of subscribers
    function getSubscriberCount(bytes32 eventType_) external view override eventTypeRegistered(eventType_) returns (uint256) {
        return subscriberCount[eventType_];
    }

    /// @notice Get subscribers for an event type
    /// @param eventType_ The event type ID
    /// @param offset_ The offset
    /// @param limit_ The limit
    /// @return Array of subscriber addresses
    function getSubscribers(
        bytes32 eventType_,
        uint256 offset_,
        uint256 limit_
    ) external view override eventTypeRegistered(eventType_) returns (address[] memory) {
        address[] storage subscribers = subscribersByEventType[eventType_];
        
        // Calculate actual limit
        uint256 actualLimit = limit_;
        if (offset_ + actualLimit > subscribers.length) {
            actualLimit = subscribers.length > offset_ ? subscribers.length - offset_ : 0;
        }
        
        // Create result array
        address[] memory result = new address[](actualLimit);
        
        // Fill result array
        for (uint256 i = 0; i < actualLimit; i++) {
            result[i] = subscribers[offset_ + i];
        }
        
        return result;
    }

    /// @notice Get active subscribers for an event type
    /// @param eventType_ The event type ID
    /// @param offset_ The offset
    /// @param limit_ The limit
    /// @return Array of active subscriber addresses
    function getActiveSubscribers(
        bytes32 eventType_,
        uint256 offset_,
        uint256 limit_
    ) external view eventTypeRegistered(eventType_) returns (address[] memory) {
        address[] storage allSubscribers = subscribersByEventType[eventType_];
        
        // Count active subscribers
        uint256 activeCount = 0;
        for (uint256 i = 0; i < allSubscribers.length; i++) {
            if (!subscriptions[eventType_][allSubscribers[i]].isPaused) {
                activeCount++;
            }
        }
        
        // Calculate actual limit
        uint256 actualLimit = limit_;
        if (offset_ + actualLimit > activeCount) {
            actualLimit = activeCount > offset_ ? activeCount - offset_ : 0;
        }
        
        // Create result array
        address[] memory result = new address[](actualLimit);
        
        // Fill result array
        uint256 resultIndex = 0;
        uint256 skipped = 0;
        
        for (uint256 i = 0; i < allSubscribers.length && resultIndex < actualLimit; i++) {
            address subscriber = allSubscribers[i];
            if (!subscriptions[eventType_][subscriber].isPaused) {
                if (skipped < offset_) {
                    skipped++;
                } else {
                    result[resultIndex++] = subscriber;
                }
            }
        }
        
        return result;
    }

    /// @notice Get event types for a subscriber
    /// @param subscriber_ The subscriber address
    /// @return Array of event type IDs
    function getEventTypesForSubscriber(address subscriber_) external view returns (bytes32[] memory) {
        return eventTypesBySubscriber[subscriber_];
    }

    /// @notice Get subscription details
    /// @param eventType_ The event type ID
    /// @param subscriber_ The subscriber address
    /// @return eventType The event type ID
    /// @return subscriber The subscriber address
    /// @return createdAt When the subscription was created
    /// @return isPaused Whether the subscription is paused
    /// @return lastNotifiedAt When the subscriber was last notified
    function getSubscriptionDetails(
        bytes32 eventType_,
        address subscriber_
    ) external view returns (
        bytes32 eventType,
        address subscriber,
        uint256 createdAt,
        bool isPaused,
        uint256 lastNotifiedAt
    ) {
        Subscription memory sub = subscriptions[eventType_][subscriber_];
        return (
            sub.eventType,
            sub.subscriber,
            sub.createdAt,
            sub.isPaused,
            sub.lastNotifiedAt
        );
    }

    /// @notice Get event type details
    /// @param eventType_ The event type ID
    /// @return id The event type ID
    /// @return name The event type name
    /// @return description The event type description
    /// @return isRegistered Whether the event type is registered
    /// @return maxSubscribers The maximum number of subscribers
    function getEventTypeDetails(bytes32 eventType_) external view returns (
        bytes32 id,
        string memory name,
        string memory description,
        bool isRegistered,
        uint256 maxSubscribers
    ) {
        EventTypeInfo memory eventType = eventTypes[eventType_];
        return (
            eventType.id,
            eventType.name,
            eventType.description,
            eventType.isRegistered,
            eventType.maxSubscribers
        );
    }

    /// @notice Get all registered event types
    /// @return Array of event type IDs
    function getRegisteredEventTypes() external view returns (bytes32[] memory) {
        return registeredEventTypes;
    }

    /// @notice Get all authorized addresses
    /// @return Array of authorized addresses
    function getAuthorizedAddresses() external view returns (address[] memory) {
        return authorizedAddresses;
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Internal function to register an event type
    /// @param name_ The event type name
    /// @param eventType_ The event type ID
    /// @param description_ The event type description
    /// @param maxSubscribers_ The maximum number of subscribers
    function _registerEventType(
        string memory name_,
        bytes32 eventType_,
        string memory description_,
        uint256 maxSubscribers_
    ) internal {
        if (eventTypes[eventType_].isRegistered) {
            revert EventSubscriptionManager_EventTypeAlreadyRegistered(eventType_);
        }
        
        // Register event type
        eventTypes[eventType_] = EventTypeInfo({
            id: eventType_,
            name: name_,
            description: description_,
            isRegistered: true,
            maxSubscribers: maxSubscribers_
        });
        
        // Map name to ID
        eventTypeIdByName[name_] = eventType_;
        
        // Add to array
        registeredEventTypes.push(eventType_);
        
        emit EventTypeRegistered(eventType_, name_, description_);
    }

    /// @notice Helper function to remove an element from an array
    /// @param array The array
    /// @param value The value to remove
    function _removeFromArray(address[] storage array, address value) internal {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == value) {
                array[i] = array[array.length - 1];
                array.pop();
                break;
            }
        }
    }

    /// @notice Helper function to remove an element from an array
    /// @param array The array
    /// @param value The value to remove
    function _removeFromArray(bytes32[] storage array, bytes32 value) internal {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == value) {
                array[i] = array[array.length - 1];
                array.pop();
                break;
            }
        }
    }
}