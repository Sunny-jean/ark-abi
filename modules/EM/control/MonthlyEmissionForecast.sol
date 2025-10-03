// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Emission Manager interface
/// @notice interface for the emission manager contract
interface IEmissionManager {
    function getEmissionRate() external view returns (uint256);
    function getEmissionCap() external view returns (uint256);
    function getTotalEmitted() external view returns (uint256);
    function getLastEmissionBlock() external view returns (uint256);
}

/// @title Weekly Emission Planner interface
/// @notice interface for the weekly emission planner contract
interface IWeeklyEmissionPlanner {
    function getCurrentWeeklyPlan() external view returns (uint256, uint256, uint256);
    function getHistoricalWeeklyEmission(uint256 weeksAgo) external view returns (uint256);
}

/// @title Monthly Emission Forecast interface
/// @notice interface for the monthly emission forecast contract
interface IMonthlyEmissionForecast {
    function getForecastedEmission() external view returns (uint256);
    function getForecastConfidence() external view returns (uint256);
    function getHistoricalAccuracy() external view returns (uint256);
    function getLastForecastTimestamp() external view returns (uint256);
}

/// @title Monthly Emission Forecast
/// @notice Forecasts monthly token emissions based on historical data and current parameters
contract MonthlyEmissionForecast {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event ForecastUpdated(uint256 indexed timestamp, uint256 forecastedEmission, uint256 confidence);
    event ForecastParametersUpdated(uint256 volatilityWeight, uint256 trendWeight, uint256 seasonalityWeight);
    event ForecastAccuracyRecorded(uint256 indexed month, uint256 forecasted, uint256 actual, uint256 accuracy);
    event WeeklyPlannerUpdated(address indexed oldPlanner, address indexed newPlanner);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error MEF_OnlyAdmin();
    error MEF_ZeroAddress();
    error MEF_InvalidParameter();
    error MEF_TooEarlyForUpdate();
    error MEF_NoHistoricalData();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct MonthlyForecast {
        uint256 forecastedEmission;
        uint256 actualEmission;
        uint256 confidence; // 0-100 scale
        uint256 accuracy; // 0-100 scale, calculated after month ends
        uint256 timestamp;
        bool completed;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public emissionManager;
    address public weeklyEmissionPlanner;
    
    // Forecast parameters
    uint256 public volatilityWeight = 30; // Weight for market volatility (0-100)
    uint256 public trendWeight = 40; // Weight for emission trend (0-100)
    uint256 public seasonalityWeight = 30; // Weight for seasonal patterns (0-100)
    
    // Current forecast
    uint256 public currentForecastedEmission;
    uint256 public currentConfidence;
    uint256 public lastForecastTimestamp;
    
    // Historical forecasts
    mapping(uint256 => MonthlyForecast) public monthlyForecasts; // month timestamp => forecast
    uint256[] public forecastTimestamps; // List of all forecast timestamps
    
    uint256 public forecastUpdateFrequency = 7 days;
    uint256 public constant SECONDS_IN_MONTH = 30 days;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert MEF_OnlyAdmin();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address emissionManager_, address weeklyEmissionPlanner_) {
        if (admin_ == address(0) || emissionManager_ == address(0) || weeklyEmissionPlanner_ == address(0)) {
            revert MEF_ZeroAddress();
        }
        
        admin = admin_;
        emissionManager = emissionManager_;
        weeklyEmissionPlanner = weeklyEmissionPlanner_;
        lastForecastTimestamp = block.timestamp;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function setForecastParameters(
        uint256 volatilityWeight_,
        uint256 trendWeight_,
        uint256 seasonalityWeight_
    ) external onlyAdmin {
        if (volatilityWeight_ + trendWeight_ + seasonalityWeight_ != 100) revert MEF_InvalidParameter();
        
        volatilityWeight = volatilityWeight_;
        trendWeight = trendWeight_;
        seasonalityWeight = seasonalityWeight_;
        
        emit ForecastParametersUpdated(volatilityWeight_, trendWeight_, seasonalityWeight_);
    }

    function setWeeklyEmissionPlanner(address planner_) external onlyAdmin {
        if (planner_ == address(0)) revert MEF_ZeroAddress();
        
        address oldPlanner = weeklyEmissionPlanner;
        weeklyEmissionPlanner = planner_;
        
        emit WeeklyPlannerUpdated(oldPlanner, planner_);
    }

    function setForecastUpdateFrequency(uint256 frequency_) external onlyAdmin {
        if (frequency_ < 1 days || frequency_ > 14 days) revert MEF_InvalidParameter();
        
        forecastUpdateFrequency = frequency_;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function updateForecast() external {
        if (block.timestamp < lastForecastTimestamp + forecastUpdateFrequency) revert MEF_TooEarlyForUpdate();
        
        // Get current emission parameters
        uint256 currentRate = IEmissionManager(emissionManager).getEmissionRate();
        uint256 emissionCap = IEmissionManager(emissionManager).getEmissionCap();
        uint256 totalEmitted = IEmissionManager(emissionManager).getTotalEmitted();
        
        // Get weekly plan data
        (uint256 weeklyTarget, uint256 weeklyUsed, uint256 weeklyRemaining) = IWeeklyEmissionPlanner(weeklyEmissionPlanner).getCurrentWeeklyPlan();
        
        // Calculate base forecast (4 weeks of emissions at current rate)
        uint256 baseForecast = currentRate * 4 weeks / 1 days; // Assuming rate is tokens per day
        
        // Apply trend adjustment based on historical weekly emissions
        int256 trendAdjustment = 0;
        uint256 confidence = 70; // Default confidence
        
        if (forecastTimestamps.length > 0) {
            // Calculate trend based on last 4 weeks
            uint256 fourWeeksAgo = IWeeklyEmissionPlanner(weeklyEmissionPlanner).getHistoricalWeeklyEmission(4);
            uint256 threeWeeksAgo = IWeeklyEmissionPlanner(weeklyEmissionPlanner).getHistoricalWeeklyEmission(3);
            uint256 twoWeeksAgo = IWeeklyEmissionPlanner(weeklyEmissionPlanner).getHistoricalWeeklyEmission(2);
            uint256 oneWeekAgo = IWeeklyEmissionPlanner(weeklyEmissionPlanner).getHistoricalWeeklyEmission(1);
            
            if (fourWeeksAgo > 0) {
                // Calculate weighted average of weekly changes
                int256 change1 = int256(threeWeeksAgo) - int256(fourWeeksAgo);
                int256 change2 = int256(twoWeeksAgo) - int256(threeWeeksAgo);
                int256 change3 = int256(oneWeekAgo) - int256(twoWeeksAgo);
                
                // Weight recent changes more heavily
                trendAdjustment = (change1 + change2 * 2 + change3 * 3) / 6;
                
                // Apply trend adjustment to forecast (scaled by trend weight)
                trendAdjustment = trendAdjustment * 4 * int256(trendWeight) / 100;
                
                // Increase confidence if trend is consistent
                if ((change1 > 0 && change2 > 0 && change3 > 0) || (change1 < 0 && change2 < 0 && change3 < 0)) {
                    confidence += 10;
                } else {
                    confidence -= 5;
                }
            }
        } else {
            // No historical data, reduce confidence
            confidence -= 20;
        }
        
        // Apply seasonality adjustment (simplified - would be more complex in production)
        uint256 seasonalAdjustment = 0;
        if (forecastTimestamps.length >= 12) {
            // Use data from same month last year if available
            uint256 sameMonthLastYear = _getMonthlyForecastFromTimestamp(block.timestamp - 365 days);
            if (sameMonthLastYear > 0) {
                seasonalAdjustment = sameMonthLastYear * seasonalityWeight / 100;
                confidence += 5;
            }
        }
        
        // Calculate final forecast
        uint256 forecastedEmission;
        if (trendAdjustment >= 0) {
            forecastedEmission = baseForecast + uint256(trendAdjustment);
        } else {
            forecastedEmission = baseForecast > uint256(-trendAdjustment) ? baseForecast - uint256(-trendAdjustment) : 0;
        }
        
        // Add seasonal adjustment
        forecastedEmission += seasonalAdjustment;
        
        // Ensure forecast doesn't exceed emission cap
        if (forecastedEmission > emissionCap) {
            forecastedEmission = emissionCap;
        }
        
        // Cap confidence at 95%
        if (confidence > 95) {
            confidence = 95;
        }
        
        // Store forecast
        currentForecastedEmission = forecastedEmission;
        currentConfidence = confidence;
        lastForecastTimestamp = block.timestamp;
        
        // Store in monthly forecasts
        uint256 monthTimestamp = _getMonthTimestamp(block.timestamp);
        if (monthlyForecasts[monthTimestamp].timestamp == 0) {
            forecastTimestamps.push(monthTimestamp);
            monthlyForecasts[monthTimestamp].timestamp = monthTimestamp;
        }
        
        monthlyForecasts[monthTimestamp].forecastedEmission = forecastedEmission;
        monthlyForecasts[monthTimestamp].confidence = confidence;
        
        emit ForecastUpdated(block.timestamp, forecastedEmission, confidence);
    }

    function recordActualEmission(uint256 monthTimestamp_, uint256 actualEmission_) external onlyAdmin {
        if (monthlyForecasts[monthTimestamp_].timestamp == 0) revert MEF_NoHistoricalData();
        if (monthlyForecasts[monthTimestamp_].completed) revert MEF_InvalidParameter();
        if (block.timestamp < monthTimestamp_ + SECONDS_IN_MONTH) revert MEF_InvalidParameter();
        
        MonthlyForecast storage forecast = monthlyForecasts[monthTimestamp_];
        forecast.actualEmission = actualEmission_;
        forecast.completed = true;
        
        // Calculate accuracy (0-100 scale)
        uint256 accuracy;
        if (forecast.forecastedEmission > actualEmission_) {
            accuracy = actualEmission_ * 100 / forecast.forecastedEmission;
        } else if (forecast.forecastedEmission < actualEmission_) {
            accuracy = forecast.forecastedEmission * 100 / actualEmission_;
        } else {
            accuracy = 100; // Perfect forecast
        }
        
        forecast.accuracy = accuracy;
        
        emit ForecastAccuracyRecorded(monthTimestamp_, forecast.forecastedEmission, actualEmission_, accuracy);
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getForecastedEmission() external view returns (uint256) {
        return currentForecastedEmission;
    }

    function getForecastConfidence() external view returns (uint256) {
        return currentConfidence;
    }

    function getHistoricalAccuracy() external view returns (uint256) {
        uint256 totalAccuracy = 0;
        uint256 completedForecasts = 0;
        
        for (uint256 i = 0; i < forecastTimestamps.length; i++) {
            MonthlyForecast memory forecast = monthlyForecasts[forecastTimestamps[i]];
            if (forecast.completed) {
                totalAccuracy += forecast.accuracy;
                completedForecasts++;
            }
        }
        
        if (completedForecasts == 0) return 0;
        return totalAccuracy / completedForecasts;
    }

    function getLastForecastTimestamp() external view returns (uint256) {
        return lastForecastTimestamp;
    }

    function getMonthlyForecast(uint256 monthTimestamp_) external view returns (
        uint256 forecastedEmission,
        uint256 actualEmission,
        uint256 confidence,
        uint256 accuracy,
        bool completed
    ) {
        MonthlyForecast memory forecast = monthlyForecasts[monthTimestamp_];
        return (
            forecast.forecastedEmission,
            forecast.actualEmission,
            forecast.confidence,
            forecast.accuracy,
            forecast.completed
        );
    }

    function getForecastCount() external view returns (uint256) {
        return forecastTimestamps.length;
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function _getMonthTimestamp(uint256 timestamp_) internal pure returns (uint256) {
        // Simplification: round down to the start of the month
        // In production, would use a more accurate calculation
        return timestamp_ - (timestamp_ % SECONDS_IN_MONTH);
    }

    function _getMonthlyForecastFromTimestamp(uint256 timestamp_) internal view returns (uint256) {
        uint256 monthTimestamp = _getMonthTimestamp(timestamp_);
        return monthlyForecasts[monthTimestamp].forecastedEmission;
    }
}