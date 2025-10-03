// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

// --- interfaces ---
interface IOracle {
    function getPrice(address) external view returns (uint256);
}

interface ICushionWall {
    function activateCushion(bool isSell) external;
    function deactivateCushion(bool isSell) external;
    function isCushionActive(bool isSell) external view returns (bool);
}

/// @title Range Bound Stability Controller
/// @notice Controls the range-bound stability mechanism
contract RBSController {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event RangeUpdated(uint256 lowerBound, uint256 upperBound);
    event CushionActivated(bool isSell);
    event CushionDeactivated(bool isSell);
    event OracleUpdated(address oracle);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error RBS_OnlyGovernance();
    error RBS_InvalidRange();
    error RBS_ZeroAddress();
    error RBS_CushionAlreadyActive(bool isSell);
    error RBS_CushionNotActive(bool isSell);

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public governance;
    address public priceOracle;
    address public cushionWall;
    address public tokenAddress;
    
    uint256 public lowerBound;
    uint256 public upperBound;
    uint256 public cushionFactor; // percentage of range for cushion (basis points)

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyGovernance() {
        if (msg.sender != governance) revert RBS_OnlyGovernance();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(
        address governance_,
        address priceOracle_,
        address cushionWall_,
        address tokenAddress_,
        uint256 lowerBound_,
        uint256 upperBound_
    ) {
        if (governance_ == address(0) || priceOracle_ == address(0) || 
            cushionWall_ == address(0) || tokenAddress_ == address(0)) revert RBS_ZeroAddress();
        if (lowerBound_ >= upperBound_) revert RBS_InvalidRange();
        
        governance = governance_;
        priceOracle = priceOracle_;
        cushionWall = cushionWall_;
        tokenAddress = tokenAddress_;
        lowerBound = lowerBound_;
        upperBound = upperBound_;
        cushionFactor = 500; // 5% default
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function setRange(uint256 lowerBound_, uint256 upperBound_) external onlyGovernance {
        if (lowerBound_ >= upperBound_) revert RBS_InvalidRange();
        
        lowerBound = lowerBound_;
        upperBound = upperBound_;
        
        emit RangeUpdated(lowerBound_, upperBound_);
    }

    function setCushionFactor(uint256 factor_) external onlyGovernance {
        if (factor_ > 2000) revert RBS_InvalidRange(); // Max 20%
        cushionFactor = factor_;
    }

    function setOracle(address oracle_) external onlyGovernance {
        if (oracle_ == address(0)) revert RBS_ZeroAddress();
        
        priceOracle = oracle_;
        
        emit OracleUpdated(oracle_);
    }

    // ============================================================================================//
    //                                     CORE FUNCTIONS                                          //
    // ============================================================================================//

    function activateCushion(bool isSell_) external {
        if (ICushionWall(cushionWall).isCushionActive(isSell_)) 
            revert RBS_CushionAlreadyActive(isSell_);
        
        uint256 currentPrice = getCurrentPrice();
        
        // Check if price is in cushion range
        if (isSell_) {
            uint256 cushionUpperBound = upperBound - (upperBound - lowerBound) * cushionFactor / 10000;
            require(currentPrice >= cushionUpperBound && currentPrice < upperBound, "Price not in sell cushion");
        } else {
            uint256 cushionLowerBound = lowerBound + (upperBound - lowerBound) * cushionFactor / 10000;
            require(currentPrice <= cushionLowerBound && currentPrice > lowerBound, "Price not in buy cushion");
        }
        
        ICushionWall(cushionWall).activateCushion(isSell_);
        
        emit CushionActivated(isSell_);
    }

    function deactivateCushion(bool isSell_) external {
        if (!ICushionWall(cushionWall).isCushionActive(isSell_)) 
            revert RBS_CushionNotActive(isSell_);
        
        ICushionWall(cushionWall).deactivateCushion(isSell_);
        
        emit CushionDeactivated(isSell_);
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getCurrentPrice() public view returns (uint256) {
        return IOracle(priceOracle).getPrice(tokenAddress);
    }

    function getCushionBounds() external view returns (uint256 lowerCushion, uint256 upperCushion) {
        uint256 range = upperBound - lowerBound;
        lowerCushion = lowerBound + range * cushionFactor / 10000;
        upperCushion = upperBound - range * cushionFactor / 10000;
    }

    function isInRange() external view returns (bool) {
        uint256 currentPrice = getCurrentPrice();
        return currentPrice >= lowerBound && currentPrice <= upperBound;
    }
}