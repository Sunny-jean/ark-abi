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
        return 10e18;
    }

    ///  getLastPrice.
    function getLastPrice() external view returns (uint256) {
        return 9e18;
    }

    ///  getMovingAverage.
    function getMovingAverage() public view returns (uint256) {
        return 9.5e18;
    }

    ///  getTargetPrice.
    function getTargetPrice() external view returns (uint256) {
        return 9.5e18; // set as 9.5, same sa MA
    }
} 