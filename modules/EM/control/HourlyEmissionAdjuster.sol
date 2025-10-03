// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

// --- interfaces ---
interface IEmissionManager {
    function getEmissionRate() external view returns (uint256);
    function adjustEmissionRate(uint256 newRate) external;
}

interface IMarketSentimentAnalyzer {
    function getCurrentMarketSentiment() external view returns (int256);
    function getMarketVolatility() external view returns (uint256);
}

/// @title Hourly Emission Adjuster interface
/// @notice interface for the hourly emission adjuster contract
interface IHourlyEmissionAdjuster {
    function getLastAdjustmentTimestamp() external view returns (uint256);
    function getAdjustmentFrequency() external view returns (uint256);
    function getMaxAdjustmentPercentage() external view returns (uint256);
    function getCurrentAdjustmentFactor() external view returns (int256);
}

/// @title Hourly Emission Adjuster
/// @notice Adjusts emission rates on an hourly basis based on market conditions
contract HourlyEmissionAdjuster {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event EmissionRateAdjusted(uint256 oldRate, uint256 newRate, int256 adjustmentFactor);
    event AdjustmentFrequencyUpdated(uint256 oldFrequency, uint256 newFrequency);
    event MaxAdjustmentPercentageUpdated(uint256 oldPercentage, uint256 newPercentage);
    event MarketAnalyzerUpdated(address indexed oldAnalyzer, address indexed newAnalyzer);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error HEA_OnlyAdmin();
    error HEA_ZeroAddress();
    error HEA_InvalidFrequency();
    error HEA_InvalidPercentage();
    error HEA_AdjustmentNotDue();
    error HEA_FailedToAdjust();

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public emissionManager;
    address public marketSentimentAnalyzer;
    
    uint256 public adjustmentFrequency; // seconds between adjustments
    uint256 public lastAdjustmentTimestamp;
    uint256 public maxAdjustmentPercentage; // basis points (e.g., 500 = 5%)
    int256 public currentAdjustmentFactor; // can be positive or negative
    
    uint256 public constant BASIS_POINTS = 10000; // 100%

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert HEA_OnlyAdmin();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(
        address admin_,
        address emissionManager_,
        address marketSentimentAnalyzer_,
        uint256 adjustmentFrequency_,
        uint256 maxAdjustmentPercentage_
    ) {
        if (admin_ == address(0) || emissionManager_ == address(0) || marketSentimentAnalyzer_ == address(0)) {
            revert HEA_ZeroAddress();
        }
        if (adjustmentFrequency_ == 0) revert HEA_InvalidFrequency();
        if (maxAdjustmentPercentage_ == 0 || maxAdjustmentPercentage_ > 2000) revert HEA_InvalidPercentage(); // Max 20%
        
        admin = admin_;
        emissionManager = emissionManager_;
        marketSentimentAnalyzer = marketSentimentAnalyzer_;
        adjustmentFrequency = adjustmentFrequency_;
        maxAdjustmentPercentage = maxAdjustmentPercentage_;
        lastAdjustmentTimestamp = block.timestamp;
        currentAdjustmentFactor = 0;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function setAdjustmentFrequency(uint256 newFrequency_) external onlyAdmin {
        if (newFrequency_ == 0) revert HEA_InvalidFrequency();
        
        uint256 oldFrequency = adjustmentFrequency;
        adjustmentFrequency = newFrequency_;
        
        emit AdjustmentFrequencyUpdated(oldFrequency, newFrequency_);
    }

    function setMaxAdjustmentPercentage(uint256 newPercentage_) external onlyAdmin {
        if (newPercentage_ == 0 || newPercentage_ > 2000) revert HEA_InvalidPercentage(); // Max 20%
        
        uint256 oldPercentage = maxAdjustmentPercentage;
        maxAdjustmentPercentage = newPercentage_;
        
        emit MaxAdjustmentPercentageUpdated(oldPercentage, newPercentage_);
    }

    function setMarketSentimentAnalyzer(address newAnalyzer_) external onlyAdmin {
        if (newAnalyzer_ == address(0)) revert HEA_ZeroAddress();
        
        address oldAnalyzer = marketSentimentAnalyzer;
        marketSentimentAnalyzer = newAnalyzer_;
        
        emit MarketAnalyzerUpdated(oldAnalyzer, newAnalyzer_);
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function adjustEmissionRate() external returns (uint256) {
        if (block.timestamp < lastAdjustmentTimestamp + adjustmentFrequency) {
            revert HEA_AdjustmentNotDue();
        }
        
        // Get current emission rate
        uint256 currentRate = IEmissionManager(emissionManager).getEmissionRate();
        
        // Get market sentiment and volatility
        int256 marketSentiment = IMarketSentimentAnalyzer(marketSentimentAnalyzer).getCurrentMarketSentiment();
        uint256 marketVolatility = IMarketSentimentAnalyzer(marketSentimentAnalyzer).getMarketVolatility();
        
        // Calculate adjustment factor based on market conditions
        // This is a simplified calculation 
        int256 adjustmentFactor = _calculateAdjustmentFactor(marketSentiment, marketVolatility);
        currentAdjustmentFactor = adjustmentFactor;
        
        // Calculate new emission rate
        uint256 newRate;
        if (adjustmentFactor >= 0) {
            // Increase rate
            uint256 increase = (currentRate * uint256(adjustmentFactor)) / BASIS_POINTS;
            newRate = currentRate + increase;
        } else {
            // Decrease rate
            uint256 decrease = (currentRate * uint256(-adjustmentFactor)) / BASIS_POINTS;
            newRate = currentRate > decrease ? currentRate - decrease : 0;
        }
        
        // Update last adjustment timestamp
        lastAdjustmentTimestamp = block.timestamp;
        
        // this would call the emission manager to adjust the rate
        // we'll just emit the event
        
        emit EmissionRateAdjusted(currentRate, newRate, adjustmentFactor);
        
        return newRate;
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getLastAdjustmentTimestamp() external view returns (uint256) {
        return lastAdjustmentTimestamp;
    }

    function getAdjustmentFrequency() external view returns (uint256) {
        return adjustmentFrequency;
    }

    function getMaxAdjustmentPercentage() external view returns (uint256) {
        return maxAdjustmentPercentage;
    }

    function getCurrentAdjustmentFactor() external view returns (int256) {
        return currentAdjustmentFactor;
    }

    function canAdjustNow() external view returns (bool) {
        return block.timestamp >= lastAdjustmentTimestamp + adjustmentFrequency;
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function _calculateAdjustmentFactor(int256 marketSentiment_, uint256 marketVolatility_) internal view returns (int256) {
        // This is a simplified calculation 
        // this would use more complex logic
        
        // Normalize market sentiment to a range of -maxAdjustmentPercentage to +maxAdjustmentPercentage
        int256 sentimentFactor = (marketSentiment_ * int256(maxAdjustmentPercentage)) / 100;
        
        // Adjust based on volatility (higher volatility = more conservative adjustments)
        uint256 volatilityFactor = BASIS_POINTS - (marketVolatility_ * 100);
        volatilityFactor = volatilityFactor < BASIS_POINTS / 2 ? BASIS_POINTS / 2 : volatilityFactor;
        
        // Apply volatility dampening
        sentimentFactor = (sentimentFactor * int256(volatilityFactor)) / int256(BASIS_POINTS);
        
        // Ensure we don't exceed max adjustment
        if (sentimentFactor > int256(maxAdjustmentPercentage)) {
            sentimentFactor = int256(maxAdjustmentPercentage);
        } else if (sentimentFactor < -int256(maxAdjustmentPercentage)) {
            sentimentFactor = -int256(maxAdjustmentPercentage);
        }
        
        return sentimentFactor;
    }
}