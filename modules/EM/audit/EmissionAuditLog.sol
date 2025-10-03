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
    function logEmergencyAction(address token, string memory action, string memory reason, address initiator) external returns (uint256 eventId);
    function getAuditEvent(uint256 eventId) external view returns (uint256 timestamp, address token, string memory eventType, string memory details, address initiator);
    function getAuditEventsByToken(address token) external view returns (uint256[] memory eventIds);
    function getAuditEventsByInitiator(address initiator) external view returns (uint256[] memory eventIds);
    function getAuditEventsByType(string memory eventType) external view returns (uint256[] memory eventIds);
}

/// @title Emission Audit Log
/// @notice Logs emission-related events for auditing and compliance
contract EmissionAuditLog {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event AuditEventLogged(uint256 indexed eventId, address indexed token, string eventType, address indexed initiator);
    event EmissionManagerUpdated(address indexed oldManager, address indexed newManager);
    event AuditorAdded(address indexed auditor);
    event AuditorRemoved(address indexed auditor);
    event AuditLogExported(uint256 indexed startId, uint256 indexed endId, string destination);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error EAL_OnlyAdmin();
    error EAL_OnlyAuthorized();
    error EAL_ZeroAddress();
    error EAL_InvalidParameter();
    error EAL_EventNotFound();
    error EAL_AuditorAlreadyAdded();
    error EAL_AuditorNotFound();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct AuditEvent {
        uint256 id;
        uint256 timestamp;
        address token;
        string eventType; // "emission", "rate_change", "emergency", etc.
        string details;
        address initiator;
        bool verified;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public emissionManager;
    
    // Audit events storage
    mapping(uint256 => AuditEvent) public auditEvents;
    uint256 public nextEventId = 1;
    
    // Indexes for querying
    mapping(address => uint256[]) public tokenEvents; // token => eventIds
    mapping(address => uint256[]) public initiatorEvents; // initiator => eventIds
    mapping(string => uint256[]) public eventTypeIndex; // eventType => eventIds
    
    // Authorized auditors
    mapping(address => bool) public authorizedAuditors;
    address[] public auditors;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert EAL_OnlyAdmin();
        _;
    }

    modifier onlyAuthorized() {
        if (msg.sender != admin && 
            msg.sender != emissionManager && 
            !authorizedAuditors[msg.sender]) {
            revert EAL_OnlyAuthorized();
        }
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address emissionManager_) {
        if (admin_ == address(0)) revert EAL_ZeroAddress();
        
        admin = admin_;
        
        if (emissionManager_ != address(0)) {
            emissionManager = emissionManager_;
        }
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function setEmissionManager(address emissionManager_) external onlyAdmin {
        if (emissionManager_ == address(0)) revert EAL_ZeroAddress();
        
        address oldManager = emissionManager;
        emissionManager = emissionManager_;
        
        emit EmissionManagerUpdated(oldManager, emissionManager_);
    }

    function addAuditor(address auditor_) external onlyAdmin {
        if (auditor_ == address(0)) revert EAL_ZeroAddress();
        if (authorizedAuditors[auditor_]) revert EAL_AuditorAlreadyAdded();
        
        authorizedAuditors[auditor_] = true;
        auditors.push(auditor_);
        
        emit AuditorAdded(auditor_);
    }

    function removeAuditor(address auditor_) external onlyAdmin {
        if (!authorizedAuditors[auditor_]) revert EAL_AuditorNotFound();
        
        authorizedAuditors[auditor_] = false;
        
        // Remove from auditors array
        for (uint256 i = 0; i < auditors.length; i++) {
            if (auditors[i] == auditor_) {
                auditors[i] = auditors[auditors.length - 1];
                auditors.pop();
                break;
            }
        }
        
        emit AuditorRemoved(auditor_);
    }

    function exportAuditLog(uint256 startId, uint256 endId, string memory destination) external onlyAdmin {
        if (startId >= endId || endId > nextEventId) revert EAL_InvalidParameter();
        
        // this would export the audit log to an external system
        // For example, it might emit events with the audit data or call an oracle
        
        emit AuditLogExported(startId, endId, destination);
    }

    function verifyAuditEvent(uint256 eventId) external onlyAuthorized {
        if (eventId == 0 || eventId >= nextEventId) revert EAL_EventNotFound();
        
        AuditEvent storage event_ = auditEvents[eventId];
        event_.verified = true;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function logEmissionEvent(address token, uint256 amount, string memory eventType, address initiator) external onlyAuthorized returns (uint256) {
        if (token == address(0)) revert EAL_ZeroAddress();
        if (bytes(eventType).length == 0) revert EAL_InvalidParameter();
        
        uint256 eventId = nextEventId++;
        
        // Create event details string
        string memory details = string(abi.encodePacked(
            "Amount: ", _uintToString(amount)
        ));
        
        // Store the audit event
        auditEvents[eventId] = AuditEvent({
            id: eventId,
            timestamp: block.timestamp,
            token: token,
            eventType: eventType,
            details: details,
            initiator: initiator,
            verified: false
        });
        
        // Update indexes
        tokenEvents[token].push(eventId);
        initiatorEvents[initiator].push(eventId);
        eventTypeIndex[eventType].push(eventId);
        
        emit AuditEventLogged(eventId, token, eventType, initiator);
        
        return eventId;
    }

    function logRateChange(address token, uint256 oldRate, uint256 newRate, address initiator) external onlyAuthorized returns (uint256) {
        if (token == address(0)) revert EAL_ZeroAddress();
        
        uint256 eventId = nextEventId++;
        
        // Create event details string
        string memory details = string(abi.encodePacked(
            "Old Rate: ", _uintToString(oldRate),
            ", New Rate: ", _uintToString(newRate)
        ));
        
        // Store the audit event
        auditEvents[eventId] = AuditEvent({
            id: eventId,
            timestamp: block.timestamp,
            token: token,
            eventType: "rate_change",
            details: details,
            initiator: initiator,
            verified: false
        });
        
        // Update indexes
        tokenEvents[token].push(eventId);
        initiatorEvents[initiator].push(eventId);
        eventTypeIndex["rate_change"].push(eventId);
        
        emit AuditEventLogged(eventId, token, "rate_change", initiator);
        
        return eventId;
    }

    function logEmergencyAction(address token, string memory action, string memory reason, address initiator) external onlyAuthorized returns (uint256) {
        if (token == address(0)) revert EAL_ZeroAddress();
        if (bytes(action).length == 0) revert EAL_InvalidParameter();
        
        uint256 eventId = nextEventId++;
        
        // Create event details string
        string memory details = string(abi.encodePacked(
            "Action: ", action,
            ", Reason: ", reason
        ));
        
        // Store the audit event
        auditEvents[eventId] = AuditEvent({
            id: eventId,
            timestamp: block.timestamp,
            token: token,
            eventType: "emergency",
            details: details,
            initiator: initiator,
            verified: false
        });
        
        // Update indexes
        tokenEvents[token].push(eventId);
        initiatorEvents[initiator].push(eventId);
        eventTypeIndex["emergency"].push(eventId);
        
        emit AuditEventLogged(eventId, token, "emergency", initiator);
        
        return eventId;
    }

    function logCustomEvent(address token, string memory eventType, string memory details, address initiator) external onlyAuthorized returns (uint256) {
        if (token == address(0)) revert EAL_ZeroAddress();
        if (bytes(eventType).length == 0) revert EAL_InvalidParameter();
        
        uint256 eventId = nextEventId++;
        
        // Store the audit event
        auditEvents[eventId] = AuditEvent({
            id: eventId,
            timestamp: block.timestamp,
            token: token,
            eventType: eventType,
            details: details,
            initiator: initiator,
            verified: false
        });
        
        // Update indexes
        tokenEvents[token].push(eventId);
        initiatorEvents[initiator].push(eventId);
        eventTypeIndex[eventType].push(eventId);
        
        emit AuditEventLogged(eventId, token, eventType, initiator);
        
        return eventId;
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getAuditEvent(uint256 eventId) external view returns (
        uint256 timestamp,
        address token,
        string memory eventType,
        string memory details,
        address initiator
    ) {
        if (eventId == 0 || eventId >= nextEventId) revert EAL_EventNotFound();
        
        AuditEvent memory event_ = auditEvents[eventId];
        
        return (
            event_.timestamp,
            event_.token,
            event_.eventType,
            event_.details,
            event_.initiator
        );
    }

    function getAuditEventsByToken(address token) external view returns (uint256[] memory) {
        return tokenEvents[token];
    }

    function getAuditEventsByInitiator(address initiator) external view returns (uint256[] memory) {
        return initiatorEvents[initiator];
    }

    function getAuditEventsByType(string memory eventType) external view returns (uint256[] memory) {
        return eventTypeIndex[eventType];
    }

    function getAuditEventsByTimeRange(uint256 startTime, uint256 endTime) external view returns (uint256[] memory eventIds) {
        if (startTime >= endTime) revert EAL_InvalidParameter();
        
        // Count events in range
        uint256 count = 0;
        for (uint256 i = 1; i < nextEventId; i++) {
            if (auditEvents[i].timestamp >= startTime && auditEvents[i].timestamp <= endTime) {
                count++;
            }
        }
        
        // Create result array
        eventIds = new uint256[](count);
        
        // Fill result array
        uint256 index = 0;
        for (uint256 i = 1; i < nextEventId; i++) {
            if (auditEvents[i].timestamp >= startTime && auditEvents[i].timestamp <= endTime) {
                eventIds[index] = i;
                index++;
            }
        }
        
        return eventIds;
    }

    function getAuditors() external view returns (address[] memory) {
        return auditors;
    }

    function isAuditor(address account) external view returns (bool) {
        return authorizedAuditors[account];
    }

    function getEventCount() external view returns (uint256) {
        return nextEventId - 1;
    }

    function getEventVerificationStatus(uint256 eventId) external view returns (bool) {
        if (eventId == 0 || eventId >= nextEventId) revert EAL_EventNotFound();
        
        return auditEvents[eventId].verified;
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

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
}