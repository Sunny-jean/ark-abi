// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

// --- interfaces ---
interface IOracle {
    function getPrice(address token) external view returns (uint256);
}

interface IMarketSentimentAnalyzer {
    function getCurrentMarketSentiment() external view returns (int256);
    function getMarketVolatility() external view returns (uint256);
}

/// @title Dynamic Bond Pricing Model interface
/// @notice interface for the dynamic bond pricing model contract
interface IDynamicBondPricingModel {
    function calculateBondPrice(address token, uint256 amount) external view returns (uint256);
    function calculateDiscount(address token, uint256 marketPrice) external view returns (uint256);
    function getBaseDiscount(address token) external view returns (uint256);
    function getMaxDiscount(address token) external view returns (uint256);
    function getMinDiscount(address token) external view returns (uint256);
}

/// @title Dynamic Bond Pricing Model
/// @notice Calculates bond prices dynamically based on market conditions and token parameters
contract DynamicBondPricingModel {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event TokenConfigured(address indexed token, uint256 baseDiscount, uint256 minDiscount, uint256 maxDiscount);
    event OracleUpdated(address indexed token, address indexed oracle);
    event PricingParametersUpdated(address indexed token, uint256 volatilityFactor, uint256 demandFactor);
    event MarketSentimentAnalyzerUpdated(address indexed oldAnalyzer, address indexed newAnalyzer);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error DBPM_OnlyAdmin();
    error DBPM_ZeroAddress();
    error DBPM_InvalidDiscount();
    error DBPM_InvalidAmount();
    error DBPM_TokenNotConfigured();
    error DBPM_OracleNotSet();
    error DBPM_InvalidParameter();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct TokenConfig {
        uint256 baseDiscount; // basis points
        uint256 minDiscount; // basis points
        uint256 maxDiscount; // basis points
        uint256 volatilityFactor; // how much volatility affects pricing (0-100)
        uint256 demandFactor; // how much demand affects pricing (0-100)
        address oracle;
        bool configured;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public marketSentimentAnalyzer;
    
    mapping(address => TokenConfig) public tokenConfigs; // token => config
    
    uint256 public constant BASIS_POINTS = 10000; // 100%

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert DBPM_OnlyAdmin();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address marketSentimentAnalyzer_) {
        if (admin_ == address(0) || marketSentimentAnalyzer_ == address(0)) revert DBPM_ZeroAddress();
        
        admin = admin_;
        marketSentimentAnalyzer = marketSentimentAnalyzer_;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function configureToken(
        address token_,
        uint256 baseDiscount_,
        uint256 minDiscount_,
        uint256 maxDiscount_,
        uint256 volatilityFactor_,
        uint256 demandFactor_,
        address oracle_
    ) external onlyAdmin {
        if (token_ == address(0) || oracle_ == address(0)) revert DBPM_ZeroAddress();
        if (baseDiscount_ == 0 || baseDiscount_ > 5000) revert DBPM_InvalidDiscount(); // Max 50%
        if (minDiscount_ > baseDiscount_) revert DBPM_InvalidDiscount();
        if (maxDiscount_ < baseDiscount_ || maxDiscount_ > 8000) revert DBPM_InvalidDiscount(); // Max 80%
        if (volatilityFactor_ > 100 || demandFactor_ > 100) revert DBPM_InvalidParameter();
        
        tokenConfigs[token_] = TokenConfig({
            baseDiscount: baseDiscount_,
            minDiscount: minDiscount_,
            maxDiscount: maxDiscount_,
            volatilityFactor: volatilityFactor_,
            demandFactor: demandFactor_,
            oracle: oracle_,
            configured: true
        });
        
        emit TokenConfigured(token_, baseDiscount_, minDiscount_, maxDiscount_);
        emit OracleUpdated(token_, oracle_);
        emit PricingParametersUpdated(token_, volatilityFactor_, demandFactor_);
    }

    function updateOracle(address token_, address oracle_) external onlyAdmin {
        if (token_ == address(0) || oracle_ == address(0)) revert DBPM_ZeroAddress();
        if (!tokenConfigs[token_].configured) revert DBPM_TokenNotConfigured();
        
        tokenConfigs[token_].oracle = oracle_;
        
        emit OracleUpdated(token_, oracle_);
    }

    function updatePricingParameters(
        address token_,
        uint256 volatilityFactor_,
        uint256 demandFactor_
    ) external onlyAdmin {
        if (token_ == address(0)) revert DBPM_ZeroAddress();
        if (!tokenConfigs[token_].configured) revert DBPM_TokenNotConfigured();
        if (volatilityFactor_ > 100 || demandFactor_ > 100) revert DBPM_InvalidParameter();
        
        tokenConfigs[token_].volatilityFactor = volatilityFactor_;
        tokenConfigs[token_].demandFactor = demandFactor_;
        
        emit PricingParametersUpdated(token_, volatilityFactor_, demandFactor_);
    }

    function updateDiscountParameters(
        address token_,
        uint256 baseDiscount_,
        uint256 minDiscount_,
        uint256 maxDiscount_
    ) external onlyAdmin {
        if (token_ == address(0)) revert DBPM_ZeroAddress();
        if (!tokenConfigs[token_].configured) revert DBPM_TokenNotConfigured();
        if (baseDiscount_ == 0 || baseDiscount_ > 5000) revert DBPM_InvalidDiscount(); // Max 50%
        if (minDiscount_ > baseDiscount_) revert DBPM_InvalidDiscount();
        if (maxDiscount_ < baseDiscount_ || maxDiscount_ > 8000) revert DBPM_InvalidDiscount(); // Max 80%
        
        tokenConfigs[token_].baseDiscount = baseDiscount_;
        tokenConfigs[token_].minDiscount = minDiscount_;
        tokenConfigs[token_].maxDiscount = maxDiscount_;
        
        emit TokenConfigured(token_, baseDiscount_, minDiscount_, maxDiscount_);
    }

    function setMarketSentimentAnalyzer(address analyzer_) external onlyAdmin {
        if (analyzer_ == address(0)) revert DBPM_ZeroAddress();
        
        address oldAnalyzer = marketSentimentAnalyzer;
        marketSentimentAnalyzer = analyzer_;
        
        emit MarketSentimentAnalyzerUpdated(oldAnalyzer, analyzer_);
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function calculateBondPrice(address token_, uint256 amount_) external view returns (uint256) {
        if (amount_ == 0) revert DBPM_InvalidAmount();
        if (!tokenConfigs[token_].configured) revert DBPM_TokenNotConfigured();
        
        TokenConfig memory config = tokenConfigs[token_];
        
        // Get market price from oracle
        if (config.oracle == address(0)) revert DBPM_OracleNotSet();
        uint256 marketPrice = IOracle(config.oracle).getPrice(token_);
        
        // Calculate discount
        uint256 discount = calculateDiscount(token_, marketPrice);
        
        // Apply discount to market price
        uint256 discountedPrice = marketPrice * (BASIS_POINTS - discount) / BASIS_POINTS;
        
        // Calculate total price
        return amount_ * discountedPrice / 1e18;
    }

    function calculateDiscount(address token_, uint256 marketPrice_) public view returns (uint256) {
        if (!tokenConfigs[token_].configured) revert DBPM_TokenNotConfigured();
        
        TokenConfig memory config = tokenConfigs[token_];
        
        // Get market sentiment and volatility
        int256 marketSentiment = IMarketSentimentAnalyzer(marketSentimentAnalyzer).getCurrentMarketSentiment();
        uint256 marketVolatility = IMarketSentimentAnalyzer(marketSentimentAnalyzer).getMarketVolatility();
        
        // Start with base discount
        uint256 discount = config.baseDiscount;
        
        // Adjust for market sentiment (positive sentiment = lower discount)
        if (marketSentiment > 0) {
            uint256 sentimentAdjustment = uint256(marketSentiment) * config.demandFactor / 100;
            if (discount > sentimentAdjustment) {
                discount -= sentimentAdjustment;
            } else {
                discount = config.minDiscount;
            }
        } else if (marketSentiment < 0) {
            uint256 sentimentAdjustment = uint256(-marketSentiment) * config.demandFactor / 100;
            discount += sentimentAdjustment;
        }
        
        // Adjust for volatility (higher volatility = higher discount)
        discount += marketVolatility * config.volatilityFactor / 100;
        
        // Ensure discount is within bounds
        if (discount < config.minDiscount) {
            discount = config.minDiscount;
        } else if (discount > config.maxDiscount) {
            discount = config.maxDiscount;
        }
        
        return discount;
    }

    function getBaseDiscount(address token_) external view returns (uint256) {
        if (!tokenConfigs[token_].configured) revert DBPM_TokenNotConfigured();
        return tokenConfigs[token_].baseDiscount;
    }

    function getMaxDiscount(address token_) external view returns (uint256) {
        if (!tokenConfigs[token_].configured) revert DBPM_TokenNotConfigured();
        return tokenConfigs[token_].maxDiscount;
    }

    function getMinDiscount(address token_) external view returns (uint256) {
        if (!tokenConfigs[token_].configured) revert DBPM_TokenNotConfigured();
        return tokenConfigs[token_].minDiscount;
    }

    function isTokenConfigured(address token_) external view returns (bool) {
        return tokenConfigs[token_].configured;
    }
}