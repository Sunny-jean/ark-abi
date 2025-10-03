// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Bond Market interface
/// @notice interface for the bond market contract
interface IBondMarket {
    function getMarketInfo(uint256 marketId) external view returns (address token, uint256 supply, uint256 sold, uint256 price, bool active);
    function getActiveMarkets() external view returns (uint256[] memory);
    function getMarketsByToken(address token) external view returns (uint256[] memory);
}

/// @title Bond Issuance Manager interface
/// @notice interface for the bond issuance manager contract
interface IBondIssuanceManager {
    function getBondDetails(uint256 bondId) external view returns (address token, uint256 amount, uint256 price, uint256 maturity, address owner, bool active);
    function getBondsByUser(address user) external view returns (uint256[] memory);
    function getBondsByToken(address token) external view returns (uint256[] memory);
}

/// @title Bond Settlement Engine interface
/// @notice interface for the bond settlement engine contract
interface IBondSettlementEngine {
    function getSettlementRecord(uint256 bondId) external view returns (uint256 timestamp, uint256 amount, address recipient);
    function getSettlementsByToken(address token) external view returns (uint256[] memory);
    function getTotalSettled(address token) external view returns (uint256);
}

/// @title Bond Market Data Aggregator interface
/// @notice interface for the bond market data aggregator contract
interface IBondMarketDataAggregator {
    function getMarketSummary(address token) external view returns (uint256 activeMarkets, uint256 totalSupply, uint256 totalSold, uint256 averagePrice);
    function getIssuanceSummary(address token) external view returns (uint256 totalIssued, uint256 activeBonds, uint256 averageMaturity);
    function getSettlementSummary(address token) external view returns (uint256 totalSettled, uint256 averageSettlementTime);
    function getTokenVolumeHistory(address token) external view returns (uint256[] memory timestamps, uint256[] memory volumes);
    function getTokenPriceHistory(address token) external view returns (uint256[] memory timestamps, uint256[] memory prices);
}

