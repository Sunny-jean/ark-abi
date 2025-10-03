// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

// --- interfaces ---
interface IOracle {
    function getPrice(address) external view returns (uint256);
}

/// @title Bond Pricer
/// @notice Calculates bond prices and discount rates
contract BondPricer {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event PriceOracleSet(address indexed token, address indexed oracle);
    event DiscountRateSet(address indexed token, uint256 rate);
    event PriceUpdated(address indexed token, uint256 price);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error BP_OnlyManager();
    error BP_ZeroAddress();
    error BP_InvalidRate(uint256 rate);
    error BP_OracleNotSet(address token);

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public manager;
    mapping(address => address) public priceOracles; // token => oracle
    mapping(address => uint256) public discountRates; // token => discount rate (in basis points)
    mapping(address => uint256) public lastPrices; // token => last price

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyManager() {
        if (msg.sender != manager) revert BP_OnlyManager();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address manager_) {
        if (manager_ == address(0)) revert BP_ZeroAddress();
        manager = manager_;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function setPriceOracle(address token_, address oracle_) external onlyManager {
        if (token_ == address(0) || oracle_ == address(0)) revert BP_ZeroAddress();
        
        priceOracles[token_] = oracle_;
        
        emit PriceOracleSet(token_, oracle_);
    }

    function setDiscountRate(address token_, uint256 rate_) external onlyManager {
        if (token_ == address(0)) revert BP_ZeroAddress();
        if (rate_ > 5000) revert BP_InvalidRate(rate_); // Max 50% discount
        
        discountRates[token_] = rate_;
        
        emit DiscountRateSet(token_, rate_);
    }

    function updatePrice(address token_) external {
        address oracle = priceOracles[token_];
        if (oracle == address(0)) revert BP_OracleNotSet(token_);
        
        uint256 price = IOracle(oracle).getPrice(token_);
        lastPrices[token_] = price;
        
        emit PriceUpdated(token_, price);
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getCurrentPrice(address token_) external view returns (uint256) {
        address oracle = priceOracles[token_];
        if (oracle == address(0)) return 0;
        
        // this would fetch the current price from the oracle

        uint256 price = lastPrices[token_];
        return price > 0 ? price : 100 * 1e18; // Default 100 USD
    }

    function getDiscountRate(address token_) external view returns (uint256) {
        return discountRates[token_];
    }

    function getDiscountedPrice(address token_) external view returns (uint256) {
        uint256 price = this.getCurrentPrice(token_);
        uint256 discount = discountRates[token_];
        
        // Apply discount (basis points)
        return price * (10000 - discount) / 10000;
    }
}