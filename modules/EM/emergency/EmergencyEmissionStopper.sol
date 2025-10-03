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
}

/// @title Market Sentiment Analyzer interface
/// @notice interface for the market sentiment analyzer contract
interface IMarketSentimentAnalyzer {
    function getCurrentMarketSentiment() external view returns (int256);
    function getMarketVolatility() external view returns (uint256);
}

/// @title Emergency Emission Stopper interface
/// @notice interface for the emergency emission stopper contract
interface IEmergencyEmissionStopper {
    function triggerEmergencyStop() external;
    function cancelEmergencyStop() external;
    function isEmergencyActive() external view returns (bool);
    function getLastEmergencyTimestamp() external view returns (uint256);
    function getEmergencyCount() external view returns (uint256);
}

/// @title Emergency Emission Stopper
/// @notice Provides emergency controls to halt token emissions in crisis situations
contract EmergencyEmissionStopper {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event EmergencyStopTriggered(address indexed triggeredBy, uint256 timestamp, string reason);
    event EmergencyStopCancelled(address indexed cancelledBy, uint256 timestamp);
    event EmergencyThresholdUpdated(int256 sentimentThreshold, uint256 volatilityThreshold);
    event EmergencyAuthorityAdded(address indexed authority);
    event EmergencyAuthorityRemoved(address indexed authority);
    event AutomaticMonitoringToggled(bool enabled);
    event MarketSentimentAnalyzerUpdated(address indexed oldAnalyzer, address indexed newAnalyzer);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error EES_OnlyAdmin();
    error EES_OnlyEmergencyAuthority();
    error EES_ZeroAddress();
    error EES_EmergencyAlreadyActive();
    error EES_NoEmergencyActive();
    error EES_InvalidParameter();
    error EES_AlreadyAuthorized();
    error EES_NotAuthorized();
    error EES_EmergencyCooldownActive();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct EmergencyEvent {
        address triggeredBy;
        uint256 timestamp;
        string reason;
        uint256 marketSentiment;
        uint256 marketVolatility;
        uint256 emissionRate;
        uint256 totalEmitted;
        uint256 resolutionTimestamp;
        bool resolved;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public emissionManager;
    address public marketSentimentAnalyzer;
    
    // Emergency authorities
    mapping(address => bool) public emergencyAuthorities;
    address[] public authorityList;
    
    // Emergency state
    bool public emergencyActive;
    uint256 public lastEmergencyTimestamp;
    uint256 public emergencyCooldown = 24 hours;
    
    // Automatic monitoring
    bool public automaticMonitoringEnabled;
    int256 public sentimentThreshold = -70; // Threshold for automatic emergency (-100 to 100)
    uint256 public volatilityThreshold = 80; // Threshold for automatic emergency (0 to 100)
    uint256 public monitoringFrequency = 1 hours;
    uint256 public lastMonitoringTimestamp;
    
    // Emergency history
    EmergencyEvent[] public emergencyHistory;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert EES_OnlyAdmin();
        _;
    }

    modifier onlyEmergencyAuthority() {
        if (!emergencyAuthorities[msg.sender] && msg.sender != admin) revert EES_OnlyEmergencyAuthority();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address emissionManager_, address marketSentimentAnalyzer_) {
        if (admin_ == address(0) || emissionManager_ == address(0) || marketSentimentAnalyzer_ == address(0)) {
            revert EES_ZeroAddress();
        }
        
        admin = admin_;
        emissionManager = emissionManager_;
        marketSentimentAnalyzer = marketSentimentAnalyzer_;
        
        // Add admin as emergency authority
        emergencyAuthorities[admin_] = true;
        authorityList.push(admin_);
        
        lastMonitoringTimestamp = block.timestamp;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function addEmergencyAuthority(address authority_) external onlyAdmin {
        if (authority_ == address(0)) revert EES_ZeroAddress();
        if (emergencyAuthorities[authority_]) revert EES_AlreadyAuthorized();
        
        emergencyAuthorities[authority_] = true;
        authorityList.push(authority_);
        
        emit EmergencyAuthorityAdded(authority_);
    }

    function removeEmergencyAuthority(address authority_) external onlyAdmin {
        if (authority_ == admin) revert EES_InvalidParameter(); // Cannot remove admin
        if (!emergencyAuthorities[authority_]) revert EES_NotAuthorized();
        
        emergencyAuthorities[authority_] = false;
        
        // Remove from authority list
        for (uint256 i = 0; i < authorityList.length; i++) {
            if (authorityList[i] == authority_) {
                authorityList[i] = authorityList[authorityList.length - 1];
                authorityList.pop();
                break;
            }
        }
        
        emit EmergencyAuthorityRemoved(authority_);
    }

    function setEmergencyThresholds(int256 sentimentThreshold_, uint256 volatilityThreshold_) external onlyAdmin {
        if (sentimentThreshold_ > 0 || sentimentThreshold_ < -100) revert EES_InvalidParameter();
        if (volatilityThreshold_ < 50 || volatilityThreshold_ > 100) revert EES_InvalidParameter();
        
        sentimentThreshold = sentimentThreshold_;
        volatilityThreshold = volatilityThreshold_;
        
        emit EmergencyThresholdUpdated(sentimentThreshold_, volatilityThreshold_);
    }

    function setAutomaticMonitoring(bool enabled_) external onlyAdmin {
        automaticMonitoringEnabled = enabled_;
        
        emit AutomaticMonitoringToggled(enabled_);
    }

    function setMarketSentimentAnalyzer(address analyzer_) external onlyAdmin {
        if (analyzer_ == address(0)) revert EES_ZeroAddress();
        
        address oldAnalyzer = marketSentimentAnalyzer;
        marketSentimentAnalyzer = analyzer_;
        
        emit MarketSentimentAnalyzerUpdated(oldAnalyzer, analyzer_);
    }

    function setEmergencyCooldown(uint256 cooldown_) external onlyAdmin {
        if (cooldown_ < 1 hours || cooldown_ > 7 days) revert EES_InvalidParameter();
        
        emergencyCooldown = cooldown_;
    }

    function setMonitoringFrequency(uint256 frequency_) external onlyAdmin {
        if (frequency_ < 15 minutes || frequency_ > 24 hours) revert EES_InvalidParameter();
        
        monitoringFrequency = frequency_;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function triggerEmergencyStop(string calldata reason_) external onlyEmergencyAuthority {
        if (emergencyActive) revert EES_EmergencyAlreadyActive();
        if (block.timestamp < lastEmergencyTimestamp + emergencyCooldown) revert EES_EmergencyCooldownActive();
        
        // Pause emissions
        IEmissionManager(emissionManager).pauseEmissions();
        
        // Update state
        emergencyActive = true;
        lastEmergencyTimestamp = block.timestamp;
        
        // Record emergency event
        _recordEmergencyEvent(msg.sender, reason_);
        
        emit EmergencyStopTriggered(msg.sender, block.timestamp, reason_);
    }

    function cancelEmergencyStop() external onlyEmergencyAuthority {
        if (!emergencyActive) revert EES_NoEmergencyActive();
        
        // Resume emissions
        IEmissionManager(emissionManager).resumeEmissions();
        
        // Update state
        emergencyActive = false;
        
        // Update emergency history
        uint256 lastIndex = emergencyHistory.length - 1;
        emergencyHistory[lastIndex].resolved = true;
        emergencyHistory[lastIndex].resolutionTimestamp = block.timestamp;
        
        emit EmergencyStopCancelled(msg.sender, block.timestamp);
    }

    function checkMarketConditions() external {
        if (block.timestamp < lastMonitoringTimestamp + monitoringFrequency) return;
        
        lastMonitoringTimestamp = block.timestamp;
        
        if (!automaticMonitoringEnabled) return;
        if (emergencyActive) return;
        if (block.timestamp < lastEmergencyTimestamp + emergencyCooldown) return;
        
        // Check market conditions
        int256 marketSentiment = IMarketSentimentAnalyzer(marketSentimentAnalyzer).getCurrentMarketSentiment();
        uint256 marketVolatility = IMarketSentimentAnalyzer(marketSentimentAnalyzer).getMarketVolatility();
        
        // Trigger emergency if conditions meet thresholds
        if (marketSentiment <= sentimentThreshold || marketVolatility >= volatilityThreshold) {
            // Pause emissions
            IEmissionManager(emissionManager).pauseEmissions();
            
            // Update state
            emergencyActive = true;
            lastEmergencyTimestamp = block.timestamp;
            
            // Record emergency event with automatic reason
            string memory reason = "Automatic trigger: Market conditions exceeded thresholds";
            _recordEmergencyEvent(address(this), reason);
            
            emit EmergencyStopTriggered(address(this), block.timestamp, reason);
        }
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function isEmergencyActive() external view returns (bool) {
        return emergencyActive;
    }

    function getLastEmergencyTimestamp() external view returns (uint256) {
        return lastEmergencyTimestamp;
    }

    function getEmergencyCount() external view returns (uint256) {
        return emergencyHistory.length;
    }

    function getEmergencyAuthoritiesCount() external view returns (uint256) {
        return authorityList.length;
    }

    function isEmergencyAuthority(address account_) external view returns (bool) {
        return emergencyAuthorities[account_];
    }

    function getEmergencyDetails(uint256 index_) external view returns (
        address triggeredBy,
        uint256 timestamp,
        string memory reason,
        bool resolved,
        uint256 resolutionTimestamp
    ) {
        if (index_ >= emergencyHistory.length) revert EES_InvalidParameter();
        
        EmergencyEvent memory event_ = emergencyHistory[index_];
        return (
            event_.triggeredBy,
            event_.timestamp,
            event_.reason,
            event_.resolved,
            event_.resolutionTimestamp
        );
    }

    function getMarketConditionThresholds() external view returns (int256, uint256) {
        return (sentimentThreshold, volatilityThreshold);
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function _recordEmergencyEvent(address triggeredBy_, string memory reason_) internal {
        // Get current market conditions and emission data
        int256 marketSentiment = IMarketSentimentAnalyzer(marketSentimentAnalyzer).getCurrentMarketSentiment();
        uint256 marketVolatility = IMarketSentimentAnalyzer(marketSentimentAnalyzer).getMarketVolatility();
        uint256 emissionRate = IEmissionManager(emissionManager).getEmissionRate();
        uint256 totalEmitted = IEmissionManager(emissionManager).getTotalEmitted();
        
        // Create emergency event record
        EmergencyEvent memory event_ = EmergencyEvent({
            triggeredBy: triggeredBy_,
            timestamp: block.timestamp,
            reason: reason_,
            marketSentiment: uint256(marketSentiment < 0 ? -marketSentiment : marketSentiment),
            marketVolatility: marketVolatility,
            emissionRate: emissionRate,
            totalEmitted: totalEmitted,
            resolutionTimestamp: 0,
            resolved: false
        });
        
        emergencyHistory.push(event_);
    }
}