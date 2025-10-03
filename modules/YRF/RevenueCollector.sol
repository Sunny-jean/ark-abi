// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

// --- interfaces ---
interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
}

/// @title Revenue Collector
/// @notice Collects and tracks protocol revenue
contract RevenueCollector {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event RevenueCollected(address indexed token, uint256 amount);
    event RevenueDistributed(address indexed token, address indexed recipient, uint256 amount);
    event TokenAdded(address indexed token);
    event TokenRemoved(address indexed token);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error RC_OnlyGovernance();
    error RC_ZeroAddress();
    error RC_TokenNotSupported(address token);
    error RC_InsufficientBalance(address token, uint256 requested, uint256 available);

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public governance;
    address public buyback;
    mapping(address => bool) public supportedTokens;
    mapping(address => uint256) public collectedRevenue;
    address[] public revenueTokens;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyGovernance() {
        if (msg.sender != governance) revert RC_OnlyGovernance();
        _;
    }

    modifier onlyBuyback() {
        if (msg.sender != buyback) revert RC_OnlyGovernance();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address governance_, address buyback_) {
        if (governance_ == address(0) || buyback_ == address(0)) revert RC_ZeroAddress();
        
        governance = governance_;
        buyback = buyback_;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function addSupportedToken(address token_) external onlyGovernance {
        if (token_ == address(0)) revert RC_ZeroAddress();
        if (supportedTokens[token_]) return;
        
        supportedTokens[token_] = true;
        revenueTokens.push(token_);
        
        emit TokenAdded(token_);
    }

    function removeSupportedToken(address token_) external onlyGovernance {
        if (!supportedTokens[token_]) return;
        
        supportedTokens[token_] = false;
        
        // Remove from array
        for (uint256 i = 0; i < revenueTokens.length; i++) {
            if (revenueTokens[i] == token_) {
                revenueTokens[i] = revenueTokens[revenueTokens.length - 1];
                revenueTokens.pop();
                break;
            }
        }
        
        emit TokenRemoved(token_);
    }

    function setBuyback(address buyback_) external onlyGovernance {
        if (buyback_ == address(0)) revert RC_ZeroAddress();
        buyback = buyback_;
    }

    // ============================================================================================//
    //                                     CORE FUNCTIONS                                          //
    // ============================================================================================//

    function collectRevenue(address token_, uint256 amount_) external {
        if (!supportedTokens[token_]) revert RC_TokenNotSupported(token_);
        
        // this would transfer tokens from msg.sender
        // we'll just update the state
        collectedRevenue[token_] += amount_;
        
        emit RevenueCollected(token_, amount_);
    }

    function distributeRevenue(address token_, uint256 amount_) external onlyBuyback {
        if (!supportedTokens[token_]) revert RC_TokenNotSupported(token_);
        if (collectedRevenue[token_] < amount_) 
            revert RC_InsufficientBalance(token_, amount_, collectedRevenue[token_]);
        
        // this would transfer tokens to the buyback contract
        // we'll just update the state
        collectedRevenue[token_] -= amount_;
        
        emit RevenueDistributed(token_, buyback, amount_);
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getCollectedRevenue(address token_) external view returns (uint256) {
        return collectedRevenue[token_];
    }

    function getSupportedTokens() external view returns (address[] memory) {
        return revenueTokens;
    }

    function getTotalRevenueValue() external view returns (uint256) {
        // this would calculate the USD value of all collected revenue

        return 1000000 * 1e18; // $1M
    }
}