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

/// @title Historical Emission Tracker interface
/// @notice interface for the historical emission tracker contract
interface IHistoricalEmissionTracker {
    function getEmissionHistory(address token) external view returns (uint256[] memory timestamps, uint256[] memory amounts);
    function getDailyEmissionAverage(address token, uint256 days_) external view returns (uint256);
    function getWeeklyEmissionAverage(address token, uint256 weeks_) external view returns (uint256);
    function getMonthlyEmissionAverage(address token, uint256 months_) external view returns (uint256);
}

/// @title Emission Audit Log interface
/// @notice interface for the emission audit log contract
interface IEmissionAuditLog {
    function logEmissionEvent(address token, uint256 amount, string memory eventType, address initiator) external returns (uint256 eventId);
    function logCustomEvent(address token, string memory eventType, string memory details, address initiator) external returns (uint256 eventId);
}

/// @title Emission Compliance Checker interface
/// @notice interface for the emission compliance checker contract
interface IEmissionComplianceChecker {
    function checkCompliance(address token) external returns (bool compliant, string memory complianceDetails);
    function getComplianceStatus(address token) external view returns (bool compliant, uint256 lastChecked, string memory complianceDetails);
    function getComplianceHistory(address token) external view returns (uint256[] memory timestamps, bool[] memory statuses);
    function getComplianceRules(address token) external view returns (string[] memory ruleNames, bool[] memory enabled);
    function getGlobalComplianceStatus() external view returns (uint256 compliantTokens, uint256 totalTokens);
}

