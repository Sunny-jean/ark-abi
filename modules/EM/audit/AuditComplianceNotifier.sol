// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Emission Compliance Checker interface
/// @notice interface for the emission compliance checker contract
interface IEmissionComplianceChecker {
    function checkCompliance(address token) external returns (bool compliant, string memory details);
    function getComplianceStatus(address token) external view returns (bool compliant, uint256 lastChecked, string memory details);
    function getComplianceHistory(address token) external view returns (uint256[] memory timestamps, bool[] memory statuses);
    function getComplianceRules(address token) external view returns (string[] memory ruleNames, bool[] memory enabled);
    function getGlobalComplianceStatus() external view returns (uint256 compliantTokens, uint256 totalTokens);
}

/// @title Emission Audit Log interface
/// @notice interface for the emission audit log contract
interface IEmissionAuditLog {
    function logEmissionEvent(address token, uint256 amount, string memory eventType, address initiator) external returns (uint256 eventId);
    function logRateChange(address token, uint256 oldRate, uint256 newRate, address initiator) external returns (uint256 eventId);
    function logEmergencyAction(address token, string memory actionType, string memory reason, address initiator) external returns (uint256 eventId);
    function logCustomEvent(address token, string memory eventType, string memory details, address initiator) external returns (uint256 eventId);
}

/// @title Emission Manager interface
/// @notice interface for the emission manager contract
interface IEmissionManager {
    function getEmissionRate(address token) external view returns (uint256);
    function getTotalEmitted(address token) external view returns (uint256);
    function getEmissionStartTime(address token) external view returns (uint256);
    function getSupportedTokens() external view returns (address[] memory);
}

/// @title Audit Compliance Notifier interface
/// @notice interface for the audit compliance notifier contract
interface IAuditComplianceNotifier {
    function notifyComplianceViolation(address token, string memory details) external;
    function notifyEmergencyEvent(address token, string memory eventType, string memory details) external;
    function notifySystemEvent(string memory category, string memory details) external;
    function getNotificationCount() external view returns (uint256);
    function getNotificationsByToken(address token, uint256 startIndex, uint256 count) external view returns (uint256[] memory notificationIds);
    function getNotificationsByType(string memory notificationType, uint256 startIndex, uint256 count) external view returns (uint256[] memory notificationIds);
    function getNotificationDetails(uint256 notificationId) external view returns (address token, string memory notificationType, uint256 timestamp, string memory details, bool acknowledged);
}

