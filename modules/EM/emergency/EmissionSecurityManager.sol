// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Emission Manager interface
/// @notice interface for the emission manager contract
interface IEmissionManager {
    function pauseEmissions() external;
    function resumeEmissions() external;
    function isEmissionPaused() external view returns (bool);
    function getEmissionRate() external view returns (uint256);
    function getTotalEmitted() external view returns (uint256);
    function getLastEmissionBlock() external view returns (uint256);
}

/// @title Emergency Emission Stopper interface
/// @notice interface for the emergency emission stopper contract
interface IEmergencyEmissionStopper {
    function triggerEmergencyStop(string calldata reason) external;
    function cancelEmergencyStop() external;
    function isEmergencyActive() external view returns (bool);
}

/// @title Emission Rate Limiter interface
/// @notice interface for the emission rate limiter contract
interface IEmissionRateLimiter {
    function emergencyRateChange(uint256 newRate, string calldata reason) external;
    function getAbsoluteMaxRate() external view returns (uint256);
    function getAbsoluteMinRate() external view returns (uint256);
}

/// @title Emission Security Manager interface
/// @notice interface for the emission security manager contract
interface IEmissionSecurityManager {
    function registerSecurityAlert(string calldata description, uint8 severity, bool requiresAction) external returns (uint256);
    function resolveSecurityAlert(uint256 alertId) external;
    function getSecurityAlertCount() external view returns (uint256);
    function getActiveSecurityAlertCount() external view returns (uint256);
    function getSecurityThreshold() external view returns (uint256);
}

