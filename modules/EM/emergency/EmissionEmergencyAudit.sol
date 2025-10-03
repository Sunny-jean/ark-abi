// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Emission Manager interface
/// @notice interface for the emission manager contract
interface IEmissionManager {
    function isEmissionPaused() external view returns (bool);
    function getEmissionRate() external view returns (uint256);
    function getTotalEmitted() external view returns (uint256);
    function getLastEmissionBlock() external view returns (uint256);
}

/// @title Emergency Emission Stopper interface
/// @notice interface for the emergency emission stopper contract
interface IEmergencyEmissionStopper {
    function isEmergencyActive() external view returns (bool);
    function getLastEmergencyTimestamp() external view returns (uint256);
    function getEmergencyCount() external view returns (uint256);
    function getEmergencyDetails(uint256 index) external view returns (
        address triggeredBy,
        uint256 timestamp,
        string memory reason,
        bool resolved,
        uint256 resolutionTimestamp
    );
}

/// @title Emission Security Manager interface
/// @notice interface for the emission security manager contract
interface IEmissionSecurityManager {
    function getSecurityAlertCount() external view returns (uint256);
    function getActiveSecurityAlertCount() external view returns (uint256);
    function getSecurityAlertDetails(uint256 alertId) external view returns (
        address reporter,
        uint256 timestamp,
        string memory description,
        uint8 severity,
        bool requiresAction,
        bool resolved,
        uint256 resolutionTimestamp,
        address resolver
    );
}

/// @title Emission Emergency Audit interface
/// @notice interface for the emission emergency audit contract
interface IEmissionEmergencyAudit {
    function recordEmergencyAudit() external returns (uint256);
    function getEmergencyAuditCount() external view returns (uint256);
    function getEmergencyAuditDetails(uint256 auditId) external view returns (
        uint256 timestamp,
        bool emergencyActive,
        uint256 emissionRate,
        uint256 totalEmitted,
        uint256 lastEmissionBlock,
        uint256 activeSecurityAlerts,
        uint256 totalEmergencyCount
    );
}

