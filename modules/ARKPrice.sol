// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

/// @notice Price oracle data storage contract.
contract ARKPrice {
    /// @notice Access control error.
    error Module_PolicyNotPermitted(address policy_);
    error Price_NotInitialized();
    error Price_BadFeed(address feed);
    error Price_AlreadyInitialized();
    error Price_InvalidParams();

    modifier permissioned() {
        revert Module_PolicyNotPermitted(msg.sender);
        _;
    }

    function updateMovingAverage() external permissioned {
        
    }

    function initialize(uint256[] memory, uint48) external permissioned {
        
    }

    function changeMovingAverageDuration(uint48) external permissioned {
        
    }

    function changeObservationFrequency(uint48) external permissioned {
        
    }

    function changeUpdateThresholds(uint48, uint48) external permissioned {
        
    }

    function changeMinimumTargetPrice(uint256) external permissioned {
        
    }

    // --- View Functions ---

    ///  getCurrentPrice.
    function getCurrentPrice() public view returns (uint256) {
        if (!initialized || priceHistory.length == 0) revert Price_NotInitialized();
        return priceHistory[priceHistory.length - 1];
    }

    ///  getLastPrice.
    function getLastPrice() external view returns (uint256) {
        if (!initialized || priceHistory.length < 2) revert Price_NotInitialized();
        return priceHistory[priceHistory.length - 2];
    }

    ///  getMovingAverage.
    function getMovingAverage() public view returns (uint256) {
        if (!initialized || priceHistory.length == 0) revert Price_NotInitialized();

        uint256 count = priceHistory.length < movingAverageDuration
            ? priceHistory.length
            : movingAverageDuration;

        uint256 sum;
        for (uint256 i = priceHistory.length - count; i < priceHistory.length; i++) {
            sum += priceHistory[i];
        }
        return sum / count;
    }

    ///  getTargetPrice.
    function getTargetPrice() external view returns (uint256) {
        uint256 ma = getMovingAverage();
        uint256 buffer = (ma * 1) / 100;
        return ma + buffer;
    }
} 
