// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Bond Market interface
/// @notice interface for interacting with bond markets
interface IBondMarket {
    function getBondPrice(address token) external view returns (uint256);
    function getBondDiscount(address token) external view returns (uint256);
    function getTotalBondedValue() external view returns (uint256);
    function getAvailableBonds() external view returns (address[] memory);
}

/// @title Bond Pricer interface
/// @notice interface for the bond pricer contract
interface IBondPricer {
    function getCurrentPrice(address token) external view returns (uint256);
    function getDiscountRate(address token) external view returns (uint256);
    function updatePrice(address token) external returns (uint256);
}

/// @title Bond Market Adapter interface
/// @notice interface for the bond market adapter contract
interface IBondMarketAdapter {
    function getBondMarketInfo(address token) external view returns (uint256 price, uint256 discount, uint256 supply);
    function getMarketLiquidity(address token) external view returns (uint256);
    function getSupportedMarkets() external view returns (address[] memory);
    function isMarketSupported(address token) external view returns (bool);
}

/// @title Bond Market Adapter
/// @notice Adapter for interacting with various bond markets
contract BondMarketAdapter {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event BondMarketAdded(address indexed market, string marketName);
    event BondMarketRemoved(address indexed market);
    event BondPricerUpdated(address indexed oldPricer, address indexed newPricer);
    event TokenAdded(address indexed token, address indexed market);
    event TokenRemoved(address indexed token);
    event AdapterConfigUpdated(uint256 updateFrequency, uint256 maxSlippage);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error BMA_OnlyAdmin();
    error BMA_ZeroAddress();
    error BMA_MarketAlreadyAdded();
    error BMA_MarketNotSupported();
    error BMA_TokenAlreadyAdded();
    error BMA_TokenNotSupported();
    error BMA_InvalidParameter();
    error BMA_UpdateTooFrequent();
    error BMA_SlippageExceeded();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct MarketInfo {
        string name;
        bool active;
        uint256 addedTimestamp;
        uint256 totalBondedValue;
        uint256 lastUpdateTimestamp;
    }

    struct TokenInfo {
        address market;
        uint256 price;
        uint256 discount;
        uint256 supply;
        uint256 liquidity;
        uint256 lastUpdateTimestamp;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public bondPricer;
    
    // Bond markets
    mapping(address => MarketInfo) public bondMarkets;
    address[] public supportedMarkets;
    
    // Token information
    mapping(address => TokenInfo) public tokenInfo;
    address[] public supportedTokens;
    
    // Configuration
    uint256 public updateFrequency = 1 hours;
    uint256 public maxSlippage = 300; // 3% in basis points
    uint256 public lastGlobalUpdate;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert BMA_OnlyAdmin();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address bondPricer_) {
        if (admin_ == address(0) || bondPricer_ == address(0)) revert BMA_ZeroAddress();
        
        admin = admin_;
        bondPricer = bondPricer_;
        lastGlobalUpdate = block.timestamp;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function addBondMarket(address market_, string calldata name_) external onlyAdmin {
        if (market_ == address(0)) revert BMA_ZeroAddress();
        if (bondMarkets[market_].active) revert BMA_MarketAlreadyAdded();
        
        bondMarkets[market_] = MarketInfo({
            name: name_,
            active: true,
            addedTimestamp: block.timestamp,
            totalBondedValue: 0,
            lastUpdateTimestamp: block.timestamp
        });
        
        supportedMarkets.push(market_);
        
        emit BondMarketAdded(market_, name_);
    }

    function removeBondMarket(address market_) external onlyAdmin {
        if (!bondMarkets[market_].active) revert BMA_MarketNotSupported();
        
        bondMarkets[market_].active = false;
        
        // Remove tokens associated with this market
        for (uint256 i = 0; i < supportedTokens.length; i++) {
            address token = supportedTokens[i];
            if (tokenInfo[token].market == market_) {
                _removeToken(token);
            }
        }
        
        emit BondMarketRemoved(market_);
    }

    function addToken(address token_, address market_) external onlyAdmin {
        if (token_ == address(0)) revert BMA_ZeroAddress();
        if (!bondMarkets[market_].active) revert BMA_MarketNotSupported();
        if (tokenInfo[token_].market != address(0)) revert BMA_TokenAlreadyAdded();
        
        // Initialize token info
        tokenInfo[token_] = TokenInfo({
            market: market_,
            price: 0,
            discount: 0,
            supply: 0,
            liquidity: 0,
            lastUpdateTimestamp: block.timestamp
        });
        
        supportedTokens.push(token_);
        
        // Update initial price and info
        _updateTokenInfo(token_);
        
        emit TokenAdded(token_, market_);
    }

    function removeToken(address token_) external onlyAdmin {
        if (tokenInfo[token_].market == address(0)) revert BMA_TokenNotSupported();
        
        _removeToken(token_);
        
        emit TokenRemoved(token_);
    }

    function setBondPricer(address pricer_) external onlyAdmin {
        if (pricer_ == address(0)) revert BMA_ZeroAddress();
        
        address oldPricer = bondPricer;
        bondPricer = pricer_;
        
        emit BondPricerUpdated(oldPricer, pricer_);
    }

    function setAdapterConfig(uint256 updateFrequency_, uint256 maxSlippage_) external onlyAdmin {
        if (updateFrequency_ < 15 minutes || updateFrequency_ > 24 hours) revert BMA_InvalidParameter();
        if (maxSlippage_ > 1000) revert BMA_InvalidParameter(); // Max 10%
        
        updateFrequency = updateFrequency_;
        maxSlippage = maxSlippage_;
        
        emit AdapterConfigUpdated(updateFrequency_, maxSlippage_);
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function updateMarketInfo(address market_) external {
        if (!bondMarkets[market_].active) revert BMA_MarketNotSupported();
        if (block.timestamp < bondMarkets[market_].lastUpdateTimestamp + updateFrequency) revert BMA_UpdateTooFrequent();
        
        // Update market total bonded value
        uint256 totalBondedValue = IBondMarket(market_).getTotalBondedValue();
        bondMarkets[market_].totalBondedValue = totalBondedValue;
        bondMarkets[market_].lastUpdateTimestamp = block.timestamp;
        
        // Update all tokens associated with this market
        for (uint256 i = 0; i < supportedTokens.length; i++) {
            address token = supportedTokens[i];
            if (tokenInfo[token].market == market_) {
                _updateTokenInfo(token);
            }
        }
    }

    function updateTokenInfo(address token_) external {
        if (tokenInfo[token_].market == address(0)) revert BMA_TokenNotSupported();
        if (block.timestamp < tokenInfo[token_].lastUpdateTimestamp + updateFrequency) revert BMA_UpdateTooFrequent();
        
        _updateTokenInfo(token_);
    }

    function updateAllMarkets() external {
        if (block.timestamp < lastGlobalUpdate + updateFrequency) revert BMA_UpdateTooFrequent();
        
        lastGlobalUpdate = block.timestamp;
        
        for (uint256 i = 0; i < supportedMarkets.length; i++) {
            address market = supportedMarkets[i];
            if (bondMarkets[market].active) {
                // Update market total bonded value
                uint256 totalBondedValue = IBondMarket(market).getTotalBondedValue();
                bondMarkets[market].totalBondedValue = totalBondedValue;
                bondMarkets[market].lastUpdateTimestamp = block.timestamp;
            }
        }
        
        for (uint256 i = 0; i < supportedTokens.length; i++) {
            address token = supportedTokens[i];
            if (tokenInfo[token].market != address(0)) {
                _updateTokenInfo(token);
            }
        }
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getBondMarketInfo(address token_) external view returns (uint256 price, uint256 discount, uint256 supply) {
        if (tokenInfo[token_].market == address(0)) revert BMA_TokenNotSupported();
        
        return (tokenInfo[token_].price, tokenInfo[token_].discount, tokenInfo[token_].supply);
    }

    function getMarketLiquidity(address token_) external view returns (uint256) {
        if (tokenInfo[token_].market == address(0)) revert BMA_TokenNotSupported();
        
        return tokenInfo[token_].liquidity;
    }

    function getSupportedMarkets() external view returns (address[] memory) {
        uint256 activeCount = 0;
        
        // Count active markets
        for (uint256 i = 0; i < supportedMarkets.length; i++) {
            if (bondMarkets[supportedMarkets[i]].active) {
                activeCount++;
            }
        }
        
        // Create array of active markets
        address[] memory activeMarkets = new address[](activeCount);
        uint256 index = 0;
        
        for (uint256 i = 0; i < supportedMarkets.length; i++) {
            if (bondMarkets[supportedMarkets[i]].active) {
                activeMarkets[index] = supportedMarkets[i];
                index++;
            }
        }
        
        return activeMarkets;
    }

    function getSupportedTokens() external view returns (address[] memory) {
        return supportedTokens;
    }

    function isMarketSupported(address market_) external view returns (bool) {
        return bondMarkets[market_].active;
    }

    function isTokenSupported(address token_) external view returns (bool) {
        return tokenInfo[token_].market != address(0);
    }

    function getMarketTokens(address market_) external view returns (address[] memory) {
        if (!bondMarkets[market_].active) revert BMA_MarketNotSupported();
        
        uint256 tokenCount = 0;
        
        // Count tokens for this market
        for (uint256 i = 0; i < supportedTokens.length; i++) {
            if (tokenInfo[supportedTokens[i]].market == market_) {
                tokenCount++;
            }
        }
        
        // Create array of market tokens
        address[] memory marketTokens = new address[](tokenCount);
        uint256 index = 0;
        
        for (uint256 i = 0; i < supportedTokens.length; i++) {
            if (tokenInfo[supportedTokens[i]].market == market_) {
                marketTokens[index] = supportedTokens[i];
                index++;
            }
        }
        
        return marketTokens;
    }

    function getMarketDetails(address market_) external view returns (
        string memory name,
        bool active,
        uint256 addedTimestamp,
        uint256 totalBondedValue,
        uint256 lastUpdateTimestamp
    ) {
        if (!bondMarkets[market_].active && bondMarkets[market_].addedTimestamp == 0) revert BMA_MarketNotSupported();
        
        MarketInfo memory info = bondMarkets[market_];
        return (info.name, info.active, info.addedTimestamp, info.totalBondedValue, info.lastUpdateTimestamp);
    }

    function getTokenDetails(address token_) external view returns (
        address market,
        uint256 price,
        uint256 discount,
        uint256 supply,
        uint256 liquidity,
        uint256 lastUpdateTimestamp
    ) {
        if (tokenInfo[token_].market == address(0)) revert BMA_TokenNotSupported();
        
        TokenInfo memory info = tokenInfo[token_];
        return (info.market, info.price, info.discount, info.supply, info.liquidity, info.lastUpdateTimestamp);
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function _updateTokenInfo(address token_) internal {
        address market = tokenInfo[token_].market;
        
        // Get price from bond market
        uint256 marketPrice = IBondMarket(market).getBondPrice(token_);
        uint256 marketDiscount = IBondMarket(market).getBondDiscount(token_);
        
        // Get price from bond pricer
        uint256 pricerPrice = IBondPricer(bondPricer).getCurrentPrice(token_);
        
        // Check for price deviation
        if (marketPrice > 0 && pricerPrice > 0) {
            uint256 priceDiff;
            if (marketPrice > pricerPrice) {
                priceDiff = ((marketPrice - pricerPrice) * 10000) / marketPrice;
            } else {
                priceDiff = ((pricerPrice - marketPrice) * 10000) / pricerPrice;
            }
            
            if (priceDiff > maxSlippage) revert BMA_SlippageExceeded();
        }
        
        // Update token info
        tokenInfo[token_].price = marketPrice;
        tokenInfo[token_].discount = marketDiscount;
        tokenInfo[token_].lastUpdateTimestamp = block.timestamp;
        
        // Additional market-specific data could be added here
    }

    function _removeToken(address token_) internal {
        delete tokenInfo[token_];
        
        // Remove from supportedTokens array
        for (uint256 i = 0; i < supportedTokens.length; i++) {
            if (supportedTokens[i] == token_) {
                supportedTokens[i] = supportedTokens[supportedTokens.length - 1];
                supportedTokens.pop();
                break;
            }
        }
    }
}