/// @title Bond Market Data Aggregator
/// @notice Aggregates data from various bond market components
contract BondMarketDataAggregator {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event DataSourceUpdated(string indexed sourceType, address indexed oldSource, address indexed newSource);
    event DataRecordAdded(address indexed token, uint256 timestamp, uint256 volume, uint256 price);
    event HistoricalDataPruned(address indexed token, uint256 oldestTimestamp);
    event TokenAdded(address indexed token);
    event TokenRemoved(address indexed token);
    event AggregationPeriodUpdated(uint256 oldPeriod, uint256 newPeriod);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error BMDA_OnlyAdmin();
    error BMDA_ZeroAddress();
    error BMDA_TokenNotTracked();
    error BMDA_TokenAlreadyTracked();
    error BMDA_InvalidParameter();
    error BMDA_NoDataAvailable();
    error BMDA_InvalidTimeRange();
    error BMDA_DataSourceNotSet();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct DataPoint {
        uint256 timestamp;
        uint256 volume;
        uint256 price;
    }

    struct TokenData {
        bool tracked;
        uint256 lastUpdateTimestamp;
        DataPoint[] historicalData;
        uint256 totalVolume;
        uint256 totalValue;
        uint256 totalTransactions;
    }

    struct MarketSummary {
        uint256 activeMarkets;
        uint256 totalSupply;
        uint256 totalSold;
        uint256 averagePrice;
    }

    struct IssuanceSummary {
        uint256 totalIssued;
        uint256 activeBonds;
        uint256 averageMaturity;
    }

    struct SettlementSummary {
        uint256 totalSettled;
        uint256 averageSettlementTime;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public bondMarket;
    address public bondIssuanceManager;
    address public bondSettlementEngine;
    
    // Data aggregation settings
    uint256 public aggregationPeriod = 86400; // Default: 1 day in seconds
    uint256 public maxHistoricalDataPoints = 90; // Default: 90 days of history
    
    // Token data tracking
    mapping(address => TokenData) public tokenData;
    address[] public trackedTokens;
    
    // Cache for computed summaries
    mapping(address => MarketSummary) public cachedMarketSummaries;
    mapping(address => IssuanceSummary) public cachedIssuanceSummaries;
    mapping(address => SettlementSummary) public cachedSettlementSummaries;
    mapping(address => uint256) public summaryLastUpdated;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert BMDA_OnlyAdmin();
        _;
    }

    modifier tokenExists(address token) {
        if (!tokenData[token].tracked) revert BMDA_TokenNotTracked();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address bondMarket_, address bondIssuanceManager_, address bondSettlementEngine_) {
        if (admin_ == address(0)) revert BMDA_ZeroAddress();
        
        admin = admin_;
        
        if (bondMarket_ != address(0)) bondMarket = bondMarket_;
        if (bondIssuanceManager_ != address(0)) bondIssuanceManager = bondIssuanceManager_;
        if (bondSettlementEngine_ != address(0)) bondSettlementEngine = bondSettlementEngine_;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function setBondMarket(address bondMarket_) external onlyAdmin {
        if (bondMarket_ == address(0)) revert BMDA_ZeroAddress();
        
        address oldSource = bondMarket;
        bondMarket = bondMarket_;
        
        emit DataSourceUpdated("BondMarket", oldSource, bondMarket_);
    }

    function setBondIssuanceManager(address bondIssuanceManager_) external onlyAdmin {
        if (bondIssuanceManager_ == address(0)) revert BMDA_ZeroAddress();
        
        address oldSource = bondIssuanceManager;
        bondIssuanceManager = bondIssuanceManager_;
        
        emit DataSourceUpdated("BondIssuanceManager", oldSource, bondIssuanceManager_);
    }

    function setBondSettlementEngine(address bondSettlementEngine_) external onlyAdmin {
        if (bondSettlementEngine_ == address(0)) revert BMDA_ZeroAddress();
        
        address oldSource = bondSettlementEngine;
        bondSettlementEngine = bondSettlementEngine_;
        
        emit DataSourceUpdated("BondSettlementEngine", oldSource, bondSettlementEngine_);
    }

    function setAggregationPeriod(uint256 period_) external onlyAdmin {
        if (period_ == 0 || period_ > 2592000) revert BMDA_InvalidParameter(); // Max 30 days
        
        uint256 oldPeriod = aggregationPeriod;
        aggregationPeriod = period_;
        
        emit AggregationPeriodUpdated(oldPeriod, period_);
    }

    function setMaxHistoricalDataPoints(uint256 maxPoints_) external onlyAdmin {
        if (maxPoints_ < 7 || maxPoints_ > 365) revert BMDA_InvalidParameter(); // Min 7 days, max 1 year
        
        maxHistoricalDataPoints = maxPoints_;
    }

    function addToken(address token_) external onlyAdmin {
        if (token_ == address(0)) revert BMDA_ZeroAddress();
        if (tokenData[token_].tracked) revert BMDA_TokenAlreadyTracked();
        
        tokenData[token_] = TokenData({
            tracked: true,
            lastUpdateTimestamp: block.timestamp,
            historicalData: new DataPoint[](0),
            totalVolume: 0,
            totalValue: 0,
            totalTransactions: 0
        });
        
        trackedTokens.push(token_);
        
        emit TokenAdded(token_);
    }

    function removeToken(address token_) external onlyAdmin tokenExists(token_) {
        tokenData[token_].tracked = false;
        
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
        TokenData storage data = tokenData[token_];
        
        if (data.historicalData.length <= maxHistoricalDataPoints) {
            return; // No pruning needed
        }
        
        uint256 excessPoints = data.historicalData.length - maxHistoricalDataPoints;
        uint256 oldestTimestamp = data.historicalData[0].timestamp;
        
        // Create new array with only the most recent data points
        DataPoint[] memory newData = new DataPoint[](maxHistoricalDataPoints);
        for (uint256 i = 0; i < maxHistoricalDataPoints; i++) {
            newData[i] = data.historicalData[i + excessPoints];
        }
        
        // Replace historical data
        delete data.historicalData;
        for (uint256 i = 0; i < maxHistoricalDataPoints; i++) {
            data.historicalData.push(newData[i]);
        }
        
        emit HistoricalDataPruned(token_, oldestTimestamp);
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function recordMarketActivity(address token_, uint256 volume_, uint256 price_) external {
        // this would be restricted to authorized sources
        if (msg.sender != admin && 
            msg.sender != bondMarket && 
            msg.sender != bondIssuanceManager && 
            msg.sender != bondSettlementEngine) {
            revert BMDA_OnlyAdmin();
        }
        
        if (!tokenData[token_].tracked) revert BMDA_TokenNotTracked();
        if (volume_ == 0 || price_ == 0) revert BMDA_InvalidParameter();
        
        TokenData storage data = tokenData[token_];
        
        // Update aggregate statistics
        data.totalVolume += volume_;
        data.totalValue += volume_ * price_;
        data.totalTransactions += 1;
        
        // Check if we need to create a new data point or update the latest one
        uint256 currentPeriod = block.timestamp / aggregationPeriod * aggregationPeriod;
        
        if (data.historicalData.length == 0 || 
            data.historicalData[data.historicalData.length - 1].timestamp < currentPeriod) {
            // Create new data point
            data.historicalData.push(DataPoint({
                timestamp: currentPeriod,
                volume: volume_,
                price: price_
            }));
        } else {
            // Update latest data point
            DataPoint storage latestPoint = data.historicalData[data.historicalData.length - 1];
            latestPoint.volume += volume_;
            latestPoint.price = (latestPoint.price + price_) / 2; // Simple average
        }
        
        data.lastUpdateTimestamp = block.timestamp;
        
        // Invalidate cached summaries
        summaryLastUpdated[token_] = 0;
        
        emit DataRecordAdded(token_, currentPeriod, volume_, price_);
        
        // Prune historical data if needed
        if (data.historicalData.length > maxHistoricalDataPoints) {
            uint256 excessPoints = data.historicalData.length - maxHistoricalDataPoints;
            uint256 oldestTimestamp = data.historicalData[0].timestamp;
            
            // Create new array with only the most recent data points
            DataPoint[] memory newData = new DataPoint[](maxHistoricalDataPoints);
            for (uint256 i = 0; i < maxHistoricalDataPoints; i++) {
                newData[i] = data.historicalData[i + excessPoints];
            }
            
            // Replace historical data
            delete data.historicalData;
            for (uint256 i = 0; i < maxHistoricalDataPoints; i++) {
                data.historicalData.push(newData[i]);
            }
            
            emit HistoricalDataPruned(token_, oldestTimestamp);
        }
    }

    function updateMarketSummaries() external {
        if (bondMarket == address(0)) revert BMDA_DataSourceNotSet();
        
        for (uint256 i = 0; i < trackedTokens.length; i++) {
            address token = trackedTokens[i];
            
            // Get all markets for this token
            uint256[] memory markets = IBondMarket(bondMarket).getMarketsByToken(token);
            
            uint256 activeMarkets = 0;
            uint256 totalSupply = 0;
            uint256 totalSold = 0;
            uint256 totalValue = 0;
            
            for (uint256 j = 0; j < markets.length; j++) {
                (address marketToken, uint256 supply, uint256 sold, uint256 price, bool active) = 
                    IBondMarket(bondMarket).getMarketInfo(markets[j]);
                
                if (marketToken != token) continue; // Safety check
                
                if (active) activeMarkets++;
                totalSupply += supply;
                totalSold += sold;
                totalValue += sold * price;
            }
            
            uint256 averagePrice = totalSold > 0 ? totalValue / totalSold : 0;
            
            // Update cached summary
            cachedMarketSummaries[token] = MarketSummary({
                activeMarkets: activeMarkets,
                totalSupply: totalSupply,
                totalSold: totalSold,
                averagePrice: averagePrice
            });
            
            summaryLastUpdated[token] = block.timestamp;
        }
    }

    function updateIssuanceSummaries() external {
        if (bondIssuanceManager == address(0)) revert BMDA_DataSourceNotSet();
        
        for (uint256 i = 0; i < trackedTokens.length; i++) {
            address token = trackedTokens[i];
            
            // Get all bonds for this token
            uint256[] memory bonds = IBondIssuanceManager(bondIssuanceManager).getBondsByToken(token);
            
            uint256 totalIssued = 0;
            uint256 activeBonds = 0;
            uint256 totalMaturity = 0;
            uint256 bondCount = 0;
            
            for (uint256 j = 0; j < bonds.length; j++) {
                (address bondToken, uint256 amount, uint256 price, uint256 maturity, , bool active) = 
                    IBondIssuanceManager(bondIssuanceManager).getBondDetails(bonds[j]);
                
                if (bondToken != token) continue; // Safety check
                
                totalIssued += amount;
                if (active) {
                    activeBonds++;
                    totalMaturity += maturity;
                    bondCount++;
                }
            }
            
            uint256 averageMaturity = bondCount > 0 ? totalMaturity / bondCount : 0;
            
            // Update cached summary
            cachedIssuanceSummaries[token] = IssuanceSummary({
                totalIssued: totalIssued,
                activeBonds: activeBonds,
                averageMaturity: averageMaturity
            });
            
            summaryLastUpdated[token] = block.timestamp;
        }
    }

    function updateSettlementSummaries() external {
        if (bondSettlementEngine == address(0)) revert BMDA_DataSourceNotSet();
        
        for (uint256 i = 0; i < trackedTokens.length; i++) {
            address token = trackedTokens[i];
            
            // Get all settlements for this token
            uint256[] memory settlements = IBondSettlementEngine(bondSettlementEngine).getSettlementsByToken(token);
            
            uint256 totalSettled = IBondSettlementEngine(bondSettlementEngine).getTotalSettled(token);
            uint256 totalSettlementTime = 0;
            
            for (uint256 j = 0; j < settlements.length; j++) {
                (uint256 timestamp, , ) = IBondSettlementEngine(bondSettlementEngine).getSettlementRecord(settlements[j]);
                totalSettlementTime += timestamp;
            }
            
            uint256 averageSettlementTime = settlements.length > 0 ? totalSettlementTime / settlements.length : 0;
            
            // Update cached summary
            cachedSettlementSummaries[token] = SettlementSummary({
                totalSettled: totalSettled,
                averageSettlementTime: averageSettlementTime
            });
            
            summaryLastUpdated[token] = block.timestamp;
        }
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getMarketSummary(address token) external view tokenExists(token) returns (
        uint256 activeMarkets,
        uint256 totalSupply,
        uint256 totalSold,
        uint256 averagePrice
    ) {
        MarketSummary memory summary = cachedMarketSummaries[token];
        
        return (summary.activeMarkets, summary.totalSupply, summary.totalSold, summary.averagePrice);
    }

    function getIssuanceSummary(address token) external view tokenExists(token) returns (
        uint256 totalIssued,
        uint256 activeBonds,
        uint256 averageMaturity
    ) {
        IssuanceSummary memory summary = cachedIssuanceSummaries[token];
        
        return (summary.totalIssued, summary.activeBonds, summary.averageMaturity);
    }

    function getSettlementSummary(address token) external view tokenExists(token) returns (
        uint256 totalSettled,
        uint256 averageSettlementTime
    ) {
        SettlementSummary memory summary = cachedSettlementSummaries[token];
        
        return (summary.totalSettled, summary.averageSettlementTime);
    }

    function getTokenVolumeHistory(address token) external view tokenExists(token) returns (
        uint256[] memory timestamps,
        uint256[] memory volumes
    ) {
        TokenData storage data = tokenData[token];
        
        if (data.historicalData.length == 0) revert BMDA_NoDataAvailable();
        
        timestamps = new uint256[](data.historicalData.length);
        volumes = new uint256[](data.historicalData.length);
        
        for (uint256 i = 0; i < data.historicalData.length; i++) {
            timestamps[i] = data.historicalData[i].timestamp;
            volumes[i] = data.historicalData[i].volume;
        }
        
        return (timestamps, volumes);
    }

    function getTokenPriceHistory(address token) external view tokenExists(token) returns (
        uint256[] memory timestamps,
        uint256[] memory prices
    ) {
        TokenData storage data = tokenData[token];
        
        if (data.historicalData.length == 0) revert BMDA_NoDataAvailable();
        
        timestamps = new uint256[](data.historicalData.length);
        prices = new uint256[](data.historicalData.length);
        
        for (uint256 i = 0; i < data.historicalData.length; i++) {
            timestamps[i] = data.historicalData[i].timestamp;
            prices[i] = data.historicalData[i].price;
        }
        
        return (timestamps, prices);
    }

    function getTokenVolumeHistoryInRange(address token, uint256 startTime, uint256 endTime) external view tokenExists(token) returns (
        uint256[] memory timestamps,
        uint256[] memory volumes
    ) {
        if (startTime >= endTime) revert BMDA_InvalidTimeRange();
        
        TokenData storage data = tokenData[token];
        
        if (data.historicalData.length == 0) revert BMDA_NoDataAvailable();
        
        // Count data points in range
        uint256 count = 0;
        for (uint256 i = 0; i < data.historicalData.length; i++) {
            if (data.historicalData[i].timestamp >= startTime && data.historicalData[i].timestamp <= endTime) {
                count++;
            }
        }
        
        if (count == 0) revert BMDA_NoDataAvailable();
        
        timestamps = new uint256[](count);
        volumes = new uint256[](count);
        
        uint256 index = 0;
        for (uint256 i = 0; i < data.historicalData.length; i++) {
            if (data.historicalData[i].timestamp >= startTime && data.historicalData[i].timestamp <= endTime) {
                timestamps[index] = data.historicalData[i].timestamp;
                volumes[index] = data.historicalData[i].volume;
                index++;
            }
        }
        
        return (timestamps, volumes);
    }

    function getTokenPriceHistoryInRange(address token, uint256 startTime, uint256 endTime) external view tokenExists(token) returns (
        uint256[] memory timestamps,
        uint256[] memory prices
    ) {
        if (startTime >= endTime) revert BMDA_InvalidTimeRange();
        
        TokenData storage data = tokenData[token];
        
        if (data.historicalData.length == 0) revert BMDA_NoDataAvailable();
        
        // Count data points in range
        uint256 count = 0;
        for (uint256 i = 0; i < data.historicalData.length; i++) {
            if (data.historicalData[i].timestamp >= startTime && data.historicalData[i].timestamp <= endTime) {
                count++;
            }
        }
        
        if (count == 0) revert BMDA_NoDataAvailable();
        
        timestamps = new uint256[](count);
        prices = new uint256[](count);
        
        uint256 index = 0;
        for (uint256 i = 0; i < data.historicalData.length; i++) {
            if (data.historicalData[i].timestamp >= startTime && data.historicalData[i].timestamp <= endTime) {
                timestamps[index] = data.historicalData[i].timestamp;
                prices[index] = data.historicalData[i].price;
                index++;
            }
        }
        
        return (timestamps, prices);
    }

    function getTrackedTokens() external view returns (address[] memory) {
        return trackedTokens;
    }

    function getTokenDataSummary(address token) external view tokenExists(token) returns (
        uint256 lastUpdateTimestamp,
        uint256 dataPointsCount,
        uint256 totalVolume,
        uint256 totalValue,
        uint256 totalTransactions
    ) {
        TokenData storage data = tokenData[token];
        
        return (
            data.lastUpdateTimestamp,
            data.historicalData.length,
            data.totalVolume,
            data.totalValue,
            data.totalTransactions
        );
    }

    function getSummaryLastUpdated(address token) external view tokenExists(token) returns (uint256) {
        return summaryLastUpdated[token];
    }

    function getAggregationSettings() external view returns (uint256 period, uint256 maxDataPoints) {
        return (aggregationPeriod, maxHistoricalDataPoints);
    }

    function getDataSources() external view returns (address market, address issuance, address settlement) {
        return (bondMarket, bondIssuanceManager, bondSettlementEngine);
    }
}