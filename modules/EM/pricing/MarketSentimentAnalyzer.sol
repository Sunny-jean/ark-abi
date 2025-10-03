// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

// --- interfaces ---
interface IOracle {
    function getPrice(address token) external view returns (uint256);
}

interface IMarketDataProvider {
    function getVolatilityIndex() external view returns (uint256);
    function getLiquidityIndex() external view returns (uint256);
    function getTradingVolume(address token) external view returns (uint256);
}

/// @title Market Sentiment Analyzer interface
/// @notice interface for the market sentiment analyzer contract
interface IMarketSentimentAnalyzer {
    function getCurrentMarketSentiment() external view returns (int256);
    function getMarketVolatility() external view returns (uint256);
    function getTokenSentiment(address token) external view returns (int256);
    function getHistoricalSentiment(uint256 lookbackPeriod) external view returns (int256);
}

/// @title Market Sentiment Analyzer
/// @notice Analyzes market sentiment based on various on-chain and off-chain data points
contract MarketSentimentAnalyzer {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event DataProviderUpdated(address indexed oldProvider, address indexed newProvider);
    event OracleUpdated(address indexed token, address indexed oracle);
    event SentimentRecorded(uint256 indexed timestamp, int256 sentiment, uint256 volatility);
    event TokenAdded(address indexed token, uint256 weight);
    event TokenRemoved(address indexed token);
    event TokenWeightUpdated(address indexed token, uint256 oldWeight, uint256 newWeight);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error MSA_OnlyAdmin();
    error MSA_ZeroAddress();
    error MSA_InvalidWeight();
    error MSA_TokenNotTracked();
    error MSA_TokenAlreadyTracked();
    error MSA_InvalidParameter();
    error MSA_NoDataAvailable();
    error MSA_OracleNotSet();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct TokenData {
        uint256 weight; // Importance weight in sentiment calculation
        address oracle; // Price oracle for this token
        uint256 lastPrice; // Last recorded price
        int256 priceChange; // Percentage change since last update
        bool tracked; // Whether this token is being tracked
    }

    struct SentimentRecord {
        int256 sentiment; // Overall market sentiment (-100 to 100)
        uint256 volatility; // Market volatility (0 to 100)
        uint256 timestamp; // When this record was created
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public marketDataProvider;
    
    mapping(address => TokenData) public tokenData; // token => data
    address[] public trackedTokens; // List of all tracked tokens
    
    SentimentRecord[] public sentimentHistory; // Historical sentiment records
    uint256 public constant MAX_HISTORY_LENGTH = 30; // Maximum number of historical records to keep
    
    uint256 public lastUpdateTimestamp;
    uint256 public updateFrequency = 1 hours;
    
    int256 public currentSentiment = 0; // Current market sentiment (-100 to 100)
    uint256 public currentVolatility = 50; // Current market volatility (0 to 100)

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert MSA_OnlyAdmin();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address marketDataProvider_) {
        if (admin_ == address(0) || marketDataProvider_ == address(0)) revert MSA_ZeroAddress();
        
        admin = admin_;
        marketDataProvider = marketDataProvider_;
        lastUpdateTimestamp = block.timestamp;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function addToken(address token_, uint256 weight_, address oracle_) external onlyAdmin {
        if (token_ == address(0) || oracle_ == address(0)) revert MSA_ZeroAddress();
        if (weight_ == 0 || weight_ > 100) revert MSA_InvalidWeight();
        if (tokenData[token_].tracked) revert MSA_TokenAlreadyTracked();
        
        tokenData[token_] = TokenData({
            weight: weight_,
            oracle: oracle_,
            lastPrice: 0,
            priceChange: 0,
            tracked: true
        });
        
        trackedTokens.push(token_);
        
        emit TokenAdded(token_, weight_);
        emit OracleUpdated(token_, oracle_);
    }

    function removeToken(address token_) external onlyAdmin {
        if (!tokenData[token_].tracked) revert MSA_TokenNotTracked();
        
        // Find and remove token from trackedTokens array
        for (uint256 i = 0; i < trackedTokens.length; i++) {
            if (trackedTokens[i] == token_) {
                // Replace with the last element and pop
                trackedTokens[i] = trackedTokens[trackedTokens.length - 1];
                trackedTokens.pop();
                break;
            }
        }
        
        delete tokenData[token_];
        
        emit TokenRemoved(token_);
    }

    function updateTokenWeight(address token_, uint256 weight_) external onlyAdmin {
        if (!tokenData[token_].tracked) revert MSA_TokenNotTracked();
        if (weight_ == 0 || weight_ > 100) revert MSA_InvalidWeight();
        
        uint256 oldWeight = tokenData[token_].weight;
        tokenData[token_].weight = weight_;
        
        emit TokenWeightUpdated(token_, oldWeight, weight_);
    }

    function updateOracle(address token_, address oracle_) external onlyAdmin {
        if (!tokenData[token_].tracked) revert MSA_TokenNotTracked();
        if (oracle_ == address(0)) revert MSA_ZeroAddress();
        
        tokenData[token_].oracle = oracle_;
        
        emit OracleUpdated(token_, oracle_);
    }

    function setMarketDataProvider(address provider_) external onlyAdmin {
        if (provider_ == address(0)) revert MSA_ZeroAddress();
        
        address oldProvider = marketDataProvider;
        marketDataProvider = provider_;
        
        emit DataProviderUpdated(oldProvider, provider_);
    }

    function setUpdateFrequency(uint256 frequency_) external onlyAdmin {
        if (frequency_ < 15 minutes || frequency_ > 24 hours) revert MSA_InvalidParameter();
        
        updateFrequency = frequency_;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function updateMarketSentiment() external {
        if (block.timestamp < lastUpdateTimestamp + updateFrequency) revert MSA_InvalidParameter();
        
        // Update token prices and calculate price changes
        _updateTokenPrices();
        
        // Calculate new sentiment based on token price changes and weights
        int256 weightedSentiment = 0;
        uint256 totalWeight = 0;
        
        for (uint256 i = 0; i < trackedTokens.length; i++) {
            address token = trackedTokens[i];
            TokenData storage data = tokenData[token];
            
            weightedSentiment += data.priceChange * int256(data.weight);
            totalWeight += data.weight;
        }
        
        // Get market data from provider
        uint256 volatilityIndex = IMarketDataProvider(marketDataProvider).getVolatilityIndex();
        uint256 liquidityIndex = IMarketDataProvider(marketDataProvider).getLiquidityIndex();
        
        // Calculate final sentiment
        if (totalWeight > 0) {
            // Normalize to -100 to 100 range
            currentSentiment = (weightedSentiment / int256(totalWeight)) * 5; // Amplify effect
            
            // Clamp to range
            if (currentSentiment > 100) currentSentiment = 100;
            if (currentSentiment < -100) currentSentiment = -100;
            
            // Adjust based on liquidity (higher liquidity = more positive sentiment)
            currentSentiment += int256(liquidityIndex) / 10 - 5; // -5 to +5 adjustment
            
            // Clamp again
            if (currentSentiment > 100) currentSentiment = 100;
            if (currentSentiment < -100) currentSentiment = -100;
        }
        
        // Update volatility (0-100 scale)
        currentVolatility = volatilityIndex;
        
        // Record sentiment history
        _recordSentiment();
        
        lastUpdateTimestamp = block.timestamp;
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getCurrentMarketSentiment() external view returns (int256) {
        return currentSentiment;
    }

    function getMarketVolatility() external view returns (uint256) {
        return currentVolatility;
    }

    function getTokenSentiment(address token_) external view returns (int256) {
        if (!tokenData[token_].tracked) revert MSA_TokenNotTracked();
        return tokenData[token_].priceChange * 5; // Amplify and normalize to similar scale as market sentiment
    }

    function getHistoricalSentiment(uint256 lookbackPeriod_) external view returns (int256) {
        if (sentimentHistory.length == 0) revert MSA_NoDataAvailable();
        
        uint256 periods = lookbackPeriod_ / updateFrequency;
        if (periods == 0) periods = 1;
        if (periods > sentimentHistory.length) periods = sentimentHistory.length;
        
        int256 totalSentiment = 0;
        
        for (uint256 i = 0; i < periods; i++) {
            uint256 index = sentimentHistory.length - 1 - i;
            totalSentiment += sentimentHistory[index].sentiment;
        }
        
        return totalSentiment / int256(periods);
    }

    function getTrackedTokenCount() external view returns (uint256) {
        return trackedTokens.length;
    }

    function getSentimentHistoryLength() external view returns (uint256) {
        return sentimentHistory.length;
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function _updateTokenPrices() internal {
        for (uint256 i = 0; i < trackedTokens.length; i++) {
            address token = trackedTokens[i];
            TokenData storage data = tokenData[token];
            
            if (data.oracle == address(0)) revert MSA_OracleNotSet();
            
            uint256 currentPrice = IOracle(data.oracle).getPrice(token);
            
            if (data.lastPrice > 0) {
                // Calculate percentage change
                if (currentPrice > data.lastPrice) {
                    // Price increased
                    data.priceChange = int256((currentPrice - data.lastPrice) * 100 / data.lastPrice);
                } else if (currentPrice < data.lastPrice) {
                    // Price decreased
                    data.priceChange = -int256((data.lastPrice - currentPrice) * 100 / data.lastPrice);
                } else {
                    // No change
                    data.priceChange = 0;
                }
            }
            
            data.lastPrice = currentPrice;
        }
    }

    function _recordSentiment() internal {
        SentimentRecord memory record = SentimentRecord({
            sentiment: currentSentiment,
            volatility: currentVolatility,
            timestamp: block.timestamp
        });
        
        sentimentHistory.push(record);
        
        // Maintain maximum history length
        if (sentimentHistory.length > MAX_HISTORY_LENGTH) {
            // Remove oldest record
            for (uint256 i = 0; i < sentimentHistory.length - 1; i++) {
                sentimentHistory[i] = sentimentHistory[i + 1];
            }
            sentimentHistory.pop();
        }
        
        emit SentimentRecorded(block.timestamp, currentSentiment, currentVolatility);
    }
}