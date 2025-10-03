// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Pricing Strategy interface
/// @notice interface for pricing strategy implementations
interface IPricingStrategy {
    function calculatePrice(address token, uint256 amount) external view returns (uint256);
    function getStrategyType() external view returns (bytes32);
    function getStrategyName() external view returns (string memory);
    function getStrategyVersion() external view returns (uint256);
}

/// @title Pricing Strategy Registry interface
/// @notice interface for the pricing strategy registry contract
interface IPricingStrategyRegistry {
    function getActiveStrategy(address token) external view returns (address);
    function getAllStrategies(address token) external view returns (address[] memory);
    function getStrategyCount(address token) external view returns (uint256);
    function isStrategyRegistered(address strategy) external view returns (bool);
}

/// @title Pricing Strategy Registry
/// @notice Registry for bond pricing strategies with version control and token-specific assignments
contract PricingStrategyRegistry {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event StrategyRegistered(address indexed strategy, bytes32 indexed strategyType, string strategyName, uint256 version);
    event StrategyDeregistered(address indexed strategy);
    event StrategyAssignedToToken(address indexed token, address indexed strategy);
    event StrategyRemovedFromToken(address indexed token, address indexed strategy);
    event ActiveStrategyChanged(address indexed token, address indexed oldStrategy, address indexed newStrategy);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error PSR_OnlyAdmin();
    error PSR_ZeroAddress();
    error PSR_StrategyNotRegistered();
    error PSR_StrategyAlreadyRegistered();
    error PSR_StrategyNotAssignedToToken();
    error PSR_StrategyAlreadyAssignedToToken();
    error PSR_NoStrategiesForToken();
    error PSR_InvalidStrategyType();
    error PSR_CannotRemoveActiveStrategy();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct StrategyInfo {
        bytes32 strategyType;
        string strategyName;
        uint256 version;
        bool registered;
    }

    struct TokenStrategies {
        address activeStrategy;
        address[] strategies;
        mapping(address => bool) isAssigned;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    
    // Strategy registry
    mapping(address => StrategyInfo) public strategies; // strategy address => info
    address[] public registeredStrategies; // List of all registered strategies
    
    // Token-specific strategies
    mapping(address => TokenStrategies) public tokenStrategies; // token => strategies
    address[] public supportedTokens; // List of all tokens with assigned strategies

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert PSR_OnlyAdmin();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_) {
        if (admin_ == address(0)) revert PSR_ZeroAddress();
        admin = admin_;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function registerStrategy(address strategy_) external onlyAdmin {
        if (strategy_ == address(0)) revert PSR_ZeroAddress();
        if (strategies[strategy_].registered) revert PSR_StrategyAlreadyRegistered();
        
        // Get strategy information
        bytes32 strategyType = IPricingStrategy(strategy_).getStrategyType();
        string memory strategyName = IPricingStrategy(strategy_).getStrategyName();
        uint256 version = IPricingStrategy(strategy_).getStrategyVersion();
        
        if (strategyType == bytes32(0)) revert PSR_InvalidStrategyType();
        
        // Register strategy
        strategies[strategy_] = StrategyInfo({
            strategyType: strategyType,
            strategyName: strategyName,
            version: version,
            registered: true
        });
        
        registeredStrategies.push(strategy_);
        
        emit StrategyRegistered(strategy_, strategyType, strategyName, version);
    }

    function deregisterStrategy(address strategy_) external onlyAdmin {
        if (!strategies[strategy_].registered) revert PSR_StrategyNotRegistered();
        
        // Check if strategy is active for any token
        for (uint256 i = 0; i < supportedTokens.length; i++) {
            address token = supportedTokens[i];
            if (tokenStrategies[token].activeStrategy == strategy_) {
                revert PSR_CannotRemoveActiveStrategy();
            }
        }
        
        // Remove strategy from all tokens it's assigned to
        for (uint256 i = 0; i < supportedTokens.length; i++) {
            address token = supportedTokens[i];
            if (tokenStrategies[token].isAssigned[strategy_]) {
                _removeStrategyFromToken(token, strategy_);
            }
        }
        
        // Remove from registered strategies array
        for (uint256 i = 0; i < registeredStrategies.length; i++) {
            if (registeredStrategies[i] == strategy_) {
                registeredStrategies[i] = registeredStrategies[registeredStrategies.length - 1];
                registeredStrategies.pop();
                break;
            }
        }
        
        delete strategies[strategy_];
        
        emit StrategyDeregistered(strategy_);
    }

    function assignStrategyToToken(address token_, address strategy_) external onlyAdmin {
        if (token_ == address(0)) revert PSR_ZeroAddress();
        if (!strategies[strategy_].registered) revert PSR_StrategyNotRegistered();
        if (tokenStrategies[token_].isAssigned[strategy_]) revert PSR_StrategyAlreadyAssignedToToken();
        
        // Add token to supported tokens if it's the first strategy
        if (tokenStrategies[token_].strategies.length == 0) {
            supportedTokens.push(token_);
        }
        
        // Assign strategy to token
        tokenStrategies[token_].strategies.push(strategy_);
        tokenStrategies[token_].isAssigned[strategy_] = true;
        
        // If this is the first strategy, make it active
        if (tokenStrategies[token_].activeStrategy == address(0)) {
            tokenStrategies[token_].activeStrategy = strategy_;
            emit ActiveStrategyChanged(token_, address(0), strategy_);
        }
        
        emit StrategyAssignedToToken(token_, strategy_);
    }

    function removeStrategyFromToken(address token_, address strategy_) external onlyAdmin {
        if (!tokenStrategies[token_].isAssigned[strategy_]) revert PSR_StrategyNotAssignedToToken();
        if (tokenStrategies[token_].activeStrategy == strategy_) revert PSR_CannotRemoveActiveStrategy();
        
        _removeStrategyFromToken(token_, strategy_);
    }

    function setActiveStrategy(address token_, address strategy_) external onlyAdmin {
        if (!tokenStrategies[token_].isAssigned[strategy_]) revert PSR_StrategyNotAssignedToToken();
        
        address oldStrategy = tokenStrategies[token_].activeStrategy;
        tokenStrategies[token_].activeStrategy = strategy_;
        
        emit ActiveStrategyChanged(token_, oldStrategy, strategy_);
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getActiveStrategy(address token_) external view returns (address) {
        return tokenStrategies[token_].activeStrategy;
    }

    function getAllStrategies(address token_) external view returns (address[] memory) {
        return tokenStrategies[token_].strategies;
    }

    function getStrategyCount(address token_) external view returns (uint256) {
        return tokenStrategies[token_].strategies.length;
    }

    function isStrategyRegistered(address strategy_) external view returns (bool) {
        return strategies[strategy_].registered;
    }

    function isStrategyAssignedToToken(address token_, address strategy_) external view returns (bool) {
        return tokenStrategies[token_].isAssigned[strategy_];
    }

    function getRegisteredStrategyCount() external view returns (uint256) {
        return registeredStrategies.length;
    }

    function getSupportedTokenCount() external view returns (uint256) {
        return supportedTokens.length;
    }

    function getStrategyInfo(address strategy_) external view returns (bytes32, string memory, uint256) {
        if (!strategies[strategy_].registered) revert PSR_StrategyNotRegistered();
        StrategyInfo memory info = strategies[strategy_];
        return (info.strategyType, info.strategyName, info.version);
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function _removeStrategyFromToken(address token_, address strategy_) internal {
        // Remove strategy from token's strategies array
        address[] storage tokenStrategyList = tokenStrategies[token_].strategies;
        for (uint256 i = 0; i < tokenStrategyList.length; i++) {
            if (tokenStrategyList[i] == strategy_) {
                tokenStrategyList[i] = tokenStrategyList[tokenStrategyList.length - 1];
                tokenStrategyList.pop();
                break;
            }
        }
        
        // Remove assignment
        tokenStrategies[token_].isAssigned[strategy_] = false;
        
        // If token has no more strategies, remove from supported tokens
        if (tokenStrategyList.length == 0) {
            for (uint256 i = 0; i < supportedTokens.length; i++) {
                if (supportedTokens[i] == token_) {
                    supportedTokens[i] = supportedTokens[supportedTokens.length - 1];
                    supportedTokens.pop();
                    break;
                }
            }
        }
        
        emit StrategyRemovedFromToken(token_, strategy_);
    }
}