/// @title Emission Emergency Audit
/// @notice Records and audits emergency situations in the emission system
contract EmissionEmergencyAudit {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event EmergencyAuditRecorded(uint256 indexed auditId, address indexed auditor, uint256 timestamp);
    event AuditReportGenerated(uint256 indexed auditId, address indexed requester, uint256 timestamp);
    event AuditorAdded(address indexed auditor);
    event AuditorRemoved(address indexed auditor);
    event EmergencyContractUpdated(string contractType, address indexed oldContract, address indexed newContract);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error EEA_OnlyAdmin();
    error EEA_OnlyAuditor();
    error EEA_ZeroAddress();
    error EEA_InvalidParameter();
    error EEA_AuditNotFound();
    error EEA_AlreadyAuthorized();
    error EEA_NotAuthorized();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct EmergencyAudit {
        uint256 id;
        address auditor;
        uint256 timestamp;
        
        // Emission state
        bool emergencyActive;
        uint256 emissionRate;
        uint256 totalEmitted;
        uint256 lastEmissionBlock;
        
        // Security state
        uint256 activeSecurityAlerts;
        uint256 totalEmergencyCount;
        
        // Latest emergency details
        uint256 lastEmergencyTimestamp;
        address lastEmergencyTrigger;
        string lastEmergencyReason;
    }

    struct AuditReport {
        uint256 auditId;
        address requester;
        uint256 timestamp;
        string reportHash; // IPFS or other storage hash
        string reportURI;  // URI to access the report
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public emissionManager;
    address public emergencyEmissionStopper;
    address public emissionSecurityManager;
    
    // Auditors
    mapping(address => bool) public authorizedAuditors;
    address[] public auditorList;
    
    // Audit records
    mapping(uint256 => EmergencyAudit) public emergencyAudits;
    uint256 public auditCounter;
    
    // Audit reports
    mapping(uint256 => AuditReport) public auditReports;
    
    // Audit schedule
    uint256 public auditFrequency = 1 days;
    uint256 public lastScheduledAudit;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert EEA_OnlyAdmin();
        _;
    }

    modifier onlyAuditor() {
        if (!authorizedAuditors[msg.sender] && msg.sender != admin) revert EEA_OnlyAuditor();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(
        address admin_,
        address emissionManager_,
        address emergencyEmissionStopper_,
        address emissionSecurityManager_
    ) {
        if (admin_ == address(0) || emissionManager_ == address(0) ||
            emergencyEmissionStopper_ == address(0) || emissionSecurityManager_ == address(0)) {
            revert EEA_ZeroAddress();
        }
        
        admin = admin_;
        emissionManager = emissionManager_;
        emergencyEmissionStopper = emergencyEmissionStopper_;
        emissionSecurityManager = emissionSecurityManager_;
        
        // Add admin as auditor
        authorizedAuditors[admin_] = true;
        auditorList.push(admin_);
        
        lastScheduledAudit = block.timestamp;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function addAuditor(address auditor_) external onlyAdmin {
        if (auditor_ == address(0)) revert EEA_ZeroAddress();
        if (authorizedAuditors[auditor_]) revert EEA_AlreadyAuthorized();
        
        authorizedAuditors[auditor_] = true;
        auditorList.push(auditor_);
        
        emit AuditorAdded(auditor_);
    }

    function removeAuditor(address auditor_) external onlyAdmin {
        if (auditor_ == admin) revert EEA_InvalidParameter(); // Cannot remove admin
        if (!authorizedAuditors[auditor_]) revert EEA_NotAuthorized();
        
        authorizedAuditors[auditor_] = false;
        
        // Remove from auditor list
        for (uint256 i = 0; i < auditorList.length; i++) {
            if (auditorList[i] == auditor_) {
                auditorList[i] = auditorList[auditorList.length - 1];
                auditorList.pop();
                break;
            }
        }
        
        emit AuditorRemoved(auditor_);
    }

    function setEmergencyEmissionStopper(address stopper_) external onlyAdmin {
        if (stopper_ == address(0)) revert EEA_ZeroAddress();
        
        address oldStopper = emergencyEmissionStopper;
        emergencyEmissionStopper = stopper_;
        
        emit EmergencyContractUpdated("EmergencyEmissionStopper", oldStopper, stopper_);
    }

    function setEmissionSecurityManager(address manager_) external onlyAdmin {
        if (manager_ == address(0)) revert EEA_ZeroAddress();
        
        address oldManager = emissionSecurityManager;
        emissionSecurityManager = manager_;
        
        emit EmergencyContractUpdated("EmissionSecurityManager", oldManager, manager_);
    }

    function setAuditFrequency(uint256 frequency_) external onlyAdmin {
        if (frequency_ < 1 hours || frequency_ > 30 days) revert EEA_InvalidParameter();
        
        auditFrequency = frequency_;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function recordEmergencyAudit() public onlyAuditor returns (uint256) {
        // Create new audit
        uint256 auditId = auditCounter++;
        
        // Get emission state
        bool emergencyActive = IEmergencyEmissionStopper(emergencyEmissionStopper).isEmergencyActive();
        uint256 emissionRate = IEmissionManager(emissionManager).getEmissionRate();
        uint256 totalEmitted = IEmissionManager(emissionManager).getTotalEmitted();
        uint256 lastEmissionBlock = IEmissionManager(emissionManager).getLastEmissionBlock();
        
        // Get security state
        uint256 activeSecurityAlerts = IEmissionSecurityManager(emissionSecurityManager).getActiveSecurityAlertCount();
        uint256 totalEmergencyCount = IEmergencyEmissionStopper(emergencyEmissionStopper).getEmergencyCount();
        
        // Get latest emergency details
        uint256 lastEmergencyTimestamp = IEmergencyEmissionStopper(emergencyEmissionStopper).getLastEmergencyTimestamp();
        
        // Initialize variables for latest emergency details
        address lastEmergencyTrigger = address(0);
        string memory lastEmergencyReason = "";
        
        // Get latest emergency details if there have been emergencies
        if (totalEmergencyCount > 0) {
            (lastEmergencyTrigger, , lastEmergencyReason, , ) = IEmergencyEmissionStopper(emergencyEmissionStopper).getEmergencyDetails(totalEmergencyCount - 1);
        }
        
        // Create emergency audit record
        EmergencyAudit memory audit = EmergencyAudit({
            id: auditId,
            auditor: msg.sender,
            timestamp: block.timestamp,
            emergencyActive: emergencyActive,
            emissionRate: emissionRate,
            totalEmitted: totalEmitted,
            lastEmissionBlock: lastEmissionBlock,
            activeSecurityAlerts: activeSecurityAlerts,
            totalEmergencyCount: totalEmergencyCount,
            lastEmergencyTimestamp: lastEmergencyTimestamp,
            lastEmergencyTrigger: lastEmergencyTrigger,
            lastEmergencyReason: lastEmergencyReason
        });
        
        emergencyAudits[auditId] = audit;
        lastScheduledAudit = block.timestamp;
        
        emit EmergencyAuditRecorded(auditId, msg.sender, block.timestamp);
        
        return auditId;
    }

    function generateAuditReport(uint256 auditId_, string calldata reportHash_, string calldata reportURI_) external onlyAuditor {
        if (auditId_ >= auditCounter) revert EEA_AuditNotFound();
        if (bytes(reportHash_).length == 0) revert EEA_InvalidParameter();
        
        // Create audit report
        AuditReport memory report = AuditReport({
            auditId: auditId_,
            requester: msg.sender,
            timestamp: block.timestamp,
            reportHash: reportHash_,
            reportURI: reportURI_
        });
        
        auditReports[auditId_] = report;
        
        emit AuditReportGenerated(auditId_, msg.sender, block.timestamp);
    }

    function checkAndPerformScheduledAudit() external onlyAuditor returns (bool) {
        if (block.timestamp < lastScheduledAudit + auditFrequency) {
            return false; // Not time for scheduled audit yet
        }
        
        // Record new audit
        recordEmergencyAudit();
        
        return true;
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getEmergencyAuditCount() external view returns (uint256) {
        return auditCounter;
    }

    function getAuditorCount() external view returns (uint256) {
        return auditorList.length;
    }

    function isAuthorizedAuditor(address account_) external view returns (bool) {
        return authorizedAuditors[account_];
    }

    function getEmergencyAuditDetails(uint256 auditId_) external view returns (
        uint256 timestamp,
        bool emergencyActive,
        uint256 emissionRate,
        uint256 totalEmitted,
        uint256 lastEmissionBlock,
        uint256 activeSecurityAlerts,
        uint256 totalEmergencyCount
    ) {
        if (auditId_ >= auditCounter) revert EEA_AuditNotFound();
        
        EmergencyAudit memory audit = emergencyAudits[auditId_];
        return (
            audit.timestamp,
            audit.emergencyActive,
            audit.emissionRate,
            audit.totalEmitted,
            audit.lastEmissionBlock,
            audit.activeSecurityAlerts,
            audit.totalEmergencyCount
        );
    }

    function getEmergencyAuditExtendedDetails(uint256 auditId_) external view returns (
        address auditor,
        uint256 lastEmergencyTimestamp,
        address lastEmergencyTrigger,
        string memory lastEmergencyReason
    ) {
        if (auditId_ >= auditCounter) revert EEA_AuditNotFound();
        
        EmergencyAudit memory audit = emergencyAudits[auditId_];
        return (
            audit.auditor,
            audit.lastEmergencyTimestamp,
            audit.lastEmergencyTrigger,
            audit.lastEmergencyReason
        );
    }

    function getAuditReportDetails(uint256 auditId_) external view returns (
        address requester,
        uint256 timestamp,
        string memory reportHash,
        string memory reportURI
    ) {
        if (auditId_ >= auditCounter) revert EEA_AuditNotFound();
        
        AuditReport memory report = auditReports[auditId_];
        return (
            report.requester,
            report.timestamp,
            report.reportHash,
            report.reportURI
        );
    }

    function getTimeUntilNextScheduledAudit() external view returns (uint256) {
        if (block.timestamp >= lastScheduledAudit + auditFrequency) {
            return 0; // Audit is due now
        }
        
        return lastScheduledAudit + auditFrequency - block.timestamp;
    }
}