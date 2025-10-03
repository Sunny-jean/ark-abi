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
    function recordEmission(address token, uint256 amount, uint256 timestamp) external;
    function getEmissionHistory(address token) external view returns (uint256[] memory timestamps, uint256[] memory amounts);
    function getEmissionHistoryInRange(address token, uint256 startTime, uint256 endTime) external view returns (uint256[] memory timestamps, uint256[] memory amounts);
    function getDailyEmissionAverage(address token, uint256 days_) external view returns (uint256);
    function getWeeklyEmissionAverage(address token, uint256 weeks_) external view returns (uint256);
    function getMonthlyEmissionAverage(address token, uint256 months_) external view returns (uint256);
    function getTotalEmissionsByPeriod(address token, uint256 startTime, uint256 endTime) external view returns (uint256);
}

/// @title Historical Emission Tracker
/// @notice Tracks historical emission data for analysis and auditing
contract HistoricalEmissionTracker {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event EmissionRecorded(address indexed token, uint256 amount, uint256 timestamp);
    event EmissionManagerUpdated(address indexed oldManager, address indexed newManager);
    event TokenAdded(address indexed token);
    event TokenRemoved(address indexed token);
    event HistoricalDataPruned(address indexed token, uint256 oldestTimestamp);
    event AggregationPeriodUpdated(uint256 oldPeriod, uint256 newPeriod);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error HET_OnlyAdmin();
    error HET_OnlyEmissionManager();
    error HET_ZeroAddress();
    error HET_TokenNotTracked();
    error HET_TokenAlreadyTracked();
    error HET_InvalidParameter();
    error HET_NoDataAvailable();
    error HET_InvalidTimeRange();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct EmissionRecord {
        uint256 timestamp;
        uint256 amount;
    }

    struct TokenEmissionData {
        bool tracked;
        uint256 lastUpdateTimestamp;
        EmissionRecord[] records;
        uint256 totalEmitted;
        mapping(uint256 => uint256) dailyEmissions; // day timestamp => amount
        mapping(uint256 => uint256) weeklyEmissions; // week timestamp => amount
        mapping(uint256 => uint256) monthlyEmissions; // month timestamp => amount
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public emissionManager;
    
    // Data aggregation settings
    uint256 public aggregationPeriod = 3600; // Default: 1 hour in seconds
    uint256 public maxHistoricalRecords = 8760; // Default: 1 year of hourly records
    
    // Token data tracking
    mapping(address => TokenEmissionData) public tokenEmissionData;
    address[] public trackedTokens;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert HET_OnlyAdmin();
        _;
    }

    modifier onlyEmissionManager() {
        if (msg.sender != emissionManager && msg.sender != admin) revert HET_OnlyEmissionManager();
        _;
    }

    modifier tokenExists(address token) {
        if (!tokenEmissionData[token].tracked) revert HET_TokenNotTracked();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address emissionManager_) {
        if (admin_ == address(0)) revert HET_ZeroAddress();
        
        admin = admin_;
        
        if (emissionManager_ != address(0)) {
            emissionManager = emissionManager_;
        }
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function setEmissionManager(address emissionManager_) external onlyAdmin {
        if (emissionManager_ == address(0)) revert HET_ZeroAddress();
        
        address oldManager = emissionManager;
        emissionManager = emissionManager_;
        
        emit EmissionManagerUpdated(oldManager, emissionManager_);
    }

    function setAggregationPeriod(uint256 period_) external onlyAdmin {
        if (period_ == 0 || period_ > 86400) revert HET_InvalidParameter(); // Max 1 day
        
        uint256 oldPeriod = aggregationPeriod;
        aggregationPeriod = period_;
        
        emit AggregationPeriodUpdated(oldPeriod, period_);
    }

    function setMaxHistoricalRecords(uint256 maxRecords_) external onlyAdmin {
        if (maxRecords_ < 24 || maxRecords_ > 17520) revert HET_InvalidParameter(); // Min 1 day, max 2 years of hourly records
        
        maxHistoricalRecords = maxRecords_;
    }

    function addToken(address token_) external onlyAdmin {
        if (token_ == address(0)) revert HET_ZeroAddress();
        if (tokenEmissionData[token_].tracked) revert HET_TokenAlreadyTracked();
        
        tokenEmissionData[token_].tracked = true;
        tokenEmissionData[token_].lastUpdateTimestamp = block.timestamp;
        
        trackedTokens.push(token_);
        
        emit TokenAdded(token_);
    }

    function removeToken(address token_) external onlyAdmin tokenExists(token_) {
        tokenEmissionData[token_].tracked = false;
        
        // Remove from trackedTokens array
        for (uint256 i = 0; i < trackedTokens.length; i++) {
            if (trackedTokens[i] == token_) {
                trackedTokens[i] = trackedTokens[trackedTokens.length - 1];
                trackedTokens.pop();
                break;
            }
        }
        
        emit TokenRemoved(token_);
    }

    function pruneHistoricalData(address token_) external onlyAdmin tokenExists(token_) {
        TokenEmissionData storage data = tokenEmissionData[token_];
        
        if (data.records.length <= maxHistoricalRecords) {
            return; // No pruning needed
        }
        
        uint256 excessRecords = data.records.length - maxHistoricalRecords;
        uint256 oldestTimestamp = data.records[0].timestamp;
        
        // Create new array with only the most recent records
        EmissionRecord[] memory newRecords = new EmissionRecord[](maxHistoricalRecords);
        for (uint256 i = 0; i < maxHistoricalRecords; i++) {
            newRecords[i] = data.records[i + excessRecords];
        }
        
        // Replace historical records
        delete data.records;
        for (uint256 i = 0; i < maxHistoricalRecords; i++) {
            data.records.push(newRecords[i]);
        }
        
        emit HistoricalDataPruned(token_, oldestTimestamp);
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function recordEmission(address token, uint256 amount, uint256 timestamp) external onlyEmissionManager tokenExists(token) {
        if (amount == 0) revert HET_InvalidParameter();
        if (timestamp == 0) timestamp = block.timestamp;
        
        TokenEmissionData storage data = tokenEmissionData[token];
        
        // Update aggregate statistics
        data.totalEmitted += amount;
        
        // Add emission record
        data.records.push(EmissionRecord({
            timestamp: timestamp,
            amount: amount
        }));
        
        // Update time-based aggregations
        uint256 dayTimestamp = timestamp / 86400 * 86400; // Round to day
        uint256 weekTimestamp = timestamp / 604800 * 604800; // Round to week
        uint256 monthTimestamp = timestamp / 2592000 * 2592000; // Round to month (30 days)
        
        data.dailyEmissions[dayTimestamp] += amount;
        data.weeklyEmissions[weekTimestamp] += amount;
        data.monthlyEmissions[monthTimestamp] += amount;
        
        data.lastUpdateTimestamp = block.timestamp;
        
        emit EmissionRecorded(token, amount, timestamp);
        
        // Prune historical data if needed
        if (data.records.length > maxHistoricalRecords) {
            uint256 excessRecords = data.records.length - maxHistoricalRecords;
            uint256 oldestTimestamp = data.records[0].timestamp;
            
            // Create new array with only the most recent records
            EmissionRecord[] memory newRecords = new EmissionRecord[](maxHistoricalRecords);
            for (uint256 i = 0; i < maxHistoricalRecords; i++) {
                newRecords[i] = data.records[i + excessRecords];
            }
            
            // Replace historical records
            delete data.records;
            for (uint256 i = 0; i < maxHistoricalRecords; i++) {
                data.records.push(newRecords[i]);
            }
            
            emit HistoricalDataPruned(token, oldestTimestamp);
        }
    }

    function syncWithEmissionManager() external {
        if (emissionManager == address(0)) revert HET_ZeroAddress();
        
        address[] memory tokens = IEmissionManager(emissionManager).getSupportedTokens();
        
        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            
            // Add token if not already tracked
            if (!tokenEmissionData[token].tracked) {
                tokenEmissionData[token].tracked = true;
                tokenEmissionData[token].lastUpdateTimestamp = block.timestamp;
                trackedTokens.push(token);
                
                emit TokenAdded(token);
            }
        }
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getEmissionHistory(address token) external view tokenExists(token) returns (
        uint256[] memory timestamps,
        uint256[] memory amounts
    ) {
        TokenEmissionData storage data = tokenEmissionData[token];
        
        if (data.records.length == 0) revert HET_NoDataAvailable();
        
        timestamps = new uint256[](data.records.length);
        amounts = new uint256[](data.records.length);
        
        for (uint256 i = 0; i < data.records.length; i++) {
            timestamps[i] = data.records[i].timestamp;
            amounts[i] = data.records[i].amount;
        }
        
        return (timestamps, amounts);
    }

    function getEmissionHistoryInRange(address token, uint256 startTime, uint256 endTime) external view tokenExists(token) returns (
        uint256[] memory timestamps,
        uint256[] memory amounts
    ) {
        if (startTime >= endTime) revert HET_InvalidTimeRange();
        
        TokenEmissionData storage data = tokenEmissionData[token];
        
        if (data.records.length == 0) revert HET_NoDataAvailable();
        
        // Count records in range
        uint256 count = 0;
        for (uint256 i = 0; i < data.records.length; i++) {
            if (data.records[i].timestamp >= startTime && data.records[i].timestamp <= endTime) {
                count++;
            }
        }
        
        if (count == 0) revert HET_NoDataAvailable();
        
        timestamps = new uint256[](count);
        amounts = new uint256[](count);
        
        uint256 index = 0;
        for (uint256 i = 0; i < data.records.length; i++) {
            if (data.records[i].timestamp >= startTime && data.records[i].timestamp <= endTime) {
                timestamps[index] = data.records[i].timestamp;
                amounts[index] = data.records[i].amount;
                index++;
            }
        }
        
        return (timestamps, amounts);
    }

    function getDailyEmissionAverage(address token, uint256 days_) external view tokenExists(token) returns (uint256) {
        if (days_ == 0) revert HET_InvalidParameter();
        
        TokenEmissionData storage data = tokenEmissionData[token];
        
        uint256 totalEmissions = 0;
        uint256 currentDay = block.timestamp / 86400 * 86400;
        
        for (uint256 i = 0; i < days_; i++) {
            uint256 dayTimestamp = currentDay - i * 86400;
            totalEmissions += data.dailyEmissions[dayTimestamp];
        }
        
        return totalEmissions / days_;
    }

    function getWeeklyEmissionAverage(address token, uint256 weeks_) external view tokenExists(token) returns (uint256) {
        if (weeks_ == 0) revert HET_InvalidParameter();
        
        TokenEmissionData storage data = tokenEmissionData[token];
        
        uint256 totalEmissions = 0;
        uint256 currentWeek = block.timestamp / 604800 * 604800;
        
        for (uint256 i = 0; i < weeks_; i++) {
            uint256 weekTimestamp = currentWeek - i * 604800;
            totalEmissions += data.weeklyEmissions[weekTimestamp];
        }
        
        return totalEmissions / weeks_;
    }

    function getMonthlyEmissionAverage(address token, uint256 months_) external view tokenExists(token) returns (uint256) {
        if (months_ == 0) revert HET_InvalidParameter();
        
        TokenEmissionData storage data = tokenEmissionData[token];
        
        uint256 totalEmissions = 0;
        uint256 currentMonth = block.timestamp / 2592000 * 2592000;
        
        for (uint256 i = 0; i < months_; i++) {
            uint256 monthTimestamp = currentMonth - i * 2592000;
            totalEmissions += data.monthlyEmissions[monthTimestamp];
        }
        
        return totalEmissions / months_;
    }

    function getTotalEmissionsByPeriod(address token, uint256 startTime, uint256 endTime) external view tokenExists(token) returns (uint256) {
        if (startTime >= endTime) revert HET_InvalidTimeRange();
        
        TokenEmissionData storage data = tokenEmissionData[token];
        
        if (data.records.length == 0) revert HET_NoDataAvailable();
        
        uint256 totalEmissions = 0;
        
        for (uint256 i = 0; i < data.records.length; i++) {
            if (data.records[i].timestamp >= startTime && data.records[i].timestamp <= endTime) {
                totalEmissions += data.records[i].amount;
            }
        }
        
        return totalEmissions;
    }

    function getTrackedTokens() external view returns (address[] memory) {
        return trackedTokens;
    }

    function getTokenEmissionSummary(address token) external view tokenExists(token) returns (
        uint256 lastUpdateTimestamp,
        uint256 recordsCount,
        uint256 totalEmitted
    ) {
        TokenEmissionData storage data = tokenEmissionData[token];
        
        return (
            data.lastUpdateTimestamp,
            data.records.length,
            data.totalEmitted
        );
    }

    function getAggregationSettings() external view returns (uint256 period, uint256 maxRecords) {
        return (aggregationPeriod, maxHistoricalRecords);
    }

    function getEmissionManager() external view returns (address) {
        return emissionManager;
    }

    function getLatestEmission(address token) external view tokenExists(token) returns (uint256 timestamp, uint256 amount) {
        TokenEmissionData storage data = tokenEmissionData[token];
        
        if (data.records.length == 0) revert HET_NoDataAvailable();
        
        EmissionRecord memory latest = data.records[data.records.length - 1];
        
        return (latest.timestamp, latest.amount);
    }

    function getEmissionTrend(address token, uint256 periods) external view tokenExists(token) returns (int256) {
        if (periods == 0 || periods > 30) revert HET_InvalidParameter();
        
        TokenEmissionData storage data = tokenEmissionData[token];
        
        if (data.records.length < periods * 2) revert HET_NoDataAvailable();
        
        uint256 recentTotal = 0;
        uint256 previousTotal = 0;
        
        // Calculate recent total (last 'periods' records)
        for (uint256 i = data.records.length - periods; i < data.records.length; i++) {
            recentTotal += data.records[i].amount;
        }
        
        // Calculate previous total (records before the recent ones)
        for (uint256 i = data.records.length - (periods * 2); i < data.records.length - periods; i++) {
            previousTotal += data.records[i].amount;
        }
        
        // Calculate percentage change
        if (previousTotal == 0) return 10000; // 100% increase if previous was zero
        
        int256 percentageChange = int256((recentTotal * 10000) / previousTotal) - 10000;
        
        return percentageChange;
    }
}