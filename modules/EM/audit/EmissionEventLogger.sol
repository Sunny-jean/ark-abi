// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Emission Manager interface
/// @notice interface for the emission manager contract
interface IEmissionManager {
    function getEmissionRate(address token) external view returns (uint256);
    function getTotalEmitted(address token) external view returns (uint256);
    function getEmissionStartTime(address token) external view returns (uint256);
    function getSupportedTokens() external view returns (address[] memory);
}

/// @title Emission Audit Log interface
/// @notice interface for the emission audit log contract
interface IEmissionAuditLog {
    function logEmissionEvent(address token, uint256 amount, string memory eventType, address initiator) external returns (uint256 eventId);
    function logRateChange(address token, uint256 oldRate, uint256 newRate, address initiator) external returns (uint256 eventId);
    function logEmergencyAction(address token, string memory actionType, string memory reason, address initiator) external returns (uint256 eventId);
    function logCustomEvent(address token, string memory eventType, string memory details, address initiator) external returns (uint256 eventId);
}

/// @title Emission Event Logger interface
/// @notice interface for the emission event logger contract
interface IEmissionEventLogger {
    function logEmission(address token, uint256 amount, address recipient) external returns (uint256 eventId);
    function logRateChange(address token, uint256 oldRate, uint256 newRate) external returns (uint256 eventId);
    function logEmergencyEvent(address token, string memory eventType, string memory details) external returns (uint256 eventId);
    function logSystemEvent(string memory category, string memory details) external returns (uint256 eventId);
    function getEventCount() external view returns (uint256);
    function getEventsByToken(address token, uint256 startIndex, uint256 count) external view returns (uint256[] memory eventIds);
    function getEventsByType(string memory eventType, uint256 startIndex, uint256 count) external view returns (uint256[] memory eventIds);
    function getEventDetails(uint256 eventId) external view returns (address token, string memory eventType, uint256 timestamp, string memory details);
}

