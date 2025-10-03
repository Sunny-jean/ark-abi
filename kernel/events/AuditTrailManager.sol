// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Audit Trail Manager
/// @notice Manages audit trails for system actions and changes
interface IAuditTrailManager {
    function recordAudit(bytes32 actionType_, address actor_, bytes memory data_) external;
    function getAuditCount() external view returns (uint256);
    function getAuditsByType(bytes32 actionType_, uint256 offset_, uint256 limit_) external view returns (uint256[] memory);
    function getAuditsByActor(address actor_, uint256 offset_, uint256 limit_) external view returns (uint256[] memory);
}

contract AuditTrailManager is IAuditTrailManager {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event AuditRecorded(bytes32 indexed actionType, address indexed actor, bytes data, uint256 timestamp);
    event ActionTypeRegistered(bytes32 indexed actionType, string name, uint256 severity);
    event ActionTypeDeregistered(bytes32 indexed actionType);
    event AuditorAdded(address indexed auditor);
    event AuditorRemoved(address indexed auditor);
    event AuditTrailManagerAdminChanged(address indexed oldAdmin, address indexed newAdmin);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error AuditTrailManager_OnlyAdmin(address caller_);
    error AuditTrailManager_OnlyAuditor(address caller_);
    error AuditTrailManager_InvalidAddress(address addr_);
    error AuditTrailManager_ActionTypeNotRegistered(bytes32 actionType_);
    error AuditTrailManager_ActionTypeAlreadyRegistered(bytes32 actionType_);
    error AuditTrailManager_AuditorAlreadyAdded(address auditor_);
    error AuditTrailManager_AuditorNotFound(address auditor_);
    error AuditTrailManager_InvalidSeverity(uint256 severity_);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    enum Severity {
        Low,
        Medium,
        High,
        Critical
    }

    struct ActionType {
        bytes32 id;
        string name;
        uint256 severity; // 0=Low, 1=Medium, 2=High, 3=Critical
        bool isRegistered;
    }

    struct AuditRecord {
        bytes32 actionType;
        address actor;
        bytes data;
        uint256 timestamp;
        uint256 blockNumber;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    
    // Auditors
    mapping(address => bool) public isAuditor;
    address[] public auditors;
    
    // Action types
    mapping(bytes32 => ActionType) public actionTypes;
    mapping(string => bytes32) public actionTypeIdByName;
    bytes32[] public registeredActionTypes;
    
    // Audit records
    AuditRecord[] public auditRecords;
    mapping(bytes32 => uint256[]) public auditsByType;
    mapping(address => uint256[]) public auditsByActor;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert AuditTrailManager_OnlyAdmin(msg.sender);
        _;
    }

    modifier onlyAuditor() {
        if (!isAuditor[msg.sender]) revert AuditTrailManager_OnlyAuditor(msg.sender);
        _;
    }

    modifier actionTypeRegistered(bytes32 actionType_) {
        if (!actionTypes[actionType_].isRegistered) {
            revert AuditTrailManager_ActionTypeNotRegistered(actionType_);
        }
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_) {
        if (admin_ == address(0)) revert AuditTrailManager_InvalidAddress(admin_);
        
        admin = admin_;
        
        // Add admin as auditor
        _addAuditor(admin_);
        
        // Initialize default action types
        _registerActionType("MODULE_INSTALLED", keccak256("MODULE_INSTALLED"), 2); // High
        _registerActionType("MODULE_UPGRADED", keccak256("MODULE_UPGRADED"), 2); // High
        _registerActionType("MODULE_REMOVED", keccak256("MODULE_REMOVED"), 2); // High
        _registerActionType("POLICY_CHANGED", keccak256("POLICY_CHANGED"), 1); // Medium
        _registerActionType("PERMISSION_GRANTED", keccak256("PERMISSION_GRANTED"), 2); // High
        _registerActionType("PERMISSION_REVOKED", keccak256("PERMISSION_REVOKED"), 2); // High
        _registerActionType("ADMIN_ACTION", keccak256("ADMIN_ACTION"), 3); // Critical
        _registerActionType("SECURITY_EVENT", keccak256("SECURITY_EVENT"), 3); // Critical
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Record an audit
    /// @param actionType_ The action type
    /// @param actor_ The actor address
    /// @param data_ The audit data
    function recordAudit(
        bytes32 actionType_,
        address actor_,
        bytes memory data_
    ) external override onlyAuditor actionTypeRegistered(actionType_) {
        // Create audit record
        AuditRecord memory newAudit = AuditRecord({
            actionType: actionType_,
            actor: actor_,
            data: data_,
            timestamp: block.timestamp,
            blockNumber: block.number
        });
        
        // Add to arrays
        uint256 auditId = auditRecords.length;
        auditRecords.push(newAudit);
        auditsByType[actionType_].push(auditId);
        auditsByActor[actor_].push(auditId);
        
        emit AuditRecorded(actionType_, actor_, data_, block.timestamp);
    }

    /// @notice Register an action type
    /// @param name_ The action type name
    /// @param actionType_ The action type ID
    /// @param severity_ The severity level (0=Low, 1=Medium, 2=High, 3=Critical)
    function registerActionType(
        string calldata name_,
        bytes32 actionType_,
        uint256 severity_
    ) external onlyAdmin {
        _registerActionType(name_, actionType_, severity_);
    }

    /// @notice Deregister an action type
    /// @param actionType_ The action type ID
    function deregisterActionType(bytes32 actionType_) external onlyAdmin actionTypeRegistered(actionType_) {
        // Remove name mapping
        delete actionTypeIdByName[actionTypes[actionType_].name];
        
        // Deregister action type
        actionTypes[actionType_].isRegistered = false;
        
        // Remove from array
        for (uint256 i = 0; i < registeredActionTypes.length; i++) {
            if (registeredActionTypes[i] == actionType_) {
                registeredActionTypes[i] = registeredActionTypes[registeredActionTypes.length - 1];
                registeredActionTypes.pop();
                break;
            }
        }
        
        emit ActionTypeDeregistered(actionType_);
    }

    /// @notice Add an auditor
    /// @param auditor_ The auditor address
    function addAuditor(address auditor_) external onlyAdmin {
        _addAuditor(auditor_);
    }

    /// @notice Remove an auditor
    /// @param auditor_ The auditor address
    function removeAuditor(address auditor_) external onlyAdmin {
        if (auditor_ == admin) revert AuditTrailManager_InvalidAddress(auditor_); // Can't remove admin
        if (!isAuditor[auditor_]) revert AuditTrailManager_AuditorNotFound(auditor_);
        
        // Remove auditor
        isAuditor[auditor_] = false;
        
        // Remove from array
        for (uint256 i = 0; i < auditors.length; i++) {
            if (auditors[i] == auditor_) {
                auditors[i] = auditors[auditors.length - 1];
                auditors.pop();
                break;
            }
        }
        
        emit AuditorRemoved(auditor_);
    }

    /// @notice Change the admin
    /// @param newAdmin_ The new admin address
    function changeAdmin(address newAdmin_) external onlyAdmin {
        if (newAdmin_ == address(0)) revert AuditTrailManager_InvalidAddress(newAdmin_);
        
        address oldAdmin = admin;
        admin = newAdmin_;
        
        // Add new admin as auditor if not already
        if (!isAuditor[newAdmin_]) {
            _addAuditor(newAdmin_);
        }
        
        emit AuditTrailManagerAdminChanged(oldAdmin, newAdmin_);
    }

    /// @notice Get the total audit count
    /// @return The total number of audits
    function getAuditCount() external view override returns (uint256) {
        return auditRecords.length;
    }

    /// @notice Get audits by type
    /// @param actionType_ The action type
    /// @param offset_ The offset
    /// @param limit_ The limit
    /// @return Array of audit IDs
    function getAuditsByType(
        bytes32 actionType_,
        uint256 offset_,
        uint256 limit_
    ) external view override actionTypeRegistered(actionType_) returns (uint256[] memory) {
        uint256[] storage audits = auditsByType[actionType_];
        
        // Calculate actual limit
        uint256 actualLimit = limit_;
        if (offset_ + actualLimit > audits.length) {
            actualLimit = audits.length > offset_ ? audits.length - offset_ : 0;
        }
        
        // Create result array
        uint256[] memory result = new uint256[](actualLimit);
        
        // Fill result array
        for (uint256 i = 0; i < actualLimit; i++) {
            result[i] = audits[offset_ + i];
        }
        
        return result;
    }

    /// @notice Get audits by actor
    /// @param actor_ The actor address
    /// @param offset_ The offset
    /// @param limit_ The limit
    /// @return Array of audit IDs
    function getAuditsByActor(
        address actor_,
        uint256 offset_,
        uint256 limit_
    ) external view override returns (uint256[] memory) {
        uint256[] storage audits = auditsByActor[actor_];
        
        // Calculate actual limit
        uint256 actualLimit = limit_;
        if (offset_ + actualLimit > audits.length) {
            actualLimit = audits.length > offset_ ? audits.length - offset_ : 0;
        }
        
        // Create result array
        uint256[] memory result = new uint256[](actualLimit);
        
        // Fill result array
        for (uint256 i = 0; i < actualLimit; i++) {
            result[i] = audits[offset_ + i];
        }
        
        return result;
    }

    /// @notice Get audit details
    /// @param auditId_ The audit ID
    /// @return actionType The action type
    /// @return actor The actor address
    /// @return data The audit data
    /// @return timestamp When the audit was recorded
    /// @return blockNumber The block number when the audit was recorded
    function getAuditDetails(uint256 auditId_) external view returns (
        bytes32 actionType,
        address actor,
        bytes memory data,
        uint256 timestamp,
        uint256 blockNumber
    ) {
        require(auditId_ < auditRecords.length, "Audit not found");
        
        AuditRecord memory audit = auditRecords[auditId_];
        return (
            audit.actionType,
            audit.actor,
            audit.data,
            audit.timestamp,
            audit.blockNumber
        );
    }

    /// @notice Get action type details
    /// @param actionType_ The action type ID
    /// @return id The action type ID
    /// @return name The action type name
    /// @return severity The severity level
    /// @return isRegistered Whether the action type is registered
    function getActionTypeDetails(bytes32 actionType_) external view returns (
        bytes32 id,
        string memory name,
        uint256 severity,
        bool isRegistered
    ) {
        ActionType memory actionType = actionTypes[actionType_];
        return (
            actionType.id,
            actionType.name,
            actionType.severity,
            actionType.isRegistered
        );
    }

    /// @notice Get all registered action types
    /// @return Array of action type IDs
    function getRegisteredActionTypes() external view returns (bytes32[] memory) {
        return registeredActionTypes;
    }

    /// @notice Get all auditors
    /// @return Array of auditor addresses
    function getAuditors() external view returns (address[] memory) {
        return auditors;
    }

    /// @notice Get audits by time range
    /// @param startTime_ The start time
    /// @param endTime_ The end time
    /// @param offset_ The offset
    /// @param limit_ The limit
    /// @return Array of audit IDs
    function getAuditsByTimeRange(
        uint256 startTime_,
        uint256 endTime_,
        uint256 offset_,
        uint256 limit_
    ) external view returns (uint256[] memory) {
        // Count audits in time range
        uint256 count = 0;
        for (uint256 i = 0; i < auditRecords.length; i++) {
            if (auditRecords[i].timestamp >= startTime_ && auditRecords[i].timestamp <= endTime_) {
                count++;
            }
        }
        
        // Calculate actual limit
        uint256 actualLimit = limit_;
        if (offset_ + actualLimit > count) {
            actualLimit = count > offset_ ? count - offset_ : 0;
        }
        
        // Create result array
        uint256[] memory result = new uint256[](actualLimit);
        
        // Fill result array
        uint256 resultIndex = 0;
        uint256 skipped = 0;
        
        for (uint256 i = 0; i < auditRecords.length && resultIndex < actualLimit; i++) {
            if (auditRecords[i].timestamp >= startTime_ && auditRecords[i].timestamp <= endTime_) {
                if (skipped < offset_) {
                    skipped++;
                } else {
                    result[resultIndex++] = i;
                }
            }
        }
        
        return result;
    }

    /// @notice Get audits by severity
    /// @param severity_ The severity level
    /// @param offset_ The offset
    /// @param limit_ The limit
    /// @return Array of audit IDs
    function getAuditsBySeverity(
        uint256 severity_,
        uint256 offset_,
        uint256 limit_
    ) external view returns (uint256[] memory) {
        if (severity_ > 3) revert AuditTrailManager_InvalidSeverity(severity_);
        
        // Count audits with this severity
        uint256 count = 0;
        for (uint256 i = 0; i < auditRecords.length; i++) {
            if (actionTypes[auditRecords[i].actionType].severity == severity_) {
                count++;
            }
        }
        
        // Calculate actual limit
        uint256 actualLimit = limit_;
        if (offset_ + actualLimit > count) {
            actualLimit = count > offset_ ? count - offset_ : 0;
        }
        
        // Create result array
        uint256[] memory result = new uint256[](actualLimit);
        
        // Fill result array
        uint256 resultIndex = 0;
        uint256 skipped = 0;
        
        for (uint256 i = 0; i < auditRecords.length && resultIndex < actualLimit; i++) {
            if (actionTypes[auditRecords[i].actionType].severity == severity_) {
                if (skipped < offset_) {
                    skipped++;
                } else {
                    result[resultIndex++] = i;
                }
            }
        }
        
        return result;
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Internal function to register an action type
    /// @param name_ The action type name
    /// @param actionType_ The action type ID
    /// @param severity_ The severity level
    function _registerActionType(string memory name_, bytes32 actionType_, uint256 severity_) internal {
        if (actionTypes[actionType_].isRegistered) {
            revert AuditTrailManager_ActionTypeAlreadyRegistered(actionType_);
        }
        if (severity_ > 3) revert AuditTrailManager_InvalidSeverity(severity_);
        
        // Register action type
        actionTypes[actionType_] = ActionType({
            id: actionType_,
            name: name_,
            severity: severity_,
            isRegistered: true
        });
        
        // Map name to ID
        actionTypeIdByName[name_] = actionType_;
        
        // Add to array
        registeredActionTypes.push(actionType_);
        
        emit ActionTypeRegistered(actionType_, name_, severity_);
    }

    /// @notice Internal function to add an auditor
    /// @param auditor_ The auditor address
    function _addAuditor(address auditor_) internal {
        if (auditor_ == address(0)) revert AuditTrailManager_InvalidAddress(auditor_);
        if (isAuditor[auditor_]) revert AuditTrailManager_AuditorAlreadyAdded(auditor_);
        
        isAuditor[auditor_] = true;
        auditors.push(auditor_);
        
        emit AuditorAdded(auditor_);
    }
}