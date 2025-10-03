// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Emission Manager interface
/// @notice interface for the emission manager contract
interface IEmissionManager {
    function setEmissionRate(uint256 rate) external;
    function getEmissionRate() external view returns (uint256);
    function getTotalEmitted() external view returns (uint256);
    function getLastEmissionBlock() external view returns (uint256);
    function isEmissionPaused() external view returns (bool);
}

/// @title Market Sentiment Analyzer interface
/// @notice interface for the market sentiment analyzer contract
interface IMarketSentimentAnalyzer {
    function getCurrentMarketSentiment() external view returns (int256);
    function getMarketVolatility() external view returns (uint256);
}

/// @title Rate Adjustment Emergency Handler interface
/// @notice interface for the rate adjustment emergency handler contract
interface IRateAdjustmentEmergencyHandler {
    function triggerEmergencyRateAdjustment() external returns (uint256);
    function getLastAdjustmentTimestamp() external view returns (uint256);
    function getEmergencyAdjustmentCount() external view returns (uint256);
    function getAdjustmentThresholds() external view returns (int256 sentimentThreshold, uint256 volatilityThreshold);
}

/// @title Rate Adjustment Emergency Handler
/// @notice Handles emergency rate adjustments based on market conditions
contract RateAdjustmentEmergencyHandler {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event EmergencyRateAdjustmentTriggered(address indexed triggeredBy, uint256 oldRate, uint256 newRate, int256 marketSentiment, uint256 marketVolatility);
    event AdjustmentThresholdsUpdated(int256 sentimentThreshold, uint256 volatilityThreshold);
    event AdjustmentParametersUpdated(uint256 maxReductionPercentage, uint256 cooldownPeriod);
    event EmergencyAuthorityAdded(address indexed authority);
    event EmergencyAuthorityRemoved(address indexed authority);
    event MarketSentimentAnalyzerUpdated(address indexed oldAnalyzer, address indexed newAnalyzer);
    event AutomaticAdjustmentToggled(bool enabled);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error RAEH_OnlyAdmin();
    error RAEH_OnlyEmergencyAuthority();
    error RAEH_ZeroAddress();
    error RAEH_InvalidParameter();
    error RAEH_CooldownActive();
    error RAEH_EmissionsPaused();
    error RAEH_AlreadyAuthorized();
    error RAEH_NotAuthorized();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct AdjustmentEvent {
        address triggeredBy;
        uint256 timestamp;
        uint256 previousRate;
        uint256 newRate;
        int256 marketSentiment;
        uint256 marketVolatility;
        string reason;
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
    
    // Adjustment parameters
    int256 public sentimentThreshold = -50; // Threshold for automatic adjustment (-100 to 100)
    uint256 public volatilityThreshold = 70; // Threshold for automatic adjustment (0 to 100)
    uint256 public maxReductionPercentage = 30; // Maximum rate reduction percentage
    uint256 public cooldownPeriod = 12 hours; // Cooldown between adjustments
    
    // Adjustment state
    uint256 public lastAdjustmentTimestamp;
    
    // Automatic adjustment
    bool public automaticAdjustmentEnabled;
    uint256 public monitoringFrequency = 1 hours;
    uint256 public lastMonitoringTimestamp;
    
    // Adjustment history
    AdjustmentEvent[] public adjustmentHistory;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert RAEH_OnlyAdmin();
        _;
    }

    modifier onlyEmergencyAuthority() {
        if (!emergencyAuthorities[msg.sender] && msg.sender != admin) revert RAEH_OnlyEmergencyAuthority();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address emissionManager_, address marketSentimentAnalyzer_) {
        if (admin_ == address(0) || emissionManager_ == address(0) || marketSentimentAnalyzer_ == address(0)) {
            revert RAEH_ZeroAddress();
        }
        
        admin = admin_;
        emissionManager = emissionManager_;
        marketSentimentAnalyzer = marketSentimentAnalyzer_;
        
        // Add admin as emergency authority
        emergencyAuthorities[admin_] = true;
        authorityList.push(admin_);
        
        lastAdjustmentTimestamp = block.timestamp;
        lastMonitoringTimestamp = block.timestamp;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function addEmergencyAuthority(address authority_) external onlyAdmin {
        if (authority_ == address(0)) revert RAEH_ZeroAddress();
        if (emergencyAuthorities[authority_]) revert RAEH_AlreadyAuthorized();
        
        emergencyAuthorities[authority_] = true;
        authorityList.push(authority_);
        
        emit EmergencyAuthorityAdded(authority_);
    }

    function removeEmergencyAuthority(address authority_) external onlyAdmin {
        if (authority_ == admin) revert RAEH_InvalidParameter(); // Cannot remove admin
        if (!emergencyAuthorities[authority_]) revert RAEH_NotAuthorized();
        
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

    function setAdjustmentThresholds(int256 sentimentThreshold_, uint256 volatilityThreshold_) external onlyAdmin {
        if (sentimentThreshold_ > 0 || sentimentThreshold_ < -100) revert RAEH_InvalidParameter();
        if (volatilityThreshold_ < 50 || volatilityThreshold_ > 100) revert RAEH_InvalidParameter();
        
        sentimentThreshold = sentimentThreshold_;
        volatilityThreshold = volatilityThreshold_;
        
        emit AdjustmentThresholdsUpdated(sentimentThreshold_, volatilityThreshold_);
    }

    function setAdjustmentParameters(uint256 maxReductionPercentage_, uint256 cooldownPeriod_) external onlyAdmin {
        if (maxReductionPercentage_ < 10 || maxReductionPercentage_ > 50) revert RAEH_InvalidParameter();
        if (cooldownPeriod_ < 1 hours || cooldownPeriod_ > 7 days) revert RAEH_InvalidParameter();
        
        maxReductionPercentage = maxReductionPercentage_;
        cooldownPeriod = cooldownPeriod_;
        
        emit AdjustmentParametersUpdated(maxReductionPercentage_, cooldownPeriod_);
    }

    function setAutomaticAdjustment(bool enabled_) external onlyAdmin {
        automaticAdjustmentEnabled = enabled_;
        
        emit AutomaticAdjustmentToggled(enabled_);
    }

    function setMarketSentimentAnalyzer(address analyzer_) external onlyAdmin {
        if (analyzer_ == address(0)) revert RAEH_ZeroAddress();
        
        address oldAnalyzer = marketSentimentAnalyzer;
        marketSentimentAnalyzer = analyzer_;
        
        emit MarketSentimentAnalyzerUpdated(oldAnalyzer, analyzer_);
    }

    function setMonitoringFrequency(uint256 frequency_) external onlyAdmin {
        if (frequency_ < 15 minutes || frequency_ > 24 hours) revert RAEH_InvalidParameter();
        
        monitoringFrequency = frequency_;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function triggerEmergencyRateAdjustment() external onlyEmergencyAuthority returns (uint256) {
        // Check if emissions are paused
        if (IEmissionManager(emissionManager).isEmissionPaused()) revert RAEH_EmissionsPaused();
        
        // Check cooldown period
        if (block.timestamp < lastAdjustmentTimestamp + cooldownPeriod) revert RAEH_CooldownActive();
        
        // Get current market conditions
        int256 marketSentiment = IMarketSentimentAnalyzer(marketSentimentAnalyzer).getCurrentMarketSentiment();
        uint256 marketVolatility = IMarketSentimentAnalyzer(marketSentimentAnalyzer).getMarketVolatility();
        
        // Get current emission rate
        uint256 currentRate = IEmissionManager(emissionManager).getEmissionRate();
        
        // Calculate adjustment percentage based on market conditions
        uint256 adjustmentPercentage = _calculateAdjustmentPercentage(marketSentiment, marketVolatility);
        
        // Calculate new rate
        uint256 newRate = currentRate * (100 - adjustmentPercentage) / 100;
        
        // Update last adjustment timestamp
        lastAdjustmentTimestamp = block.timestamp;
        
        // Set new emission rate
        IEmissionManager(emissionManager).setEmissionRate(newRate);
        
        // Record adjustment event
        _recordAdjustmentEvent(msg.sender, currentRate, newRate, marketSentiment, marketVolatility, "Manual emergency adjustment");
        
        emit EmergencyRateAdjustmentTriggered(msg.sender, currentRate, newRate, marketSentiment, marketVolatility);
        
        return newRate;
    }

    function checkMarketConditions() external {
        if (block.timestamp < lastMonitoringTimestamp + monitoringFrequency) return;
        
        lastMonitoringTimestamp = block.timestamp;
        
        if (!automaticAdjustmentEnabled) return;
        if (IEmissionManager(emissionManager).isEmissionPaused()) return;
        if (block.timestamp < lastAdjustmentTimestamp + cooldownPeriod) return;
        
        // Check market conditions
        int256 marketSentiment = IMarketSentimentAnalyzer(marketSentimentAnalyzer).getCurrentMarketSentiment();
        uint256 marketVolatility = IMarketSentimentAnalyzer(marketSentimentAnalyzer).getMarketVolatility();
        
        // Trigger adjustment if conditions meet thresholds
        if (marketSentiment <= sentimentThreshold || marketVolatility >= volatilityThreshold) {
            // Get current emission rate
            uint256 currentRate = IEmissionManager(emissionManager).getEmissionRate();
            
            // Calculate adjustment percentage based on market conditions
            uint256 adjustmentPercentage = _calculateAdjustmentPercentage(marketSentiment, marketVolatility);
            
            // Calculate new rate
            uint256 newRate = currentRate * (100 - adjustmentPercentage) / 100;
            
            // Update last adjustment timestamp
            lastAdjustmentTimestamp = block.timestamp;
            
            // Set new emission rate
            IEmissionManager(emissionManager).setEmissionRate(newRate);
            
            // Record adjustment event
            _recordAdjustmentEvent(address(this), currentRate, newRate, marketSentiment, marketVolatility, "Automatic adjustment due to market conditions");
            
            emit EmergencyRateAdjustmentTriggered(address(this), currentRate, newRate, marketSentiment, marketVolatility);
        }
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getLastAdjustmentTimestamp() external view returns (uint256) {
        return lastAdjustmentTimestamp;
    }

    function getEmergencyAdjustmentCount() external view returns (uint256) {
        return adjustmentHistory.length;
    }

    function getAdjustmentThresholds() external view returns (int256, uint256) {
        return (sentimentThreshold, volatilityThreshold);
    }

    function getEmergencyAuthoritiesCount() external view returns (uint256) {
        return authorityList.length;
    }

    function isEmergencyAuthority(address account_) external view returns (bool) {
        return emergencyAuthorities[account_];
    }

    function getAdjustmentDetails(uint256 index_) external view returns (
        address triggeredBy,
        uint256 timestamp,
        uint256 previousRate,
        uint256 newRate,
        int256 marketSentiment,
        uint256 marketVolatility,
        string memory reason
    ) {
        if (index_ >= adjustmentHistory.length) revert RAEH_InvalidParameter();
        
        AdjustmentEvent memory event_ = adjustmentHistory[index_];
        return (
            event_.triggeredBy,
            event_.timestamp,
            event_.previousRate,
            event_.newRate,
            event_.marketSentiment,
            event_.marketVolatility,
            event_.reason
        );
    }

    function getTimeUntilNextAllowedAdjustment() external view returns (uint256) {
        if (block.timestamp >= lastAdjustmentTimestamp + cooldownPeriod) {
            return 0;
        }
        
        return lastAdjustmentTimestamp + cooldownPeriod - block.timestamp;
    }

    function calculateExpectedAdjustment() external view returns (uint256 currentRate, uint256 expectedNewRate, uint256 adjustmentPercentage) {
        // Get current market conditions
        int256 marketSentiment = IMarketSentimentAnalyzer(marketSentimentAnalyzer).getCurrentMarketSentiment();
        uint256 marketVolatility = IMarketSentimentAnalyzer(marketSentimentAnalyzer).getMarketVolatility();
        
        // Get current emission rate
        currentRate = IEmissionManager(emissionManager).getEmissionRate();
        
        // Calculate adjustment percentage based on market conditions
        adjustmentPercentage = _calculateAdjustmentPercentage(marketSentiment, marketVolatility);
        
        // Calculate expected new rate
        expectedNewRate = currentRate * (100 - adjustmentPercentage) / 100;
        
        return (currentRate, expectedNewRate, adjustmentPercentage);
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function _calculateAdjustmentPercentage(int256 marketSentiment_, uint256 marketVolatility_) internal view returns (uint256) {
        // Base adjustment percentage based on sentiment
        uint256 sentimentAdjustment = 0;
        if (marketSentiment_ < 0) {
            // Convert negative sentiment to positive for calculation
            uint256 positiveSentiment = uint256(-marketSentiment_);
            
            // Scale from 0-100 to 0-maxReductionPercentage
            sentimentAdjustment = (positiveSentiment * maxReductionPercentage) / 100;
        }
        
        // Additional adjustment based on volatility
        uint256 volatilityAdjustment = 0;
        if (marketVolatility_ > 50) {
            // Scale from 50-100 to 0-maxReductionPercentage/2
            volatilityAdjustment = ((marketVolatility_ - 50) * maxReductionPercentage) / 100;
        }
        
        // Combine adjustments, but cap at maxReductionPercentage
        uint256 totalAdjustment = sentimentAdjustment + volatilityAdjustment;
        if (totalAdjustment > maxReductionPercentage) {
            totalAdjustment = maxReductionPercentage;
        }
        
        return totalAdjustment;
    }

    function _recordAdjustmentEvent(
        address triggeredBy_,
        uint256 previousRate_,
        uint256 newRate_,
        int256 marketSentiment_,
        uint256 marketVolatility_,
        string memory reason_
    ) internal {
        // Create adjustment event record
        AdjustmentEvent memory event_ = AdjustmentEvent({
            triggeredBy: triggeredBy_,
            timestamp: block.timestamp,
            previousRate: previousRate_,
            newRate: newRate_,
            marketSentiment: marketSentiment_,
            marketVolatility: marketVolatility_,
            reason: reason_
        });
        
        adjustmentHistory.push(event_);
    }
}