/// @title Emission Security Manager
/// @notice Manages security alerts and coordinates emergency responses for the emission system
contract EmissionSecurityManager {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event SecurityAlertRegistered(uint256 indexed alertId, address indexed reporter, string description, uint8 severity, bool requiresAction);
    event SecurityAlertResolved(uint256 indexed alertId, address indexed resolver);
    event SecurityThresholdUpdated(uint256 oldThreshold, uint256 newThreshold);
    event SecurityActionExecuted(uint256 indexed alertId, address indexed executor, string actionType);
    event SecurityAuthorityAdded(address indexed authority);
    event SecurityAuthorityRemoved(address indexed authority);
    event EmergencyContractUpdated(string contractType, address indexed oldContract, address indexed newContract);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error ESM_OnlyAdmin();
    error ESM_OnlySecurityAuthority();
    error ESM_ZeroAddress();
    error ESM_InvalidParameter();
    error ESM_AlertNotFound();
    error ESM_AlertAlreadyResolved();
    error ESM_AlreadyAuthorized();
    error ESM_NotAuthorized();
    error ESM_ThresholdExceeded();
    error ESM_EmergencyAlreadyActive();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct SecurityAlert {
        uint256 id;
        address reporter;
        uint256 timestamp;
        string description;
        uint8 severity; // 1-5, with 5 being most severe
        bool requiresAction;
        bool resolved;
        uint256 resolutionTimestamp;
        address resolver;
    }

    struct SecurityAction {
        uint256 alertId;
        address executor;
        uint256 timestamp;
        string actionType;
        string details;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public emissionManager;
    address public emergencyEmissionStopper;
    address public emissionRateLimiter;
    
    // Security authorities
    mapping(address => bool) public securityAuthorities;
    address[] public authorityList;
    
    // Security threshold
    uint256 public securityThreshold = 3; // Default threshold for automatic action
    
    // Security alerts
    mapping(uint256 => SecurityAlert) public securityAlerts;
    uint256 public alertCounter;
    uint256 public activeAlertCount;
    
    // Security actions
    mapping(uint256 => SecurityAction[]) public alertActions;
    uint256 public totalActionCount;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert ESM_OnlyAdmin();
        _;
    }

    modifier onlySecurityAuthority() {
        if (!securityAuthorities[msg.sender] && msg.sender != admin) revert ESM_OnlySecurityAuthority();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(
        address admin_,
        address emissionManager_,
        address emergencyEmissionStopper_,
        address emissionRateLimiter_
    ) {
        if (admin_ == address(0) || emissionManager_ == address(0) ||
            emergencyEmissionStopper_ == address(0) || emissionRateLimiter_ == address(0)) {
            revert ESM_ZeroAddress();
        }
        
        admin = admin_;
        emissionManager = emissionManager_;
        emergencyEmissionStopper = emergencyEmissionStopper_;
        emissionRateLimiter = emissionRateLimiter_;
        
        // Add admin as security authority
        securityAuthorities[admin_] = true;
        authorityList.push(admin_);
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function addSecurityAuthority(address authority_) external onlyAdmin {
        if (authority_ == address(0)) revert ESM_ZeroAddress();
        if (securityAuthorities[authority_]) revert ESM_AlreadyAuthorized();
        
        securityAuthorities[authority_] = true;
        authorityList.push(authority_);
        
        emit SecurityAuthorityAdded(authority_);
    }

    function removeSecurityAuthority(address authority_) external onlyAdmin {
        if (authority_ == admin) revert ESM_InvalidParameter(); // Cannot remove admin
        if (!securityAuthorities[authority_]) revert ESM_NotAuthorized();
        
        securityAuthorities[authority_] = false;
        
        // Remove from authority list
        for (uint256 i = 0; i < authorityList.length; i++) {
            if (authorityList[i] == authority_) {
                authorityList[i] = authorityList[authorityList.length - 1];
                authorityList.pop();
                break;
            }
        }
        
        emit SecurityAuthorityRemoved(authority_);
    }

    function setSecurityThreshold(uint256 threshold_) external onlyAdmin {
        if (threshold_ == 0 || threshold_ > 5) revert ESM_InvalidParameter();
        
        uint256 oldThreshold = securityThreshold;
        securityThreshold = threshold_;
        
        emit SecurityThresholdUpdated(oldThreshold, threshold_);
    }

    function setEmergencyEmissionStopper(address stopper_) external onlyAdmin {
        if (stopper_ == address(0)) revert ESM_ZeroAddress();
        
        address oldStopper = emergencyEmissionStopper;
        emergencyEmissionStopper = stopper_;
        
        emit EmergencyContractUpdated("EmergencyEmissionStopper", oldStopper, stopper_);
    }

    function setEmissionRateLimiter(address limiter_) external onlyAdmin {
        if (limiter_ == address(0)) revert ESM_ZeroAddress();
        
        address oldLimiter = emissionRateLimiter;
        emissionRateLimiter = limiter_;
        
        emit EmergencyContractUpdated("EmissionRateLimiter", oldLimiter, limiter_);
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function registerSecurityAlert(
        string calldata description_,
        uint8 severity_,
        bool requiresAction_
    ) external onlySecurityAuthority returns (uint256) {
        if (severity_ == 0 || severity_ > 5) revert ESM_InvalidParameter();
        
        // Create new alert
        uint256 alertId = alertCounter++;
        
        SecurityAlert memory alert = SecurityAlert({
            id: alertId,
            reporter: msg.sender,
            timestamp: block.timestamp,
            description: description_,
            severity: severity_,
            requiresAction: requiresAction_,
            resolved: false,
            resolutionTimestamp: 0,
            resolver: address(0)
        });
        
        securityAlerts[alertId] = alert;
        activeAlertCount++;
        
        emit SecurityAlertRegistered(alertId, msg.sender, description_, severity_, requiresAction_);
        
        // Check if automatic action is needed
        if (severity_ >= securityThreshold) {
            _executeEmergencyAction(alertId, severity_);
        }
        
        return alertId;
    }

    function resolveSecurityAlert(uint256 alertId_) external onlySecurityAuthority {
        if (alertId_ >= alertCounter) revert ESM_AlertNotFound();
        if (securityAlerts[alertId_].resolved) revert ESM_AlertAlreadyResolved();
        
        securityAlerts[alertId_].resolved = true;
        securityAlerts[alertId_].resolutionTimestamp = block.timestamp;
        securityAlerts[alertId_].resolver = msg.sender;
        
        activeAlertCount--;
        
        emit SecurityAlertResolved(alertId_, msg.sender);
    }

    function executeEmergencyStop(uint256 alertId_) external onlySecurityAuthority {
        if (alertId_ >= alertCounter) revert ESM_AlertNotFound();
        if (securityAlerts[alertId_].resolved) revert ESM_AlertAlreadyResolved();
        
        // Check if emergency is already active
        if (IEmergencyEmissionStopper(emergencyEmissionStopper).isEmergencyActive()) {
            revert ESM_EmergencyAlreadyActive();
        }
        
        // Trigger emergency stop
        string memory reason = string(abi.encodePacked("Security alert #", _uint2str(alertId_), ": ", securityAlerts[alertId_].description));
        IEmergencyEmissionStopper(emergencyEmissionStopper).triggerEmergencyStop(reason);
        
        // Record action
        _recordSecurityAction(alertId_, "EmergencyStop", reason);
        
        emit SecurityActionExecuted(alertId_, msg.sender, "EmergencyStop");
    }

    function executeRateReduction(uint256 alertId_, uint256 reductionPercentage_) external onlySecurityAuthority {
        if (alertId_ >= alertCounter) revert ESM_AlertNotFound();
        if (securityAlerts[alertId_].resolved) revert ESM_AlertAlreadyResolved();
        if (reductionPercentage_ == 0 || reductionPercentage_ > 90) revert ESM_InvalidParameter();
        
        // Get current emission rate
        uint256 currentRate = IEmissionManager(emissionManager).getEmissionRate();
        
        // Calculate new rate
        uint256 newRate = currentRate * (100 - reductionPercentage_) / 100;
        
        // Ensure new rate is above minimum
        uint256 minRate = IEmissionRateLimiter(emissionRateLimiter).getAbsoluteMinRate();
        if (newRate < minRate) {
            newRate = minRate;
        }
        
        // Execute emergency rate change
        string memory reason = string(abi.encodePacked("Security alert #", _uint2str(alertId_), ": Rate reduced by ", _uint2str(reductionPercentage_), "%"));
        IEmissionRateLimiter(emissionRateLimiter).emergencyRateChange(newRate, reason);
        
        // Record action
        _recordSecurityAction(alertId_, "RateReduction", reason);
        
        emit SecurityActionExecuted(alertId_, msg.sender, "RateReduction");
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getSecurityAlertCount() external view returns (uint256) {
        return alertCounter;
    }

    function getActiveSecurityAlertCount() external view returns (uint256) {
        return activeAlertCount;
    }

    function getSecurityThreshold() external view returns (uint256) {
        return securityThreshold;
    }

    function getSecurityAuthoritiesCount() external view returns (uint256) {
        return authorityList.length;
    }

    function isSecurityAuthority(address account_) external view returns (bool) {
        return securityAuthorities[account_];
    }

    function getSecurityAlertDetails(uint256 alertId_) external view returns (
        address reporter,
        uint256 timestamp,
        string memory description,
        uint8 severity,
        bool requiresAction,
        bool resolved,
        uint256 resolutionTimestamp,
        address resolver
    ) {
        if (alertId_ >= alertCounter) revert ESM_AlertNotFound();
        
        SecurityAlert memory alert = securityAlerts[alertId_];
        return (
            alert.reporter,
            alert.timestamp,
            alert.description,
            alert.severity,
            alert.requiresAction,
            alert.resolved,
            alert.resolutionTimestamp,
            alert.resolver
        );
    }

    function getAlertActionCount(uint256 alertId_) external view returns (uint256) {
        if (alertId_ >= alertCounter) revert ESM_AlertNotFound();
        
        return alertActions[alertId_].length;
    }

    function getAlertActionDetails(uint256 alertId_, uint256 actionIndex_) external view returns (
        address executor,
        uint256 timestamp,
        string memory actionType,
        string memory details
    ) {
        if (alertId_ >= alertCounter) revert ESM_AlertNotFound();
        if (actionIndex_ >= alertActions[alertId_].length) revert ESM_InvalidParameter();
        
        SecurityAction memory action = alertActions[alertId_][actionIndex_];
        return (
            action.executor,
            action.timestamp,
            action.actionType,
            action.details
        );
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function _executeEmergencyAction(uint256 alertId_, uint8 severity_) internal {
        // For severity 5 (highest), trigger emergency stop
        if (severity_ == 5) {
            // Check if emergency is already active
            if (!IEmergencyEmissionStopper(emergencyEmissionStopper).isEmergencyActive()) {
                // Trigger emergency stop
                string memory reason = string(abi.encodePacked("Automatic response to severity 5 alert #", _uint2str(alertId_)));
                IEmergencyEmissionStopper(emergencyEmissionStopper).triggerEmergencyStop(reason);
                
                // Record action
                _recordSecurityAction(alertId_, "AutomaticEmergencyStop", reason);
                
                emit SecurityActionExecuted(alertId_, address(this), "AutomaticEmergencyStop");
            }
        }
        // For severity 4, reduce emission rate by 50%
        else if (severity_ == 4) {
            // Get current emission rate
            uint256 currentRate = IEmissionManager(emissionManager).getEmissionRate();
            
            // Calculate new rate (50% reduction)
            uint256 newRate = currentRate / 2;
            
            // Ensure new rate is above minimum
            uint256 minRate = IEmissionRateLimiter(emissionRateLimiter).getAbsoluteMinRate();
            if (newRate < minRate) {
                newRate = minRate;
            }
            
            // Execute emergency rate change
            string memory reason = string(abi.encodePacked("Automatic 50% rate reduction for severity 4 alert #", _uint2str(alertId_)));
            IEmissionRateLimiter(emissionRateLimiter).emergencyRateChange(newRate, reason);
            
            // Record action
            _recordSecurityAction(alertId_, "AutomaticRateReduction", reason);
            
            emit SecurityActionExecuted(alertId_, address(this), "AutomaticRateReduction");
        }
        // For severity 3, reduce emission rate by 25%
        else if (severity_ == 3) {
            // Get current emission rate
            uint256 currentRate = IEmissionManager(emissionManager).getEmissionRate();
            
            // Calculate new rate (25% reduction)
            uint256 newRate = currentRate * 75 / 100;
            
            // Ensure new rate is above minimum
            uint256 minRate = IEmissionRateLimiter(emissionRateLimiter).getAbsoluteMinRate();
            if (newRate < minRate) {
                newRate = minRate;
            }
            
            // Execute emergency rate change
            string memory reason = string(abi.encodePacked("Automatic 25% rate reduction for severity 3 alert #", _uint2str(alertId_)));
            IEmissionRateLimiter(emissionRateLimiter).emergencyRateChange(newRate, reason);
            
            // Record action
            _recordSecurityAction(alertId_, "AutomaticRateReduction", reason);
            
            emit SecurityActionExecuted(alertId_, address(this), "AutomaticRateReduction");
        }
    }

    function _recordSecurityAction(uint256 alertId_, string memory actionType_, string memory details_) internal {
        SecurityAction memory action = SecurityAction({
            alertId: alertId_,
            executor: msg.sender,
            timestamp: block.timestamp,
            actionType: actionType_,
            details: details_
        });
        
        alertActions[alertId_].push(action);
        totalActionCount++;
    }

    function _uint2str(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        
        uint256 temp = value;
        uint256 digits;
        
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        
        bytes memory buffer = new bytes(digits);
        
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        
        return string(buffer);
    }
}