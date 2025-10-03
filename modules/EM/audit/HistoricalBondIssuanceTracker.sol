// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Bond Issuance Manager interface
/// @notice interface for the bond issuance manager contract
interface IBondIssuanceManager {
    function getBondDetails(uint256 bondId) external view returns (address token, uint256 amount, uint256 price, uint256 maturity);
    function getBondStatus(uint256 bondId) external view returns (bool active, bool settled, bool cancelled);
    function getBondsByToken(address token) external view returns (uint256[] memory);
    function getTotalBondCount() external view returns (uint256);
    function getSupportedTokens() external view returns (address[] memory);
}

/// @title Bond Settlement Engine interface
/// @notice interface for the bond settlement engine contract
interface IBondSettlementEngine {
    function getSettlementRecord(uint256 bondId) external view returns (uint256 timestamp, uint256 amount, address settler);
    function getSettlementHistory(address token) external view returns (uint256[] memory bondIds, uint256[] memory timestamps);
    function getTotalSettledAmount(address token) external view returns (uint256);
}

/// @title Historical Bond Issuance Tracker interface
/// @notice interface for the historical bond issuance tracker contract
interface IHistoricalBondIssuanceTracker {
    function recordBondIssuance(uint256 bondId, address token, uint256 amount, uint256 price) external;
    function recordBondSettlement(uint256 bondId, uint256 amount) external;
    function recordBondCancellation(uint256 bondId) external;
    function getDailyIssuanceVolume(address token, uint256 daysAgo) external view returns (uint256);
    function getWeeklyIssuanceVolume(address token, uint256 weeksAgo) external view returns (uint256);
    function getMonthlyIssuanceVolume(address token, uint256 monthsAgo) external view returns (uint256);
    function getDailySettlementVolume(address token, uint256 daysAgo) external view returns (uint256);
    function getWeeklySettlementVolume(address token, uint256 weeksAgo) external view returns (uint256);
    function getMonthlySettlementVolume(address token, uint256 monthsAgo) external view returns (uint256);
    function getIssuanceHistory(address token, uint256 startTime, uint256 endTime) external view returns (uint256[] memory timestamps, uint256[] memory amounts);
    function getSettlementHistory(address token, uint256 startTime, uint256 endTime) external view returns (uint256[] memory timestamps, uint256[] memory amounts);
}