/// @title Emission Compliance Checker
/// @notice Checks emission compliance against predefined rules
contract EmissionComplianceChecker {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event ComplianceChecked(address indexed token, bool compliant, string complianceDetails);
    event ComplianceRuleAdded(string indexed ruleName, string description);
    event ComplianceRuleRemoved(string indexed ruleName);
    event ComplianceRuleToggled(address indexed token, string indexed ruleName, bool enabled);
    event EmissionManagerUpdated(address indexed oldManager, address indexed newManager);
    event HistoricalTrackerUpdated(address indexed oldTracker, address indexed newTracker);
    event AuditLogUpdated(address indexed oldLog, address indexed newLog);
    event ComplianceThresholdUpdated(string indexed ruleName, uint256 oldThreshold, uint256 newThreshold);
    event ComplianceNotifierAdded(address indexed notifier);
    event ComplianceNotifierRemoved(address indexed notifier);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error ECC_OnlyAdmin();
    error ECC_OnlyNotifier();
    error ECC_ZeroAddress();
    error ECC_TokenNotSupported();
    error ECC_RuleAlreadyExists();
    error ECC_RuleNotFound();
    error ECC_InvalidParameter();
    error ECC_NotifierAlreadyAdded();
    error ECC_NotifierNotFound();
    error ECC_DependencyNotSet();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct ComplianceRule {
        string name;
        string description;
        bool global; // If true, applies to all tokens
        uint256 threshold; // Rule-specific threshold value
        bool exists;
    }

    struct TokenComplianceStatus {
        bool compliant;
        uint256 lastChecked;
        string complianceDetails;
        mapping(string => bool) ruleEnabled; // ruleName => enabled
        uint256[] checkTimestamps;
        bool[] checkResults;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public emissionManager;
    address public historicalTracker;
    address public auditLog;
    
    // Compliance rules
    mapping(string => ComplianceRule) public complianceRules;
    string[] public ruleNames;
    
    // Token compliance status
    mapping(address => TokenComplianceStatus) public tokenComplianceStatus;
    
    // Compliance notifiers
    mapping(address => bool) public authorizedNotifiers;
    address[] public notifiers;
    
    // Global thresholds
    uint256 public maxDailyEmissionRate = 1000000 * 10**18; // 1M tokens per day
    uint256 public maxWeeklyEmissionGrowth = 2000; // 20% max weekly growth
    uint256 public maxMonthlyEmissionTotal = 30000000 * 10**18; // 30M tokens per month

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert ECC_OnlyAdmin();
        _;
    }

    modifier onlyNotifier() {
        if (msg.sender != admin && !authorizedNotifiers[msg.sender]) revert ECC_OnlyNotifier();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address emissionManager_, address historicalTracker_, address auditLog_) {
        if (admin_ == address(0)) revert ECC_ZeroAddress();
        
        admin = admin_;
        
        if (emissionManager_ != address(0)) emissionManager = emissionManager_;
        if (historicalTracker_ != address(0)) historicalTracker = historicalTracker_;
        if (auditLog_ != address(0)) auditLog = auditLog_;
        
        // Add default compliance rules
        _addComplianceRule(
            "daily_rate_limit",
            "Daily emission rate must not exceed the maximum allowed",
            true,
            maxDailyEmissionRate
        );
        
        _addComplianceRule(
            "weekly_growth_limit",
            "Weekly emission growth must not exceed the maximum percentage",
            true,
            maxWeeklyEmissionGrowth
        );
        
        _addComplianceRule(
            "monthly_total_limit",
            "Monthly emission total must not exceed the maximum allowed",
            true,
            maxMonthlyEmissionTotal
        );
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function setEmissionManager(address emissionManager_) external onlyAdmin {
        if (emissionManager_ == address(0)) revert ECC_ZeroAddress();
        
        address oldManager = emissionManager;
        emissionManager = emissionManager_;
        
        emit EmissionManagerUpdated(oldManager, emissionManager_);
    }

    function setHistoricalTracker(address historicalTracker_) external onlyAdmin {
        if (historicalTracker_ == address(0)) revert ECC_ZeroAddress();
        
        address oldTracker = historicalTracker;
        historicalTracker = historicalTracker_;
        
        emit HistoricalTrackerUpdated(oldTracker, historicalTracker_);
    }

    function setAuditLog(address auditLog_) external onlyAdmin {
        if (auditLog_ == address(0)) revert ECC_ZeroAddress();
        
        address oldLog = auditLog;
        auditLog = auditLog_;
        
        emit AuditLogUpdated(oldLog, auditLog_);
    }

    function addComplianceRule(string memory name, string memory description, bool global, uint256 threshold) external onlyAdmin {
        _addComplianceRule(name, description, global, threshold);
    }

    function removeComplianceRule(string memory name) external onlyAdmin {
        if (!complianceRules[name].exists) revert ECC_RuleNotFound();
        
        // Remove from ruleNames array
        for (uint256 i = 0; i < ruleNames.length; i++) {
            if (keccak256(bytes(ruleNames[i])) == keccak256(bytes(name))) {
                ruleNames[i] = ruleNames[ruleNames.length - 1];
                ruleNames.pop();
                break;
            }
        }
        
        delete complianceRules[name];
        
        emit ComplianceRuleRemoved(name);
    }

    function setRuleThreshold(string memory name, uint256 threshold) external onlyAdmin {
        if (!complianceRules[name].exists) revert ECC_RuleNotFound();
        
        uint256 oldThreshold = complianceRules[name].threshold;
        complianceRules[name].threshold = threshold;
        
        emit ComplianceThresholdUpdated(name, oldThreshold, threshold);
    }

    function toggleRuleForToken(address token, string memory ruleName, bool enabled) external onlyAdmin {
        if (emissionManager == address(0)) revert ECC_DependencyNotSet();
        if (!complianceRules[ruleName].exists) revert ECC_RuleNotFound();
        
        // Check if token is supported by emission manager
        address[] memory supportedTokens = IEmissionManager(emissionManager).getSupportedTokens();
        bool tokenFound = false;
        
        for (uint256 i = 0; i < supportedTokens.length; i++) {
            if (supportedTokens[i] == token) {
                tokenFound = true;
                break;
            }
        }
        
        if (!tokenFound) revert ECC_TokenNotSupported();
        
        tokenComplianceStatus[token].ruleEnabled[ruleName] = enabled;
        
        emit ComplianceRuleToggled(token, ruleName, enabled);
    }

    function setGlobalThresholds(
        uint256 dailyRate,
        uint256 weeklyGrowth,
        uint256 monthlyTotal
    ) external onlyAdmin {
        if (dailyRate > 0) {
            uint256 oldThreshold = maxDailyEmissionRate;
            maxDailyEmissionRate = dailyRate;
            complianceRules["daily_rate_limit"].threshold = dailyRate;
            emit ComplianceThresholdUpdated("daily_rate_limit", oldThreshold, dailyRate);
        }
        
        if (weeklyGrowth > 0) {
            uint256 oldThreshold = maxWeeklyEmissionGrowth;
            maxWeeklyEmissionGrowth = weeklyGrowth;
            complianceRules["weekly_growth_limit"].threshold = weeklyGrowth;
            emit ComplianceThresholdUpdated("weekly_growth_limit", oldThreshold, weeklyGrowth);
        }
        
        if (monthlyTotal > 0) {
            uint256 oldThreshold = maxMonthlyEmissionTotal;
            maxMonthlyEmissionTotal = monthlyTotal;
            complianceRules["monthly_total_limit"].threshold = monthlyTotal;
            emit ComplianceThresholdUpdated("monthly_total_limit", oldThreshold, monthlyTotal);
        }
    }

    function addComplianceNotifier(address notifier) external onlyAdmin {
        if (notifier == address(0)) revert ECC_ZeroAddress();
        if (authorizedNotifiers[notifier]) revert ECC_NotifierAlreadyAdded();
        
        authorizedNotifiers[notifier] = true;
        notifiers.push(notifier);
        
        emit ComplianceNotifierAdded(notifier);
    }

    function removeComplianceNotifier(address notifier) external onlyAdmin {
        if (!authorizedNotifiers[notifier]) revert ECC_NotifierNotFound();
        
        authorizedNotifiers[notifier] = false;
        
        // Remove from notifiers array
        for (uint256 i = 0; i < notifiers.length; i++) {
            if (notifiers[i] == notifier) {
                notifiers[i] = notifiers[notifiers.length - 1];
                notifiers.pop();
                break;
            }
        }
        
        emit ComplianceNotifierRemoved(notifier);
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function checkCompliance(address token) external returns (bool compliant, string memory complianceDetails) {
        if (emissionManager == address(0) || historicalTracker == address(0)) revert ECC_DependencyNotSet();
        
        // Check if token is supported by emission manager
        address[] memory supportedTokens = IEmissionManager(emissionManager).getSupportedTokens();
        bool tokenFound = false;
        
        for (uint256 i = 0; i < supportedTokens.length; i++) {
            if (supportedTokens[i] == token) {
                tokenFound = true;
                break;
            }
        }
        
        if (!tokenFound) revert ECC_TokenNotSupported();
        
        // Check each compliance rule
        bool isCompliant = true;
        string memory complianceDetails = "";
        
        for (uint256 i = 0; i < ruleNames.length; i++) {
            string memory ruleName = ruleNames[i];
            ComplianceRule memory rule = complianceRules[ruleName];
            
            // Skip if rule is not enabled for this token
            if (!rule.global && !tokenComplianceStatus[token].ruleEnabled[ruleName]) {
                continue;
            }
            
            bool ruleCompliant = true;
            string memory ruleDetails = "";
            
            // Check rule compliance
            if (keccak256(bytes(ruleName)) == keccak256(bytes("daily_rate_limit"))) {
                uint256 dailyRate = IHistoricalEmissionTracker(historicalTracker).getDailyEmissionAverage(token, 1);
                ruleCompliant = dailyRate <= rule.threshold;
                if (!ruleCompliant) {
                    ruleDetails = string(abi.encodePacked(
                        "Daily rate (", _uintToString(dailyRate),
                        ") exceeds limit (", _uintToString(rule.threshold), ")"
                    ));
                }
            }
            else if (keccak256(bytes(ruleName)) == keccak256(bytes("weekly_growth_limit"))) {
                uint256 currentWeekly = IHistoricalEmissionTracker(historicalTracker).getWeeklyEmissionAverage(token, 1);
                uint256 previousWeekly = IHistoricalEmissionTracker(historicalTracker).getWeeklyEmissionAverage(token, 2) / 2; // Average of previous week
                
                if (previousWeekly > 0) {
                    uint256 growthPercentage = (currentWeekly * 10000) / previousWeekly - 10000; // In basis points
                    ruleCompliant = growthPercentage <= rule.threshold;
                    if (!ruleCompliant) {
                        ruleDetails = string(abi.encodePacked(
                            "Weekly growth (", _uintToString(growthPercentage),
                            "bp) exceeds limit (", _uintToString(rule.threshold), "bp)"
                        ));
                    }
                }
            }
            else if (keccak256(bytes(ruleName)) == keccak256(bytes("monthly_total_limit"))) {
                uint256 monthlyTotal = IHistoricalEmissionTracker(historicalTracker).getMonthlyEmissionAverage(token, 1) * 30; // Approximate monthly total
                ruleCompliant = monthlyTotal <= rule.threshold;
                if (!ruleCompliant) {
                    ruleDetails = string(abi.encodePacked(
                        "Monthly total (", _uintToString(monthlyTotal),
                        ") exceeds limit (", _uintToString(rule.threshold), ")"
                    ));
                }
            }
            // Add more rule checks here
            
            // Update overall compliance
            if (!ruleCompliant) {
                isCompliant = false;
                complianceDetails = string(abi.encodePacked(
                        complianceDetails,
                        bytes(complianceDetails).length > 0 ? "; " : "",
                        rule.name, ": ", ruleDetails
                    ));
            }
        }
        
        if (isCompliant) {
            complianceDetails = "All compliance rules passed";
        }
        
        // Update token compliance status
        tokenComplianceStatus[token].compliant = isCompliant;
        tokenComplianceStatus[token].lastChecked = block.timestamp;
        tokenComplianceStatus[token].complianceDetails = complianceDetails;
        tokenComplianceStatus[token].checkTimestamps.push(block.timestamp);
        tokenComplianceStatus[token].checkResults.push(isCompliant);
        
        // Log compliance check to audit log
        if (auditLog != address(0)) {
            IEmissionAuditLog(auditLog).logCustomEvent(
                token,
                "compliance_check",
                complianceDetails,
                msg.sender
            );
        }
        
        emit ComplianceChecked(token, isCompliant, complianceDetails);
        
        return (isCompliant, complianceDetails);
    }

    function notifyComplianceViolation(address token, string memory details) external onlyNotifier {
        if (auditLog == address(0)) revert ECC_DependencyNotSet();
        
        // Log violation to audit log
        IEmissionAuditLog(auditLog).logCustomEvent(
            token,
            "compliance_violation",
            details,
            msg.sender
        );
        
        // Update token compliance status
        tokenComplianceStatus[token].compliant = false;
        tokenComplianceStatus[token].lastChecked = block.timestamp;
        tokenComplianceStatus[token].complianceDetails = details;
        tokenComplianceStatus[token].checkTimestamps.push(block.timestamp);
        tokenComplianceStatus[token].checkResults.push(false);
        
        emit ComplianceChecked(token, false, details);
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getComplianceStatus(address token) external view returns (bool compliant, uint256 lastChecked, string memory complianceDetails) {
        TokenComplianceStatus storage status = tokenComplianceStatus[token];
        
        return (status.compliant, status.lastChecked, status.complianceDetails);
    }

    function getComplianceHistory(address token) external view returns (uint256[] memory timestamps, bool[] memory statuses) {
        TokenComplianceStatus storage status = tokenComplianceStatus[token];
        
        return (status.checkTimestamps, status.checkResults);
    }

    function getComplianceRules(address token) external view returns (string[] memory ruleNames_, bool[] memory enabled) {
        ruleNames_ = new string[](ruleNames.length);
        enabled = new bool[](ruleNames.length);
        
        for (uint256 i = 0; i < ruleNames.length; i++) {
            ruleNames_[i] = ruleNames[i];
            ComplianceRule memory rule = complianceRules[ruleNames[i]];
            
            // Rule is enabled if it's global or specifically enabled for this token
            enabled[i] = rule.global || tokenComplianceStatus[token].ruleEnabled[ruleNames[i]];
        }
        
        return (ruleNames_, enabled);
    }

    function getGlobalComplianceStatus() external view returns (uint256 compliantTokens, uint256 totalTokens) {
        if (emissionManager == address(0)) revert ECC_DependencyNotSet();
        
        address[] memory supportedTokens = IEmissionManager(emissionManager).getSupportedTokens();
        totalTokens = supportedTokens.length;
        
        for (uint256 i = 0; i < supportedTokens.length; i++) {
            if (tokenComplianceStatus[supportedTokens[i]].compliant) {
                compliantTokens++;
            }
        }
        
        return (compliantTokens, totalTokens);
    }

    function getAllRules() external view returns (string[] memory names, string[] memory descriptions, bool[] memory globals, uint256[] memory thresholds) {
        names = new string[](ruleNames.length);
        descriptions = new string[](ruleNames.length);
        globals = new bool[](ruleNames.length);
        thresholds = new uint256[](ruleNames.length);
        
        for (uint256 i = 0; i < ruleNames.length; i++) {
            ComplianceRule memory rule = complianceRules[ruleNames[i]];
            names[i] = rule.name;
            descriptions[i] = rule.description;
            globals[i] = rule.global;
            thresholds[i] = rule.threshold;
        }
        
        return (names, descriptions, globals, thresholds);
    }

    function getComplianceNotifiers() external view returns (address[] memory) {
        return notifiers;
    }

    function isComplianceNotifier(address account) external view returns (bool) {
        return authorizedNotifiers[account];
    }

    function getGlobalThresholds() external view returns (uint256 dailyRate, uint256 weeklyGrowth, uint256 monthlyTotal) {
        return (maxDailyEmissionRate, maxWeeklyEmissionGrowth, maxMonthlyEmissionTotal);
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function _addComplianceRule(string memory name, string memory description, bool global, uint256 threshold) internal {
        if (bytes(name).length == 0) revert ECC_InvalidParameter();
        if (complianceRules[name].exists) revert ECC_RuleAlreadyExists();
        
        complianceRules[name] = ComplianceRule({
            name: name,
            description: description,
            global: global,
            threshold: threshold,
            exists: true
        });
        
        ruleNames.push(name);
        
        emit ComplianceRuleAdded(name, description);
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