/// @title Audit Compliance Notifier
/// @notice Notifies relevant parties about compliance violations and audit events
contract AuditComplianceNotifier {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event NotificationSent(uint256 indexed notificationId, address indexed token, string indexed notificationType, uint256 timestamp);
    event NotificationAcknowledged(uint256 indexed notificationId, address indexed acknowledgedBy, uint256 timestamp);
    event NotifierAdded(address indexed notifier, string notifierType);
    event NotifierRemoved(address indexed notifier);
    event ComplianceCheckerUpdated(address indexed oldChecker, address indexed newChecker);
    event AuditLogUpdated(address indexed oldLog, address indexed newLog);
    event EmissionManagerUpdated(address indexed oldManager, address indexed newManager);
    event NotificationThresholdUpdated(string indexed thresholdType, uint256 oldValue, uint256 newValue);
    event AutoCheckingToggled(bool enabled);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error ACN_OnlyAdmin();
    error ACN_OnlyNotifier();
    error ACN_ZeroAddress();
    error ACN_TokenNotSupported();
    error ACN_InvalidNotificationId();
    error ACN_InvalidParameter();
    error ACN_NotifierAlreadyAdded();
    error ACN_NotifierNotFound();
    error ACN_DependencyNotSet();
    error ACN_NotificationAlreadyAcknowledged();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct Notification {
        uint256 id;
        address token; // Zero address for system-wide notifications
        string notificationType;
        uint256 timestamp;
        string details;
        bool acknowledged;
        address acknowledgedBy;
        uint256 acknowledgedAt;
    }

    struct Notifier {
        address addr;
        string notifierType; // "email", "webhook", "contract", etc.
        bool active;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public complianceChecker;
    address public auditLog;
    address public emissionManager;
    
    // Notifications
    mapping(uint256 => Notification) public notifications;
    uint256 public notificationCount;
    
    // Notification indices
    mapping(address => uint256[]) public tokenNotifications; // token => notificationIds
    mapping(string => uint256[]) public typeNotifications; // notificationType => notificationIds
    
    // Notifiers
    mapping(address => Notifier) public notifiers;
    address[] public notifierList;
    
    // Thresholds and settings
    uint256 public complianceCheckInterval = 86400; // 24 hours
    uint256 public lastGlobalComplianceCheck;
    bool public autoCheckingEnabled = true;
    uint256 public criticalThreshold = 3; // Number of consecutive violations to consider critical
    uint256 public warningThreshold = 1; // Number of consecutive violations to issue warning

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert ACN_OnlyAdmin();
        _;
    }

    modifier onlyNotifier() {
        if (msg.sender != admin && !notifiers[msg.sender].active) revert ACN_OnlyNotifier();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address complianceChecker_, address auditLog_, address emissionManager_) {
        if (admin_ == address(0)) revert ACN_ZeroAddress();
        
        admin = admin_;
        
        if (complianceChecker_ != address(0)) complianceChecker = complianceChecker_;
        if (auditLog_ != address(0)) auditLog = auditLog_;
        if (emissionManager_ != address(0)) emissionManager = emissionManager_;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function setComplianceChecker(address complianceChecker_) external onlyAdmin {
        if (complianceChecker_ == address(0)) revert ACN_ZeroAddress();
        
        address oldChecker = complianceChecker;
        complianceChecker = complianceChecker_;
        
        emit ComplianceCheckerUpdated(oldChecker, complianceChecker_);
    }

    function setAuditLog(address auditLog_) external onlyAdmin {
        if (auditLog_ == address(0)) revert ACN_ZeroAddress();
        
        address oldLog = auditLog;
        auditLog = auditLog_;
        
        emit AuditLogUpdated(oldLog, auditLog_);
    }

    function setEmissionManager(address emissionManager_) external onlyAdmin {
        if (emissionManager_ == address(0)) revert ACN_ZeroAddress();
        
        address oldManager = emissionManager;
        emissionManager = emissionManager_;
        
        emit EmissionManagerUpdated(oldManager, emissionManager_);
    }

    function addNotifier(address notifier, string memory notifierType) external onlyAdmin {
        if (notifier == address(0)) revert ACN_ZeroAddress();
        if (notifiers[notifier].active) revert ACN_NotifierAlreadyAdded();
        
        notifiers[notifier] = Notifier({
            addr: notifier,
            notifierType: notifierType,
            active: true
        });
        
        notifierList.push(notifier);
        
        emit NotifierAdded(notifier, notifierType);
    }

    function removeNotifier(address notifier) external onlyAdmin {
        if (!notifiers[notifier].active) revert ACN_NotifierNotFound();
        
        notifiers[notifier].active = false;
        
        // Remove from notifierList
        for (uint256 i = 0; i < notifierList.length; i++) {
            if (notifierList[i] == notifier) {
                notifierList[i] = notifierList[notifierList.length - 1];
                notifierList.pop();
                break;
            }
        }
        
        emit NotifierRemoved(notifier);
    }

    function setThresholds(uint256 warning, uint256 critical) external onlyAdmin {
        if (warning > 0 && warning != warningThreshold) {
            uint256 oldValue = warningThreshold;
            warningThreshold = warning;
            emit NotificationThresholdUpdated("warning", oldValue, warning);
        }
        
        if (critical > 0 && critical != criticalThreshold) {
            uint256 oldValue = criticalThreshold;
            criticalThreshold = critical;
            emit NotificationThresholdUpdated("critical", oldValue, critical);
        }
    }

    function setComplianceCheckInterval(uint256 interval) external onlyAdmin {
        if (interval == 0) revert ACN_InvalidParameter();
        
        uint256 oldValue = complianceCheckInterval;
        complianceCheckInterval = interval;
        
        emit NotificationThresholdUpdated("check_interval", oldValue, interval);
    }

    function toggleAutoChecking(bool enabled) external onlyAdmin {
        autoCheckingEnabled = enabled;
        
        emit AutoCheckingToggled(enabled);
    }

    function acknowledgeNotification(uint256 notificationId) external onlyAdmin {
        if (notificationId >= notificationCount) revert ACN_InvalidNotificationId();
        if (notifications[notificationId].acknowledged) revert ACN_NotificationAlreadyAcknowledged();
        
        notifications[notificationId].acknowledged = true;
        notifications[notificationId].acknowledgedBy = msg.sender;
        notifications[notificationId].acknowledgedAt = block.timestamp;
        
        emit NotificationAcknowledged(notificationId, msg.sender, block.timestamp);
    }

    function checkAllTokensCompliance() public returns (uint256 compliantCount, uint256 totalCount) {
        if (complianceChecker == address(0) || emissionManager == address(0)) revert ACN_DependencyNotSet();
        
        address[] memory tokens = IEmissionManager(emissionManager).getSupportedTokens();
        totalCount = tokens.length;
        compliantCount = 0;
        
        for (uint256 i = 0; i < tokens.length; i++) {
            (bool compliant, string memory details) = IEmissionComplianceChecker(complianceChecker).checkCompliance(tokens[i]);
            
            if (compliant) {
                compliantCount++;
            } else {
                // Create notification for non-compliant token
                _createNotification(tokens[i], "compliance_violation", details);
            }
        }
        
        lastGlobalComplianceCheck = block.timestamp;
        
        // Log to audit log
        if (auditLog != address(0)) {
            string memory details = string(abi.encodePacked(
                "Compliance check: ", _uintToString(compliantCount), "/", _uintToString(totalCount), " tokens compliant"
            ));
            
            IEmissionAuditLog(auditLog).logCustomEvent(
                address(0),
                "global_compliance_check",
                details,
                msg.sender
            );
        }
        
        return (compliantCount, totalCount);
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function notifyComplianceViolation(address token, string memory details) external onlyNotifier {
        if (emissionManager == address(0)) revert ACN_DependencyNotSet();
        
        // Check if token is supported by emission manager
        _validateToken(token);
        
        // Create notification
        uint256 notificationId = _createNotification(token, "compliance_violation", details);
        
        // Log to audit log
        if (auditLog != address(0)) {
            IEmissionAuditLog(auditLog).logCustomEvent(
                token,
                "compliance_violation",
                details,
                msg.sender
            );
        }
        

    }

    function notifyEmergencyEvent(address token, string memory eventType, string memory details) external onlyNotifier {
        if (emissionManager == address(0)) revert ACN_DependencyNotSet();
        
        // Check if token is supported by emission manager
        _validateToken(token);
        
        // Create notification
        string memory fullType = string(abi.encodePacked("emergency_", eventType));
        uint256 notificationId = _createNotification(token, fullType, details);
        
        // Log to audit log
        if (auditLog != address(0)) {
            IEmissionAuditLog(auditLog).logEmergencyAction(
                token,
                eventType,
                details,
                msg.sender
            );
        }
        

    }

    function notifySystemEvent(string memory category, string memory details) external onlyNotifier {
        // Create notification with zero address as token (system-wide)
        uint256 notificationId = _createNotification(address(0), category, details);
        
        // Log to audit log
        if (auditLog != address(0)) {
            IEmissionAuditLog(auditLog).logCustomEvent(
                address(0),
                category,
                details,
                msg.sender
            );
        }
        

    }

    function checkComplianceIfNeeded() external returns (bool checked) {
        if (!autoCheckingEnabled) return false;
        if (complianceChecker == address(0) || emissionManager == address(0)) revert ACN_DependencyNotSet();
        
        // Check if it's time for a compliance check
        if (block.timestamp >= lastGlobalComplianceCheck + complianceCheckInterval) {
            checkAllTokensCompliance();
            return true;
        }
        
        return false;
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getNotificationCount() external view returns (uint256) {
        return notificationCount;
    }

    function getNotificationsByToken(address token, uint256 startIndex, uint256 count) external view returns (uint256[] memory notificationIds) {
        uint256[] storage tokenNotificationIds = tokenNotifications[token];
        
        // Determine actual count based on available notifications
        uint256 available = tokenNotificationIds.length > startIndex ? tokenNotificationIds.length - startIndex : 0;
        uint256 actualCount = available < count ? available : count;
        
        notificationIds = new uint256[](actualCount);
        
        for (uint256 i = 0; i < actualCount; i++) {
            notificationIds[i] = tokenNotificationIds[startIndex + i];
        }
        
        return notificationIds;
    }

    function getNotificationsByType(string memory notificationType, uint256 startIndex, uint256 count) external view returns (uint256[] memory notificationIds) {
        uint256[] storage typeNotificationIds = typeNotifications[notificationType];
        
        // Determine actual count based on available notifications
        uint256 available = typeNotificationIds.length > startIndex ? typeNotificationIds.length - startIndex : 0;
        uint256 actualCount = available < count ? available : count;
        
        notificationIds = new uint256[](actualCount);
        
        for (uint256 i = 0; i < actualCount; i++) {
            notificationIds[i] = typeNotificationIds[startIndex + i];
        }
        
        return notificationIds;
    }

    function getNotificationDetails(uint256 notificationId) external view returns (address token, string memory notificationType, uint256 timestamp, string memory details, bool acknowledged) {
        if (notificationId >= notificationCount) revert ACN_InvalidNotificationId();
        
        Notification storage notification = notifications[notificationId];
        
        return (
            notification.token,
            notification.notificationType,
            notification.timestamp,
            notification.details,
            notification.acknowledged
        );
    }

    function getNotificationAcknowledgement(uint256 notificationId) external view returns (bool acknowledged, address acknowledgedBy, uint256 acknowledgedAt) {
        if (notificationId >= notificationCount) revert ACN_InvalidNotificationId();
        
        Notification storage notification = notifications[notificationId];
        
        return (
            notification.acknowledged,
            notification.acknowledgedBy,
            notification.acknowledgedAt
        );
    }

    function getUnacknowledgedNotifications(uint256 startIndex, uint256 count) external view returns (uint256[] memory notificationIds) {
        // Count unacknowledged notifications
        uint256 unacknowledgedCount = 0;
        for (uint256 i = 0; i < notificationCount; i++) {
            if (!notifications[i].acknowledged) {
                unacknowledgedCount++;
            }
        }
        
        // Determine actual count based on available notifications
        uint256 available = unacknowledgedCount > startIndex ? unacknowledgedCount - startIndex : 0;
        uint256 actualCount = available < count ? available : count;
        
        notificationIds = new uint256[](actualCount);
        
        // Fill the array
        uint256 index = 0;
        uint256 skipped = 0;
        for (uint256 i = 0; i < notificationCount && index < actualCount; i++) {
            if (!notifications[i].acknowledged) {
                if (skipped >= startIndex) {
                    notificationIds[index] = i;
                    index++;
                } else {
                    skipped++;
                }
            }
        }
        
        return notificationIds;
    }

    function getNotifierCount() external view returns (uint256) {
        return notifierList.length;
    }

    function getNotifiers() external view returns (address[] memory) {
        return notifierList;
    }

    function getNotifierDetails(address notifier) external view returns (string memory notifierType, bool active) {
        Notifier storage notifierData = notifiers[notifier];
        
        return (notifierData.notifierType, notifierData.active);
    }

    function getThresholds() external view returns (uint256 warning, uint256 critical, uint256 checkInterval) {
        return (warningThreshold, criticalThreshold, complianceCheckInterval);
    }

    function getLastGlobalComplianceCheck() external view returns (uint256) {
        return lastGlobalComplianceCheck;
    }

    function isAutoCheckingEnabled() external view returns (bool) {
        return autoCheckingEnabled;
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function _createNotification(address token, string memory notificationType, string memory details) internal returns (uint256 notificationId) {
        notificationId = notificationCount;
        
        // Create notification
        notifications[notificationId] = Notification({
            id: notificationId,
            token: token,
            notificationType: notificationType,
            timestamp: block.timestamp,
            details: details,
            acknowledged: false,
            acknowledgedBy: address(0),
            acknowledgedAt: 0
        });
        
        // Update indices
        tokenNotifications[token].push(notificationId);
        typeNotifications[notificationType].push(notificationId);
        
        // Increment notification count
        notificationCount++;
        
        emit NotificationSent(notificationId, token, notificationType, block.timestamp);
        
        return notificationId;
    }

    function _validateToken(address token) internal view {
        if (token == address(0)) revert ACN_ZeroAddress();
        
        // Check if token is supported by emission manager
        address[] memory supportedTokens = IEmissionManager(emissionManager).getSupportedTokens();
        bool tokenFound = false;
        
        for (uint256 i = 0; i < supportedTokens.length; i++) {
            if (supportedTokens[i] == token) {
                tokenFound = true;
                break;
            }
        }
        
        if (!tokenFound) revert ACN_TokenNotSupported();
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
}