/// @title Emission Event Logger
/// @notice Logs emission-related events for auditing and monitoring
contract EmissionEventLogger {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event EventLogged(uint256 indexed eventId, address indexed token, string indexed eventType, uint256 timestamp);
    event EmissionManagerUpdated(address indexed oldManager, address indexed newManager);
    event AuditLogUpdated(address indexed oldLog, address indexed newLog);
    event EventLoggerAuthorityAdded(address indexed authority);
    event EventLoggerAuthorityRemoved(address indexed authority);
    event EventCategoryAdded(string indexed category);
    event EventCategoryRemoved(string indexed category);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error EEL_OnlyAdmin();
    error EEL_OnlyAuthority();
    error EEL_ZeroAddress();
    error EEL_TokenNotSupported();
    error EEL_InvalidEventId();
    error EEL_InvalidParameter();
    error EEL_AuthorityAlreadyAdded();
    error EEL_AuthorityNotFound();
    error EEL_CategoryAlreadyExists();
    error EEL_CategoryNotFound();
    error EEL_DependencyNotSet();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct EventRecord {
        uint256 id;
        address token; // Zero address for system-wide events
        string eventType;
        uint256 timestamp;
        string details;
        address initiator;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public emissionManager;
    address public auditLog;
    
    // Event storage
    mapping(uint256 => EventRecord) public events;
    uint256 public eventCount;
    
    // Event indices
    mapping(address => uint256[]) public tokenEvents; // token => eventIds
    mapping(string => uint256[]) public typeEvents; // eventType => eventIds
    
    // Authorities
    mapping(address => bool) public authorities;
    address[] public authorityList;
    
    // Event categories
    mapping(string => bool) public validCategories;
    string[] public categories;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert EEL_OnlyAdmin();
        _;
    }

    modifier onlyAuthority() {
        if (msg.sender != admin && !authorities[msg.sender]) revert EEL_OnlyAuthority();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address emissionManager_, address auditLog_) {
        if (admin_ == address(0)) revert EEL_ZeroAddress();
        
        admin = admin_;
        
        if (emissionManager_ != address(0)) emissionManager = emissionManager_;
        if (auditLog_ != address(0)) auditLog = auditLog_;
        
        // Add default event categories
        _addCategory("emission");
        _addCategory("rate_change");
        _addCategory("emergency");
        _addCategory("system");
        _addCategory("governance");
        _addCategory("market");
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function setEmissionManager(address emissionManager_) external onlyAdmin {
        if (emissionManager_ == address(0)) revert EEL_ZeroAddress();
        
        address oldManager = emissionManager;
        emissionManager = emissionManager_;
        
        emit EmissionManagerUpdated(oldManager, emissionManager_);
    }

    function setAuditLog(address auditLog_) external onlyAdmin {
        if (auditLog_ == address(0)) revert EEL_ZeroAddress();
        
        address oldLog = auditLog;
        auditLog = auditLog_;
        
        emit AuditLogUpdated(oldLog, auditLog_);
    }

    function addAuthority(address authority) external onlyAdmin {
        if (authority == address(0)) revert EEL_ZeroAddress();
        if (authorities[authority]) revert EEL_AuthorityAlreadyAdded();
        
        authorities[authority] = true;
        authorityList.push(authority);
        
        emit EventLoggerAuthorityAdded(authority);
    }

    function removeAuthority(address authority) external onlyAdmin {
        if (!authorities[authority]) revert EEL_AuthorityNotFound();
        
        authorities[authority] = false;
        
        // Remove from authorityList
        for (uint256 i = 0; i < authorityList.length; i++) {
            if (authorityList[i] == authority) {
                authorityList[i] = authorityList[authorityList.length - 1];
                authorityList.pop();
                break;
            }
        }
        
        emit EventLoggerAuthorityRemoved(authority);
    }

    function addCategory(string memory category) external onlyAdmin {
        _addCategory(category);
    }

    function removeCategory(string memory category) external onlyAdmin {
        if (!validCategories[category]) revert EEL_CategoryNotFound();
        
        validCategories[category] = false;
        
        // Remove from categories array
        for (uint256 i = 0; i < categories.length; i++) {
            if (keccak256(bytes(categories[i])) == keccak256(bytes(category))) {
                categories[i] = categories[categories.length - 1];
                categories.pop();
                break;
            }
        }
        
        emit EventCategoryRemoved(category);
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function logEmission(address token, uint256 amount, address recipient) external onlyAuthority returns (uint256 eventId) {
        if (emissionManager == address(0)) revert EEL_DependencyNotSet();
        
        // Check if token is supported by emission manager
        _validateToken(token);
        
        // Create event details
        string memory details = string(abi.encodePacked(
            "Amount: ", _uintToString(amount),
            ", Recipient: ", _addressToString(recipient)
        ));
        
        // Log event
        eventId = _logEvent(token, "emission", details);
        
        // Forward to audit log if set
        if (auditLog != address(0)) {
            IEmissionAuditLog(auditLog).logEmissionEvent(token, amount, "emission", msg.sender);
        }
        
        return eventId;
    }

    function logRateChange(address token, uint256 oldRate, uint256 newRate) external onlyAuthority returns (uint256 eventId) {
        if (emissionManager == address(0)) revert EEL_DependencyNotSet();
        
        // Check if token is supported by emission manager
        _validateToken(token);
        
        // Create event details
        string memory details = string(abi.encodePacked(
            "Old Rate: ", _uintToString(oldRate),
            ", New Rate: ", _uintToString(newRate)
        ));
        
        // Log event
        eventId = _logEvent(token, "rate_change", details);
        
        // Forward to audit log if set
        if (auditLog != address(0)) {
            IEmissionAuditLog(auditLog).logRateChange(token, oldRate, newRate, msg.sender);
        }
        
        return eventId;
    }

    function logEmergencyEvent(address token, string memory eventType, string memory details) external onlyAuthority returns (uint256 eventId) {
        if (emissionManager == address(0)) revert EEL_DependencyNotSet();
        
        // Check if token is supported by emission manager
        _validateToken(token);
        
        // Prefix event type with emergency_
        string memory fullEventType = string(abi.encodePacked("emergency_", eventType));
        
        // Log event
        eventId = _logEvent(token, fullEventType, details);
        
        // Forward to audit log if set
        if (auditLog != address(0)) {
            IEmissionAuditLog(auditLog).logEmergencyAction(token, eventType, details, msg.sender);
        }
        
        return eventId;
    }

    function logSystemEvent(string memory category, string memory details) external onlyAuthority returns (uint256 eventId) {
        if (!validCategories[category]) revert EEL_CategoryNotFound();
        
        // Log event with zero address as token (system-wide)
        eventId = _logEvent(address(0), category, details);
        
        // Forward to audit log if set
        if (auditLog != address(0)) {
            IEmissionAuditLog(auditLog).logCustomEvent(address(0), category, details, msg.sender);
        }
        
        return eventId;
    }

    function logCustomEvent(address token, string memory eventType, string memory details) external onlyAuthority returns (uint256 eventId) {
        // If token is not zero address, validate it
        if (token != address(0)) {
            if (emissionManager == address(0)) revert EEL_DependencyNotSet();
            _validateToken(token);
        }
        
        // Log event
        eventId = _logEvent(token, eventType, details);
        
        // Forward to audit log if set
        if (auditLog != address(0)) {
            IEmissionAuditLog(auditLog).logCustomEvent(token, eventType, details, msg.sender);
        }
        
        return eventId;
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getEventCount() external view returns (uint256) {
        return eventCount;
    }

    function getEventsByToken(address token, uint256 startIndex, uint256 count) external view returns (uint256[] memory eventIds) {
        uint256[] storage tokenEventIds = tokenEvents[token];
        
        // Determine actual count based on available events
        uint256 available = tokenEventIds.length > startIndex ? tokenEventIds.length - startIndex : 0;
        uint256 actualCount = available < count ? available : count;
        
        eventIds = new uint256[](actualCount);
        
        for (uint256 i = 0; i < actualCount; i++) {
            eventIds[i] = tokenEventIds[startIndex + i];
        }
        
        return eventIds;
    }

    function getEventsByType(string memory eventType, uint256 startIndex, uint256 count) external view returns (uint256[] memory eventIds) {
        uint256[] storage typeEventIds = typeEvents[eventType];
        
        // Determine actual count based on available events
        uint256 available = typeEventIds.length > startIndex ? typeEventIds.length - startIndex : 0;
        uint256 actualCount = available < count ? available : count;
        
        eventIds = new uint256[](actualCount);
        
        for (uint256 i = 0; i < actualCount; i++) {
            eventIds[i] = typeEventIds[startIndex + i];
        }
        
        return eventIds;
    }

    function getEventDetails(uint256 eventId) external view returns (address token, string memory eventType, uint256 timestamp, string memory details) {
        if (eventId >= eventCount) revert EEL_InvalidEventId();
        
        EventRecord storage event_ = events[eventId];
        
        return (event_.token, event_.eventType, event_.timestamp, event_.details);
    }

    function getEventInitiator(uint256 eventId) external view returns (address) {
        if (eventId >= eventCount) revert EEL_InvalidEventId();
        
        return events[eventId].initiator;
    }

    function getEventsByTimeRange(uint256 startTime, uint256 endTime, uint256 maxCount) external view returns (uint256[] memory eventIds) {
        // Count events in the time range
        uint256 matchCount = 0;
        uint256 count = 0;
        
        for (uint256 i = 0; i < eventCount && count < maxCount; i++) {
            if (events[i].timestamp >= startTime && events[i].timestamp <= endTime) {
                matchCount++;
            }
        }
        
        // Limit to maxCount
        uint256 actualCount = matchCount < maxCount ? matchCount : maxCount;
        eventIds = new uint256[](actualCount);
        
        // Fill the array
        for (uint256 i = 0; i < eventCount && count < actualCount; i++) {
            if (events[i].timestamp >= startTime && events[i].timestamp <= endTime) {
                eventIds[count] = i;
                count++;
            }
        }
        
        return eventIds;
    }

    function getAuthorities() external view returns (address[] memory) {
        return authorityList;
    }

    function getCategories() external view returns (string[] memory) {
        return categories;
    }

    function isValidCategory(string memory category) external view returns (bool) {
        return validCategories[category];
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function _logEvent(address token, string memory eventType, string memory details) internal returns (uint256 eventId) {
        eventId = eventCount;
        
        // Create event record
        events[eventId] = EventRecord({
            id: eventId,
            token: token,
            eventType: eventType,
            timestamp: block.timestamp,
            details: details,
            initiator: msg.sender
        });
        
        // Update indices
        tokenEvents[token].push(eventId);
        typeEvents[eventType].push(eventId);
        
        // Increment event count
        eventCount++;
        
        emit EventLogged(eventId, token, eventType, block.timestamp);
        
        return eventId;
    }

    function _validateToken(address token) internal view {
        if (token == address(0)) revert EEL_ZeroAddress();
        
        // Check if token is supported by emission manager
        address[] memory supportedTokens = IEmissionManager(emissionManager).getSupportedTokens();
        bool tokenFound = false;
        
        for (uint256 i = 0; i < supportedTokens.length; i++) {
            if (supportedTokens[i] == token) {
                tokenFound = true;
                break;
            }
        }
        
        if (!tokenFound) revert EEL_TokenNotSupported();
    }

    function _addCategory(string memory category) internal {
        if (bytes(category).length == 0) revert EEL_InvalidParameter();
        if (validCategories[category]) revert EEL_CategoryAlreadyExists();
        
        validCategories[category] = true;
        categories.push(category);
        
        emit EventCategoryAdded(category);
    }

    function _uintToString(uint256 value) internal pure returns (string memory) {
        // Special case for 0
        if (value == 0) {
            return "0";
        }
        
        // Count digits
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        
        // Create string
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        
        return string(buffer);
    }

    function _addressToString(address addr) internal pure returns (string memory) {
        bytes memory buffer = new bytes(42);
        buffer[0] = "0";
        buffer[1] = "x";
        
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint256(uint160(addr)) / (2**(8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            buffer[2 + i * 2] = _char(hi);
            buffer[3 + i * 2] = _char(lo);
        }
        
        return string(buffer);
    }

    function _char(bytes1 b) internal pure returns (bytes1) {
        if (uint8(b) < 10) {
            return bytes1(uint8(b) + 0x30);
        } else {
            return bytes1(uint8(b) + 0x57);
        }
    }
}