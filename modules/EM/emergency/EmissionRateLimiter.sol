// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Emission Manager interface
/// @notice interface for the emission manager contract
interface IEmissionManager {
    function setEmissionRate(uint256 rate) external;
    function getEmissionRate() external view returns (uint256);
    function getTotalEmitted() external view returns (uint256);
    function getLastEmissionBlock() external view returns (uint256);
}

/// @title Emission Rate Limiter interface
/// @notice interface for the emission rate limiter contract
interface IEmissionRateLimiter {
    function checkRateLimit(uint256 proposedRate) external view returns (bool);
    function getMaxRateChange() external view returns (uint256);
    function getAbsoluteMaxRate() external view returns (uint256);
    function getAbsoluteMinRate() external view returns (uint256);
    function getRateLimitCooldown() external view returns (uint256);
}

/// @title Emission Rate Limiter
/// @notice Controls and limits emission rate changes to prevent extreme fluctuations
contract EmissionRateLimiter {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event MaxRateChangeUpdated(uint256 oldMaxChange, uint256 newMaxChange);
    event AbsoluteMaxRateUpdated(uint256 oldMaxRate, uint256 newMaxRate);
    event AbsoluteMinRateUpdated(uint256 oldMinRate, uint256 newMinRate);
    event RateLimitCooldownUpdated(uint256 oldCooldown, uint256 newCooldown);
    event RateChangeRequested(address indexed requester, uint256 currentRate, uint256 requestedRate, bool approved);
    event EmergencyRateChangeExecuted(address indexed executor, uint256 oldRate, uint256 newRate, string reason);
    event EmergencyAuthorityAdded(address indexed authority);
    event EmergencyAuthorityRemoved(address indexed authority);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error ERL_OnlyAdmin();
    error ERL_OnlyEmergencyAuthority();
    error ERL_ZeroAddress();
    error ERL_InvalidParameter();
    error ERL_RateExceedsLimit();
    error ERL_RateBelowMinimum();
    error ERL_CooldownActive();
    error ERL_AlreadyAuthorized();
    error ERL_NotAuthorized();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct RateChangeEvent {
        address requester;
        uint256 timestamp;
        uint256 previousRate;
        uint256 requestedRate;
        uint256 actualRate;
        bool emergency;
        string reason;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public emissionManager;
    
    // Rate limits
    uint256 public maxRateChangePercentage = 20; // 20% max change per adjustment
    uint256 public absoluteMaxRate = 1000000e18; // Maximum possible emission rate
    uint256 public absoluteMinRate = 100e18;     // Minimum possible emission rate
    
    // Cooldown
    uint256 public rateLimitCooldown = 12 hours; // Minimum time between rate changes
    uint256 public lastRateChangeTimestamp;
    
    // Emergency authorities
    mapping(address => bool) public emergencyAuthorities;
    address[] public authorityList;
    
    // Rate change history
    RateChangeEvent[] public rateChangeHistory;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert ERL_OnlyAdmin();
        _;
    }

    modifier onlyEmergencyAuthority() {
        if (!emergencyAuthorities[msg.sender] && msg.sender != admin) revert ERL_OnlyEmergencyAuthority();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address emissionManager_, uint256 initialMaxRateChange_, uint256 initialCooldown_) {
        if (admin_ == address(0) || emissionManager_ == address(0)) revert ERL_ZeroAddress();
        if (initialMaxRateChange_ == 0 || initialMaxRateChange_ > 50) revert ERL_InvalidParameter();
        if (initialCooldown_ < 1 hours || initialCooldown_ > 7 days) revert ERL_InvalidParameter();
        
        admin = admin_;
        emissionManager = emissionManager_;
        maxRateChangePercentage = initialMaxRateChange_;
        rateLimitCooldown = initialCooldown_;
        
        // Add admin as emergency authority
        emergencyAuthorities[admin_] = true;
        authorityList.push(admin_);
        
        lastRateChangeTimestamp = block.timestamp;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function setMaxRateChangePercentage(uint256 maxChangePercentage_) external onlyAdmin {
        if (maxChangePercentage_ == 0 || maxChangePercentage_ > 50) revert ERL_InvalidParameter();
        
        uint256 oldMaxChange = maxRateChangePercentage;
        maxRateChangePercentage = maxChangePercentage_;
        
        emit MaxRateChangeUpdated(oldMaxChange, maxChangePercentage_);
    }

    function setAbsoluteMaxRate(uint256 maxRate_) external onlyAdmin {
        if (maxRate_ <= absoluteMinRate) revert ERL_InvalidParameter();
        
        uint256 oldMaxRate = absoluteMaxRate;
        absoluteMaxRate = maxRate_;
        
        emit AbsoluteMaxRateUpdated(oldMaxRate, maxRate_);
    }

    function setAbsoluteMinRate(uint256 minRate_) external onlyAdmin {
        if (minRate_ == 0 || minRate_ >= absoluteMaxRate) revert ERL_InvalidParameter();
        
        uint256 oldMinRate = absoluteMinRate;
        absoluteMinRate = minRate_;
        
        emit AbsoluteMinRateUpdated(oldMinRate, minRate_);
    }

    function setRateLimitCooldown(uint256 cooldown_) external onlyAdmin {
        if (cooldown_ < 1 hours || cooldown_ > 7 days) revert ERL_InvalidParameter();
        
        uint256 oldCooldown = rateLimitCooldown;
        rateLimitCooldown = cooldown_;
        
        emit RateLimitCooldownUpdated(oldCooldown, cooldown_);
    }

    function addEmergencyAuthority(address authority_) external onlyAdmin {
        if (authority_ == address(0)) revert ERL_ZeroAddress();
        if (emergencyAuthorities[authority_]) revert ERL_AlreadyAuthorized();
        
        emergencyAuthorities[authority_] = true;
        authorityList.push(authority_);
        
        emit EmergencyAuthorityAdded(authority_);
    }

    function removeEmergencyAuthority(address authority_) external onlyAdmin {
        if (authority_ == admin) revert ERL_InvalidParameter(); // Cannot remove admin
        if (!emergencyAuthorities[authority_]) revert ERL_NotAuthorized();
        
        emergencyAuthorities[authority_] = false;
        
        // Remove from authority list
        for (uint256 i = 0; i < authorityList.length; i++) {
            if (authorityList[i] == authority_) {
                authorityList[i] = authorityList[authorityList.length - 1];
                authorityList.pop();
                break;
            }
        }
        
        emit EmergencyAuthorityRemoved(authority_);
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function requestRateChange(uint256 newRate_) external returns (bool) {
        // Get current emission rate
        uint256 currentRate = IEmissionManager(emissionManager).getEmissionRate();
        
        // Check if cooldown is active
        if (block.timestamp < lastRateChangeTimestamp + rateLimitCooldown) {
            emit RateChangeRequested(msg.sender, currentRate, newRate_, false);
            revert ERL_CooldownActive();
        }
        
        // Check absolute limits
        if (newRate_ > absoluteMaxRate) {
            emit RateChangeRequested(msg.sender, currentRate, newRate_, false);
            revert ERL_RateExceedsLimit();
        }
        
        if (newRate_ < absoluteMinRate) {
            emit RateChangeRequested(msg.sender, currentRate, newRate_, false);
            revert ERL_RateBelowMinimum();
        }
        
        // Check percentage change limit
        bool withinLimit = _isWithinRateChangeLimit(currentRate, newRate_);
        
        if (!withinLimit) {
            emit RateChangeRequested(msg.sender, currentRate, newRate_, false);
            revert ERL_RateExceedsLimit();
        }
        
        // Update last rate change timestamp
        lastRateChangeTimestamp = block.timestamp;
        
        // Set new emission rate
        IEmissionManager(emissionManager).setEmissionRate(newRate_);
        
        // Record rate change event
        _recordRateChangeEvent(msg.sender, currentRate, newRate_, newRate_, false, "");
        
        emit RateChangeRequested(msg.sender, currentRate, newRate_, true);
        
        return true;
    }

    function emergencyRateChange(uint256 newRate_, string calldata reason_) external onlyEmergencyAuthority {
        // Get current emission rate
        uint256 currentRate = IEmissionManager(emissionManager).getEmissionRate();
        
        // Check absolute limits (even emergency changes must respect absolute limits)
        if (newRate_ > absoluteMaxRate) revert ERL_RateExceedsLimit();
        if (newRate_ < absoluteMinRate) revert ERL_RateBelowMinimum();
        
        // Update last rate change timestamp
        lastRateChangeTimestamp = block.timestamp;
        
        // Set new emission rate
        IEmissionManager(emissionManager).setEmissionRate(newRate_);
        
        // Record rate change event
        _recordRateChangeEvent(msg.sender, currentRate, newRate_, newRate_, true, reason_);
        
        emit EmergencyRateChangeExecuted(msg.sender, currentRate, newRate_, reason_);
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function checkRateLimit(uint256 proposedRate_) external view returns (bool) {
        // Get current emission rate
        uint256 currentRate = IEmissionManager(emissionManager).getEmissionRate();
        
        // Check if cooldown is active
        if (block.timestamp < lastRateChangeTimestamp + rateLimitCooldown) {
            return false;
        }
        
        // Check absolute limits
        if (proposedRate_ > absoluteMaxRate || proposedRate_ < absoluteMinRate) {
            return false;
        }
        
        // Check percentage change limit
        return _isWithinRateChangeLimit(currentRate, proposedRate_);
    }

    function getMaxRateChange() external view returns (uint256) {
        return maxRateChangePercentage;
    }

    function getAbsoluteMaxRate() external view returns (uint256) {
        return absoluteMaxRate;
    }

    function getAbsoluteMinRate() external view returns (uint256) {
        return absoluteMinRate;
    }

    function getRateLimitCooldown() external view returns (uint256) {
        return rateLimitCooldown;
    }

    function getTimeUntilNextAllowedChange() external view returns (uint256) {
        if (block.timestamp >= lastRateChangeTimestamp + rateLimitCooldown) {
            return 0;
        }
        
        return lastRateChangeTimestamp + rateLimitCooldown - block.timestamp;
    }

    function getRateChangeHistoryLength() external view returns (uint256) {
        return rateChangeHistory.length;
    }

    function getRateChangeDetails(uint256 index_) external view returns (
        address requester,
        uint256 timestamp,
        uint256 previousRate,
        uint256 requestedRate,
        uint256 actualRate,
        bool emergency,
        string memory reason
    ) {
        if (index_ >= rateChangeHistory.length) revert ERL_InvalidParameter();
        
        RateChangeEvent memory event_ = rateChangeHistory[index_];
        return (
            event_.requester,
            event_.timestamp,
            event_.previousRate,
            event_.requestedRate,
            event_.actualRate,
            event_.emergency,
            event_.reason
        );
    }

    function getEmergencyAuthoritiesCount() external view returns (uint256) {
        return authorityList.length;
    }

    function isEmergencyAuthority(address account_) external view returns (bool) {
        return emergencyAuthorities[account_];
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function _isWithinRateChangeLimit(uint256 currentRate_, uint256 proposedRate_) internal view returns (bool) {
        // Calculate maximum allowed change
        uint256 maxChange = (currentRate_ * maxRateChangePercentage) / 100;
        
        // Check if proposed rate is within limits
        if (proposedRate_ > currentRate_) {
            return proposedRate_ <= currentRate_ + maxChange;
        } else {
            return proposedRate_ >= currentRate_ - maxChange;
        }
    }

    function _recordRateChangeEvent(
        address requester_,
        uint256 previousRate_,
        uint256 requestedRate_,
        uint256 actualRate_,
        bool emergency_,
        string memory reason_
    ) internal {
        // Create rate change event record
        RateChangeEvent memory event_ = RateChangeEvent({
            requester: requester_,
            timestamp: block.timestamp,
            previousRate: previousRate_,
            requestedRate: requestedRate_,
            actualRate: actualRate_,
            emergency: emergency_,
            reason: reason_
        });
        
        rateChangeHistory.push(event_);
    }
}