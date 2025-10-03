// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.15;

/// @title Buyback Rate Limiter
/// @notice Controls buyback frequency to prevent excessive operations
interface IBuybackRateLimiter {
    function checkRateLimit(uint256 amount) external view returns (bool);
    function recordBuyback(uint256 amount) external;
    function getMaxAmountPerPeriod() external view returns (uint256);
    function getPeriodDuration() external view returns (uint256);
    function getCurrentPeriodStart() external view returns (uint256);
    function getCurrentPeriodUsage() external view returns (uint256);
}

contract BuybackRateLimiter {
    // ============================================================================================//
    //                                        EVENTS                                                 //
    // ============================================================================================//

    event BuybackRecorded(uint256 amount, uint256 timestamp, uint256 periodStart, uint256 periodUsage);
    event MaxAmountPerPeriodUpdated(uint256 oldAmount, uint256 newAmount);
    event PeriodDurationUpdated(uint256 oldDuration, uint256 newDuration);

    // ============================================================================================//
    //                                        ERRORS                                                //
    // ============================================================================================//

    error BuybackRateLimiter_InvalidAmount();
    error BuybackRateLimiter_InvalidDuration();
    error BuybackRateLimiter_InvalidAddress();
    error BuybackRateLimiter_Unauthorized();
    error BuybackRateLimiter_RateLimitExceeded();

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    // Maximum amount allowed per period
    uint256 public maxAmountPerPeriod;
    
    // Duration of each period in seconds
    uint256 public periodDuration;
    
    // Start timestamp of the current period
    uint256 public currentPeriodStart;
    
    // Amount used in the current period
    uint256 public currentPeriodUsage;
    
    // Owner of the contract
    address public owner;
    
    // Authorized callers who can record buybacks
    mapping(address => bool) public authorizedCallers;
    
    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(
        uint256 _maxAmountPerPeriod,
        uint256 _periodDuration
    ) {
        if (_maxAmountPerPeriod == 0) {
            revert BuybackRateLimiter_InvalidAmount();
        }
        
        if (_periodDuration == 0) {
            revert BuybackRateLimiter_InvalidDuration();
        }
        
        maxAmountPerPeriod = _maxAmountPerPeriod;
        periodDuration = _periodDuration;
        currentPeriodStart = block.timestamp;
        owner = msg.sender;
        authorizedCallers[msg.sender] = true;
    }
    
    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert BuybackRateLimiter_Unauthorized();
        }
        _;
    }
    
    modifier onlyAuthorized() {
        if (!authorizedCallers[msg.sender]) {
            revert BuybackRateLimiter_Unauthorized();
        }
        _;
    }
    
    // ============================================================================================//
    //                                       FUNCTIONS                                             //
    // ============================================================================================//

    /// @notice Check if a buyback of the given amount would exceed the rate limit
    /// @param amount The amount to check
    /// @return Whether the buyback is allowed
    function checkRateLimit(uint256 amount) external view returns (bool) {
        // Update period if needed (view function, so no state changes)
        uint256 periodStart = currentPeriodStart;
        uint256 periodUsage = currentPeriodUsage;
        
        if (block.timestamp >= periodStart + periodDuration) {
            // New period would start
            return amount <= maxAmountPerPeriod;
        } else {
            // Still in current period
            return periodUsage + amount <= maxAmountPerPeriod;
        }
    }
    
    /// @notice Record a buyback and update rate limiting state
    /// @param amount The amount of the buyback
    function recordBuyback(uint256 amount) external onlyAuthorized {
        // Update period if needed
        _updatePeriodIfNeeded();
        
        // Check if the buyback would exceed the rate limit
        if (currentPeriodUsage + amount > maxAmountPerPeriod) {
            revert BuybackRateLimiter_RateLimitExceeded();
        }
        
        // Record the buyback
        currentPeriodUsage += amount;
        
        emit BuybackRecorded(amount, block.timestamp, currentPeriodStart, currentPeriodUsage);
    }
    
    /// @notice Get the maximum amount allowed per period
    /// @return The maximum amount
    function getMaxAmountPerPeriod() external view returns (uint256) {
        return maxAmountPerPeriod;
    }
    
    /// @notice Get the duration of each period
    /// @return The period duration in seconds
    function getPeriodDuration() external view returns (uint256) {
        return periodDuration;
    }
    
    /// @notice Get the start timestamp of the current period
    /// @return The current period start timestamp
    function getCurrentPeriodStart() external view returns (uint256) {
        return currentPeriodStart;
    }
    
    /// @notice Get the amount used in the current period
    /// @return The current period usage
    function getCurrentPeriodUsage() external view returns (uint256) {
        return currentPeriodUsage;
    }
    
    /// @notice Get the remaining amount that can be used in the current period
    /// @return The remaining amount
    function getRemainingAmount() external view returns (uint256) {
        // Update period if needed (view function, so no state changes)
        if (block.timestamp >= currentPeriodStart + periodDuration) {
            // New period would start
            return maxAmountPerPeriod;
        } else {
            // Still in current period
            return maxAmountPerPeriod - currentPeriodUsage;
        }
    }
    
    /// @notice Set the maximum amount allowed per period
    /// @param _maxAmountPerPeriod The new maximum amount
    function setMaxAmountPerPeriod(uint256 _maxAmountPerPeriod) external onlyOwner {
        if (_maxAmountPerPeriod == 0) {
            revert BuybackRateLimiter_InvalidAmount();
        }
        
        uint256 oldAmount = maxAmountPerPeriod;
        maxAmountPerPeriod = _maxAmountPerPeriod;
        
        emit MaxAmountPerPeriodUpdated(oldAmount, _maxAmountPerPeriod);
    }
    
    /// @notice Set the duration of each period
    /// @param _periodDuration The new period duration in seconds
    function setPeriodDuration(uint256 _periodDuration) external onlyOwner {
        if (_periodDuration == 0) {
            revert BuybackRateLimiter_InvalidDuration();
        }
        
        uint256 oldDuration = periodDuration;
        periodDuration = _periodDuration;
        
        // Reset the current period
        currentPeriodStart = block.timestamp;
        currentPeriodUsage = 0;
        
        emit PeriodDurationUpdated(oldDuration, _periodDuration);
    }
    
    /// @notice Add an authorized caller
    /// @param caller The address to authorize
    function addAuthorizedCaller(address caller) external onlyOwner {
        if (caller == address(0)) {
            revert BuybackRateLimiter_InvalidAddress();
        }
        
        authorizedCallers[caller] = true;
    }
    
    /// @notice Remove an authorized caller
    /// @param caller The address to remove authorization from
    function removeAuthorizedCaller(address caller) external onlyOwner {
        authorizedCallers[caller] = false;
    }
    
    /// @notice Transfer ownership of the contract
    /// @param newOwner The address of the new owner
    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) {
            revert BuybackRateLimiter_InvalidAddress();
        }
        
        owner = newOwner;
    }
    
    /// @notice Update the current period if needed
    function _updatePeriodIfNeeded() internal {
        if (block.timestamp >= currentPeriodStart + periodDuration) {
            // Start a new period
            currentPeriodStart = block.timestamp;
            currentPeriodUsage = 0;
        }
    }
}