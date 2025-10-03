// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Market Sentiment Analyzer interface
/// @notice interface for the market sentiment analyzer contract
interface IMarketSentimentAnalyzer {
    function getCurrentMarketSentiment() external view returns (int256);
    function getMarketVolatility() external view returns (uint256);
    function getTokenSentiment(address token) external view returns (int256);
}

/// @title Premium Calculator interface
/// @notice interface for the premium calculator contract
interface IPremiumCalculator {
    function calculatePremium(address token_, uint256 amount_) external returns (uint256);
    function getBasePremium(address token) external view returns (uint256);
    function getMaxPremium(address token) external view returns (uint256);
    function getMinPremium(address token) external view returns (uint256);
}

/// @title Premium Calculator
/// @notice Calculates premium rates for token emissions based on market conditions
contract PremiumCalculator {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event TokenConfigured(address indexed token, uint256 basePremium, uint256 minPremium, uint256 maxPremium);
    event PremiumParametersUpdated(address indexed token, uint256 volatilityFactor, uint256 sentimentFactor);
    event MarketSentimentAnalyzerUpdated(address indexed oldAnalyzer, address indexed newAnalyzer);
    event PremiumCalculated(address indexed token, uint256 amount, uint256 premium);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error PC_OnlyAdmin();
    error PC_ZeroAddress();
    error PC_InvalidPremium();
    error PC_InvalidAmount();
    error PC_TokenNotConfigured();
    error PC_InvalidParameter();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct TokenConfig {
        uint256 basePremium; // basis points
        uint256 minPremium; // basis points
        uint256 maxPremium; // basis points
        uint256 volatilityFactor; // how much volatility affects premium (0-100)
        uint256 sentimentFactor; // how much sentiment affects premium (0-100)
        bool configured;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public marketSentimentAnalyzer;
    
    mapping(address => TokenConfig) public tokenConfigs; // token => config
    address[] public configuredTokens; // List of all configured tokens
    
    uint256 public constant BASIS_POINTS = 10000; // 100%

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert PC_OnlyAdmin();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address marketSentimentAnalyzer_) {
        if (admin_ == address(0) || marketSentimentAnalyzer_ == address(0)) revert PC_ZeroAddress();
        
        admin = admin_;
        marketSentimentAnalyzer = marketSentimentAnalyzer_;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function configureToken(
        address token_,
        uint256 basePremium_,
        uint256 minPremium_,
        uint256 maxPremium_,
        uint256 volatilityFactor_,
        uint256 sentimentFactor_
    ) external onlyAdmin {
        if (token_ == address(0)) revert PC_ZeroAddress();
        if (basePremium_ == 0 || basePremium_ > 5000) revert PC_InvalidPremium(); // Max 50%
        if (minPremium_ > basePremium_) revert PC_InvalidPremium();
        if (maxPremium_ < basePremium_ || maxPremium_ > 8000) revert PC_InvalidPremium(); // Max 80%
        if (volatilityFactor_ > 100 || sentimentFactor_ > 100) revert PC_InvalidParameter();
        
        // Add token to configured tokens if it's not already configured
        if (!tokenConfigs[token_].configured) {
            configuredTokens.push(token_);
        }
        
        tokenConfigs[token_] = TokenConfig({
            basePremium: basePremium_,
            minPremium: minPremium_,
            maxPremium: maxPremium_,
            volatilityFactor: volatilityFactor_,
            sentimentFactor: sentimentFactor_,
            configured: true
        });
        
        emit TokenConfigured(token_, basePremium_, minPremium_, maxPremium_);
        emit PremiumParametersUpdated(token_, volatilityFactor_, sentimentFactor_);
    }

    function updatePremiumParameters(
        address token_,
        uint256 volatilityFactor_,
        uint256 sentimentFactor_
    ) external onlyAdmin {
        if (token_ == address(0)) revert PC_ZeroAddress();
        if (!tokenConfigs[token_].configured) revert PC_TokenNotConfigured();
        if (volatilityFactor_ > 100 || sentimentFactor_ > 100) revert PC_InvalidParameter();
        
        tokenConfigs[token_].volatilityFactor = volatilityFactor_;
        tokenConfigs[token_].sentimentFactor = sentimentFactor_;
        
        emit PremiumParametersUpdated(token_, volatilityFactor_, sentimentFactor_);
    }

    function updatePremiumRates(
        address token_,
        uint256 basePremium_,
        uint256 minPremium_,
        uint256 maxPremium_
    ) external onlyAdmin {
        if (token_ == address(0)) revert PC_ZeroAddress();
        if (!tokenConfigs[token_].configured) revert PC_TokenNotConfigured();
        if (basePremium_ == 0 || basePremium_ > 5000) revert PC_InvalidPremium(); // Max 50%
        if (minPremium_ > basePremium_) revert PC_InvalidPremium();
        if (maxPremium_ < basePremium_ || maxPremium_ > 8000) revert PC_InvalidPremium(); // Max 80%
        
        tokenConfigs[token_].basePremium = basePremium_;
        tokenConfigs[token_].minPremium = minPremium_;
        tokenConfigs[token_].maxPremium = maxPremium_;
        
        emit TokenConfigured(token_, basePremium_, minPremium_, maxPremium_);
    }

    function setMarketSentimentAnalyzer(address analyzer_) external onlyAdmin {
        if (analyzer_ == address(0)) revert PC_ZeroAddress();
        
        address oldAnalyzer = marketSentimentAnalyzer;
        marketSentimentAnalyzer = analyzer_;
        
        emit MarketSentimentAnalyzerUpdated(oldAnalyzer, analyzer_);
    }

    function removeToken(address token_) external onlyAdmin {
        if (!tokenConfigs[token_].configured) revert PC_TokenNotConfigured();
        
        // Remove token from configured tokens array
        for (uint256 i = 0; i < configuredTokens.length; i++) {
            if (configuredTokens[i] == token_) {
                configuredTokens[i] = configuredTokens[configuredTokens.length - 1];
                configuredTokens.pop();
                break;
            }
        }
        
        delete tokenConfigs[token_];
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function calculatePremium(address token_, uint256 amount_) external returns (uint256) {
        if (amount_ == 0) revert PC_InvalidAmount();
        if (!tokenConfigs[token_].configured) revert PC_TokenNotConfigured();
        
        TokenConfig memory config = tokenConfigs[token_];
        
        // Get market sentiment and volatility
        int256 marketSentiment = IMarketSentimentAnalyzer(marketSentimentAnalyzer).getCurrentMarketSentiment();
        uint256 marketVolatility = IMarketSentimentAnalyzer(marketSentimentAnalyzer).getMarketVolatility();
        int256 tokenSentiment = IMarketSentimentAnalyzer(marketSentimentAnalyzer).getTokenSentiment(token_);
        
        // Start with base premium
        uint256 premium = config.basePremium;
        
        // Adjust for market sentiment (positive sentiment = lower premium)
        if (marketSentiment > 0) {
            uint256 sentimentAdjustment = uint256(marketSentiment) * config.sentimentFactor / 100;
            if (premium > sentimentAdjustment) {
                premium -= sentimentAdjustment;
            } else {
                premium = config.minPremium;
            }
        } else if (marketSentiment < 0) {
            uint256 sentimentAdjustment = uint256(-marketSentiment) * config.sentimentFactor / 100;
            premium += sentimentAdjustment;
        }
        
        // Adjust for token-specific sentiment
        if (tokenSentiment > 0) {
            uint256 tokenAdjustment = uint256(tokenSentiment) * config.sentimentFactor / 200; // Less impact than market
            if (premium > tokenAdjustment) {
                premium -= tokenAdjustment;
            } else {
                premium = config.minPremium;
            }
        } else if (tokenSentiment < 0) {
            uint256 tokenAdjustment = uint256(-tokenSentiment) * config.sentimentFactor / 200;
            premium += tokenAdjustment;
        }
        
        // Adjust for volatility (higher volatility = higher premium)
        premium += marketVolatility * config.volatilityFactor / 100;
        
        // Ensure premium is within bounds
        if (premium < config.minPremium) {
            premium = config.minPremium;
        } else if (premium > config.maxPremium) {
            premium = config.maxPremium;
        }
        
        // Calculate premium amount
        uint256 premiumAmount = amount_ * premium / BASIS_POINTS;
        
        emit PremiumCalculated(token_, amount_, premiumAmount);
        
        return premiumAmount;
    }

    function getBasePremium(address token_) external view returns (uint256) {
        if (!tokenConfigs[token_].configured) revert PC_TokenNotConfigured();
        return tokenConfigs[token_].basePremium;
    }

    function getMaxPremium(address token_) external view returns (uint256) {
        if (!tokenConfigs[token_].configured) revert PC_TokenNotConfigured();
        return tokenConfigs[token_].maxPremium;
    }

    function getMinPremium(address token_) external view returns (uint256) {
        if (!tokenConfigs[token_].configured) revert PC_TokenNotConfigured();
        return tokenConfigs[token_].minPremium;
    }

    function isTokenConfigured(address token_) external view returns (bool) {
        return tokenConfigs[token_].configured;
    }

    function getConfiguredTokenCount() external view returns (uint256) {
        return configuredTokens.length;
    }
}