/// @title Historical Bond Issuance Tracker
/// @notice Tracks historical bond issuance and settlement data
contract HistoricalBondIssuanceTracker {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event BondIssuanceRecorded(uint256 indexed bondId, address indexed token, uint256 amount, uint256 price, uint256 timestamp);
    event BondSettlementRecorded(uint256 indexed bondId, address indexed token, uint256 amount, uint256 timestamp);
    event BondCancellationRecorded(uint256 indexed bondId, address indexed token, uint256 timestamp);
    event BondIssuanceManagerUpdated(address indexed oldManager, address indexed newManager);
    event BondSettlementEngineUpdated(address indexed oldEngine, address indexed newEngine);
    event TrackerAuthorityAdded(address indexed authority);
    event TrackerAuthorityRemoved(address indexed authority);
    event AggregationPeriodUpdated(string indexed periodType, uint256 oldPeriod, uint256 newPeriod);
    event TokenAdded(address indexed token);
    event TokenRemoved(address indexed token);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error HIBT_OnlyAdmin();
    error HIBT_OnlyAuthority();
    error HIBT_ZeroAddress();
    error HIBT_TokenNotSupported();
    error HIBT_BondAlreadyRecorded();
    error HIBT_BondNotFound();
    error HIBT_InvalidParameter();
    error HIBT_AuthorityAlreadyAdded();
    error HIBT_AuthorityNotFound();
    error HIBT_TokenAlreadyAdded();
    error HIBT_TokenNotFound();
    error HIBT_DependencyNotSet();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct BondRecord {
        uint256 bondId;
        address token;
        uint256 amount;
        uint256 price;
        uint256 timestamp;
        bool settled;
        bool cancelled;
        uint256 settlementTimestamp;
        uint256 settlementAmount;
    }

    struct DailyData {
        uint256 date; // Timestamp of the start of the day (00:00:00 UTC)
        uint256 issuanceVolume;
        uint256 settlementVolume;
        uint256 cancellationVolume;
        uint256 bondCount;
        uint256 settlementCount;
        uint256 cancellationCount;
    }

    struct TokenData {
        bool supported;
        uint256[] bondIds;
        mapping(uint256 => uint256) bondIdToIndex; // bondId => index in bondIds array
        mapping(uint256 => uint256) dailyDataIndices; // date => index in dailyData array
        DailyData[] dailyData;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public bondIssuanceManager;
    address public bondSettlementEngine;
    
    // Bond records
    mapping(uint256 => BondRecord) public bondRecords;
    uint256[] public recordedBondIds;
    mapping(uint256 => bool) public isBondRecorded;
    
    // Token data
    mapping(address => TokenData) public tokenData;
    address[] public supportedTokens;
    
    // Authorities
    mapping(address => bool) public authorities;
    address[] public authorityList;
    
    // Aggregation periods
    uint256 public daySeconds = 86400; // 24 hours
    uint256 public weekSeconds = 604800; // 7 days
    uint256 public monthSeconds = 2592000; // 30 days

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert HIBT_OnlyAdmin();
        _;
    }

    modifier onlyAuthority() {
        if (msg.sender != admin && !authorities[msg.sender]) revert HIBT_OnlyAuthority();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address bondIssuanceManager_, address bondSettlementEngine_) {
        if (admin_ == address(0)) revert HIBT_ZeroAddress();
        
        admin = admin_;
        
        if (bondIssuanceManager_ != address(0)) bondIssuanceManager = bondIssuanceManager_;
        if (bondSettlementEngine_ != address(0)) bondSettlementEngine = bondSettlementEngine_;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function setBondIssuanceManager(address bondIssuanceManager_) external onlyAdmin {
        if (bondIssuanceManager_ == address(0)) revert HIBT_ZeroAddress();
        
        address oldManager = bondIssuanceManager;
        bondIssuanceManager = bondIssuanceManager_;
        
        emit BondIssuanceManagerUpdated(oldManager, bondIssuanceManager_);
    }

    function setBondSettlementEngine(address bondSettlementEngine_) external onlyAdmin {
        if (bondSettlementEngine_ == address(0)) revert HIBT_ZeroAddress();
        
        address oldEngine = bondSettlementEngine;
        bondSettlementEngine = bondSettlementEngine_;
        
        emit BondSettlementEngineUpdated(oldEngine, bondSettlementEngine_);
    }

    function addAuthority(address authority) external onlyAdmin {
        if (authority == address(0)) revert HIBT_ZeroAddress();
        if (authorities[authority]) revert HIBT_AuthorityAlreadyAdded();
        
        authorities[authority] = true;
        authorityList.push(authority);
        
        emit TrackerAuthorityAdded(authority);
    }

    function removeAuthority(address authority) external onlyAdmin {
        if (!authorities[authority]) revert HIBT_AuthorityNotFound();
        
        authorities[authority] = false;
        
        // Remove from authorityList
        for (uint256 i = 0; i < authorityList.length; i++) {
            if (authorityList[i] == authority) {
                authorityList[i] = authorityList[authorityList.length - 1];
                authorityList.pop();
                break;
            }
        }
        
        emit TrackerAuthorityRemoved(authority);
    }

    function setAggregationPeriods(uint256 day, uint256 week, uint256 month) external onlyAdmin {
        if (day > 0 && day != daySeconds) {
            uint256 oldPeriod = daySeconds;
            daySeconds = day;
            emit AggregationPeriodUpdated("day", oldPeriod, day);
        }
        
        if (week > 0 && week != weekSeconds) {
            uint256 oldPeriod = weekSeconds;
            weekSeconds = week;
            emit AggregationPeriodUpdated("week", oldPeriod, week);
        }
        
        if (month > 0 && month != monthSeconds) {
            uint256 oldPeriod = monthSeconds;
            monthSeconds = month;
            emit AggregationPeriodUpdated("month", oldPeriod, month);
        }
    }

    function addToken(address token) external onlyAdmin {
        if (token == address(0)) revert HIBT_ZeroAddress();
        if (tokenData[token].supported) revert HIBT_TokenAlreadyAdded();
        
        tokenData[token].supported = true;
        supportedTokens.push(token);
        
        emit TokenAdded(token);
    }

    function removeToken(address token) external onlyAdmin {
        if (!tokenData[token].supported) revert HIBT_TokenNotFound();
        
        tokenData[token].supported = false;
        
        // Remove from supportedTokens
        for (uint256 i = 0; i < supportedTokens.length; i++) {
            if (supportedTokens[i] == token) {
                supportedTokens[i] = supportedTokens[supportedTokens.length - 1];
                supportedTokens.pop();
                break;
            }
        }
        
        emit TokenRemoved(token);
    }

    function syncWithBondManager() external onlyAdmin {
        if (bondIssuanceManager == address(0)) revert HIBT_DependencyNotSet();
        
        // Get supported tokens from bond manager
        address[] memory managerTokens = IBondIssuanceManager(bondIssuanceManager).getSupportedTokens();
        
        // Add tokens that are not already supported
        for (uint256 i = 0; i < managerTokens.length; i++) {
            address token = managerTokens[i];
            if (!tokenData[token].supported) {
                tokenData[token].supported = true;
                supportedTokens.push(token);
                emit TokenAdded(token);
            }
        }
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function recordBondIssuance(uint256 bondId, address token, uint256 amount, uint256 price) external onlyAuthority {
        if (isBondRecorded[bondId]) revert HIBT_BondAlreadyRecorded();
        if (!tokenData[token].supported) revert HIBT_TokenNotSupported();
        
        // Record bond
        bondRecords[bondId] = BondRecord({
            bondId: bondId,
            token: token,
            amount: amount,
            price: price,
            timestamp: block.timestamp,
            settled: false,
            cancelled: false,
            settlementTimestamp: 0,
            settlementAmount: 0
        });
        
        recordedBondIds.push(bondId);
        isBondRecorded[bondId] = true;
        
        // Add to token data
        TokenData storage data = tokenData[token];
        data.bondIds.push(bondId);
        data.bondIdToIndex[bondId] = data.bondIds.length - 1;
        
        // Update daily data
        _updateDailyData(token, block.timestamp, amount, 0, 0, 1, 0, 0);
        
        emit BondIssuanceRecorded(bondId, token, amount, price, block.timestamp);
    }

    function recordBondSettlement(uint256 bondId, uint256 amount) external onlyAuthority {
        if (!isBondRecorded[bondId]) revert HIBT_BondNotFound();
        if (bondRecords[bondId].settled) revert HIBT_InvalidParameter();
        if (bondRecords[bondId].cancelled) revert HIBT_InvalidParameter();
        
        // Update bond record
        BondRecord storage record = bondRecords[bondId];
        record.settled = true;
        record.settlementTimestamp = block.timestamp;
        record.settlementAmount = amount;
        
        // Update daily data
        _updateDailyData(record.token, block.timestamp, 0, amount, 0, 0, 1, 0);
        
        emit BondSettlementRecorded(bondId, record.token, amount, block.timestamp);
    }

    function recordBondCancellation(uint256 bondId) external onlyAuthority {
        if (!isBondRecorded[bondId]) revert HIBT_BondNotFound();
        if (bondRecords[bondId].settled) revert HIBT_InvalidParameter();
        if (bondRecords[bondId].cancelled) revert HIBT_InvalidParameter();
        
        // Update bond record
        BondRecord storage record = bondRecords[bondId];
        record.cancelled = true;
        
        // Update daily data
        _updateDailyData(record.token, block.timestamp, 0, 0, record.amount, 0, 0, 1);
        
        emit BondCancellationRecorded(bondId, record.token, block.timestamp);
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getDailyIssuanceVolume(address token, uint256 daysAgo) external view returns (uint256) {
        if (!tokenData[token].supported) return 0;
        
        uint256 targetDate = _getStartOfDay(block.timestamp - daysAgo * daySeconds);
        TokenData storage data = tokenData[token];
        
        if (data.dailyDataIndices[targetDate] > 0) {
            uint256 index = data.dailyDataIndices[targetDate] - 1;
            return data.dailyData[index].issuanceVolume;
        }
        
        return 0;
    }

    function getWeeklyIssuanceVolume(address token, uint256 weeksAgo) external view returns (uint256) {
        if (!tokenData[token].supported) return 0;
        
        uint256 endDate = _getStartOfDay(block.timestamp - weeksAgo * weekSeconds);
        uint256 startDate = endDate - 7 * daySeconds;
        
        return _getVolumeInRange(token, startDate, endDate, true, false, false);
    }

    function getMonthlyIssuanceVolume(address token, uint256 monthsAgo) external view returns (uint256) {
        if (!tokenData[token].supported) return 0;
        
        uint256 endDate = _getStartOfDay(block.timestamp - monthsAgo * monthSeconds);
        uint256 startDate = endDate - 30 * daySeconds;
        
        return _getVolumeInRange(token, startDate, endDate, true, false, false);
    }

    function getDailySettlementVolume(address token, uint256 daysAgo) external view returns (uint256) {
        if (!tokenData[token].supported) return 0;
        
        uint256 targetDate = _getStartOfDay(block.timestamp - daysAgo * daySeconds);
        TokenData storage data = tokenData[token];
        
        if (data.dailyDataIndices[targetDate] > 0) {
            uint256 index = data.dailyDataIndices[targetDate] - 1;
            return data.dailyData[index].settlementVolume;
        }
        
        return 0;
    }

    function getWeeklySettlementVolume(address token, uint256 weeksAgo) external view returns (uint256) {
        if (!tokenData[token].supported) return 0;
        
        uint256 endDate = _getStartOfDay(block.timestamp - weeksAgo * weekSeconds);
        uint256 startDate = endDate - 7 * daySeconds;
        
        return _getVolumeInRange(token, startDate, endDate, false, true, false);
    }

    function getMonthlySettlementVolume(address token, uint256 monthsAgo) external view returns (uint256) {
        if (!tokenData[token].supported) return 0;
        
        uint256 endDate = _getStartOfDay(block.timestamp - monthsAgo * monthSeconds);
        uint256 startDate = endDate - 30 * daySeconds;
        
        return _getVolumeInRange(token, startDate, endDate, false, true, false);
    }

    function getIssuanceHistory(address token, uint256 startTime, uint256 endTime) external view returns (uint256[] memory timestamps, uint256[] memory amounts) {
        if (!tokenData[token].supported) {
            timestamps = new uint256[](0);
            amounts = new uint256[](0);
            return (timestamps, amounts);
        }
        
        // Count bonds in the time range
        uint256 count = 0;
        for (uint256 i = 0; i < tokenData[token].bondIds.length; i++) {
            uint256 bondId = tokenData[token].bondIds[i];
            BondRecord storage record = bondRecords[bondId];
            
            if (record.timestamp >= startTime && record.timestamp <= endTime) {
                count++;
            }
        }
        
        // Create arrays
        timestamps = new uint256[](count);
        amounts = new uint256[](count);
        
        // Fill arrays
        uint256 index = 0;
        for (uint256 i = 0; i < tokenData[token].bondIds.length; i++) {
            uint256 bondId = tokenData[token].bondIds[i];
            BondRecord storage record = bondRecords[bondId];
            
            if (record.timestamp >= startTime && record.timestamp <= endTime) {
                timestamps[index] = record.timestamp;
                amounts[index] = record.amount;
                index++;
            }
        }
        
        return (timestamps, amounts);
    }

    function getSettlementHistory(address token, uint256 startTime, uint256 endTime) external view returns (uint256[] memory timestamps, uint256[] memory amounts) {
        if (!tokenData[token].supported) {
            timestamps = new uint256[](0);
            amounts = new uint256[](0);
            return (timestamps, amounts);
        }
        
        // Count settlements in the time range
        uint256 count = 0;
        for (uint256 i = 0; i < tokenData[token].bondIds.length; i++) {
            uint256 bondId = tokenData[token].bondIds[i];
            BondRecord storage record = bondRecords[bondId];
            
            if (record.settled && record.settlementTimestamp >= startTime && record.settlementTimestamp <= endTime) {
                count++;
            }
        }
        
        // Create arrays
        timestamps = new uint256[](count);
        amounts = new uint256[](count);
        
        // Fill arrays
        uint256 index = 0;
        for (uint256 i = 0; i < tokenData[token].bondIds.length; i++) {
            uint256 bondId = tokenData[token].bondIds[i];
            BondRecord storage record = bondRecords[bondId];
            
            if (record.settled && record.settlementTimestamp >= startTime && record.settlementTimestamp <= endTime) {
                timestamps[index] = record.settlementTimestamp;
                amounts[index] = record.settlementAmount;
                index++;
            }
        }
        
        return (timestamps, amounts);
    }

    function getBondRecord(uint256 bondId) external view returns (
        address token,
        uint256 amount,
        uint256 price,
        uint256 timestamp,
        bool settled,
        bool cancelled,
        uint256 settlementTimestamp,
        uint256 settlementAmount
    ) {
        if (!isBondRecorded[bondId]) revert HIBT_BondNotFound();
        
        BondRecord storage record = bondRecords[bondId];
        
        return (
            record.token,
            record.amount,
            record.price,
            record.timestamp,
            record.settled,
            record.cancelled,
            record.settlementTimestamp,
            record.settlementAmount
        );
    }

    function getBondsByToken(address token) external view returns (uint256[] memory) {
        if (!tokenData[token].supported) return new uint256[](0);
        
        return tokenData[token].bondIds;
    }

    function getDailyData(address token, uint256 date) external view returns (
        uint256 issuanceVolume,
        uint256 settlementVolume,
        uint256 cancellationVolume,
        uint256 bondCount,
        uint256 settlementCount,
        uint256 cancellationCount
    ) {
        if (!tokenData[token].supported) {
            return (0, 0, 0, 0, 0, 0);
        }
        
        date = _getStartOfDay(date);
        TokenData storage data = tokenData[token];
        
        if (data.dailyDataIndices[date] > 0) {
            uint256 index = data.dailyDataIndices[date] - 1;
            DailyData storage dailyData = data.dailyData[index];
            
            return (
                dailyData.issuanceVolume,
                dailyData.settlementVolume,
                dailyData.cancellationVolume,
                dailyData.bondCount,
                dailyData.settlementCount,
                dailyData.cancellationCount
            );
        }
        
        return (0, 0, 0, 0, 0, 0);
    }

    function getRecordedBondCount() external view returns (uint256) {
        return recordedBondIds.length;
    }

    function getSupportedTokens() external view returns (address[] memory) {
        return supportedTokens;
    }

    function getAuthorities() external view returns (address[] memory) {
        return authorityList;
    }

    function getAggregationPeriods() external view returns (uint256 day, uint256 week, uint256 month) {
        return (daySeconds, weekSeconds, monthSeconds);
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function _updateDailyData(
        address token,
        uint256 timestamp,
        uint256 issuanceAmount,
        uint256 settlementAmount,
        uint256 cancellationAmount,
        uint256 bondCount,
        uint256 settlementCount,
        uint256 cancellationCount
    ) internal {
        uint256 date = _getStartOfDay(timestamp);
        TokenData storage data = tokenData[token];
        
        // Check if we already have data for this date
        if (data.dailyDataIndices[date] > 0) {
            uint256 index = data.dailyDataIndices[date] - 1;
            DailyData storage dailyData = data.dailyData[index];
            
            // Update existing data
            dailyData.issuanceVolume += issuanceAmount;
            dailyData.settlementVolume += settlementAmount;
            dailyData.cancellationVolume += cancellationAmount;
            dailyData.bondCount += bondCount;
            dailyData.settlementCount += settlementCount;
            dailyData.cancellationCount += cancellationCount;
        } else {
            // Create new daily data
            data.dailyData.push(DailyData({
                date: date,
                issuanceVolume: issuanceAmount,
                settlementVolume: settlementAmount,
                cancellationVolume: cancellationAmount,
                bondCount: bondCount,
                settlementCount: settlementCount,
                cancellationCount: cancellationCount
            }));
            
            data.dailyDataIndices[date] = data.dailyData.length;
        }
    }

    function _getStartOfDay(uint256 timestamp) internal pure returns (uint256) {
        return timestamp - (timestamp % 86400);
    }

    function _getVolumeInRange(
        address token,
        uint256 startDate,
        uint256 endDate,
        bool issuance,
        bool settlement,
        bool cancellation
    ) internal view returns (uint256) {
        TokenData storage data = tokenData[token];
        uint256 volume = 0;
        
        // Iterate through daily data in the range
        for (uint256 i = 0; i < data.dailyData.length; i++) {
            DailyData storage dailyData = data.dailyData[i];
            
            if (dailyData.date >= startDate && dailyData.date <= endDate) {
                if (issuance) volume += dailyData.issuanceVolume;
                if (settlement) volume += dailyData.settlementVolume;
                if (cancellation) volume += dailyData.cancellationVolume;
            }
        }
        
        return volume;
    }
}