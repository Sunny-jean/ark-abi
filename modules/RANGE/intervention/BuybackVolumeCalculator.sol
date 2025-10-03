// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.15;

/// @title Buyback Volume Calculator
/// @notice Calculates the optimal volume for buyback operations based on market conditions
interface IBuybackVolumeCalculator {
    function calculateBuybackAmount() external view returns (uint256);
    function getMaxBuybackAmount() external view returns (uint256);
    function getMinBuybackAmount() external view returns (uint256);
    function getScalingFactor() external view returns (uint256);
}

import "@openzeppelin/contracts/access/Ownable.sol";

interface IBuybackDeviationMonitor {
    function getCurrentDeviation() external view returns (uint256);
    function getDeviationThreshold() external view returns (uint256);
}

interface IBuybackReserveChecker {
    function getAvailableReserves() external view returns (uint256);
    function getMaxReservesPercentage() external view returns (uint256);
}

contract BuybackVolumeCalculator is Ownable {
    // ============================================================================================//
    //                                        EVENTS                                                 //
    // ============================================================================================//

    event MaxBuybackAmountUpdated(uint256 oldAmount, uint256 newAmount);
    event MinBuybackAmountUpdated(uint256 oldAmount, uint256 newAmount);
    event ScalingFactorUpdated(uint256 oldFactor, uint256 newFactor);
    event DeviationMonitorUpdated(address oldMonitor, address newMonitor);
    event ReserveCheckerUpdated(address oldChecker, address newChecker);

    // ============================================================================================//
    //                                        ERRORS                                                //
    // ============================================================================================//

    error BuybackVolumeCalculator_InvalidAmount();
    error BuybackVolumeCalculator_InvalidFactor();
    error BuybackVolumeCalculator_InvalidAddress();
    error BuybackVolumeCalculator_Unauthorized();

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//
    
    // Deviation monitor
    IBuybackDeviationMonitor public deviationMonitor;
    
    // Reserve checker
    IBuybackReserveChecker public reserveChecker;
    
    // Maximum amount for a single buyback
    uint256 public maxBuybackAmount;
    
    // Minimum amount for a single buyback
    uint256 public minBuybackAmount;
    
    // Scaling factor for calculating buyback amount based on deviation (in basis points)
    // Higher scaling factor means more aggressive buybacks for the same deviation
    uint256 public scalingFactor;
    
    // Maximum scaling factor (in basis points)
    uint256 public constant MAX_SCALING_FACTOR = 10000; // 100%
    
    // Owner of the contract

    
    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(
        address _deviationMonitor,
        address _reserveChecker,
        uint256 _maxBuybackAmount,
        uint256 _minBuybackAmount,
        uint256 _scalingFactor,
        address initialOwner
    ) Ownable(initialOwner) {
        if (_deviationMonitor == address(0) || _reserveChecker == address(0)) {
            revert BuybackVolumeCalculator_InvalidAddress();
        }
        
        if (_maxBuybackAmount == 0 || _minBuybackAmount == 0 || _minBuybackAmount > _maxBuybackAmount) {
            revert BuybackVolumeCalculator_InvalidAmount();
        }
        
        if (_scalingFactor == 0 || _scalingFactor > MAX_SCALING_FACTOR) {
            revert BuybackVolumeCalculator_InvalidFactor();
        }
        
        deviationMonitor = IBuybackDeviationMonitor(_deviationMonitor);
        reserveChecker = IBuybackReserveChecker(_reserveChecker);
        maxBuybackAmount = _maxBuybackAmount;
        minBuybackAmount = _minBuybackAmount;
        scalingFactor = _scalingFactor;

    }
    
    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyOwner() override {

        _;
    }
    
    // ============================================================================================//
    //                                       FUNCTIONS                                             //
    // ============================================================================================//

    /// @notice Calculate the optimal buyback amount based on current market conditions
    /// @return The calculated buyback amount
    function calculateBuybackAmount() external view returns (uint256) {
        // Get current deviation and threshold
        uint256 currentDeviation = deviationMonitor.getCurrentDeviation();
        uint256 deviationThreshold = deviationMonitor.getDeviationThreshold();
        
        // If deviation is below threshold, return minimum amount
        if (currentDeviation < deviationThreshold) {
            return minBuybackAmount;
        }
        
        // Calculate amount based on deviation
        // Formula: min + (max - min) * (deviation - threshold) / (10000 - threshold) * scalingFactor / 10000
        uint256 excessDeviation = currentDeviation - deviationThreshold;
        uint256 maxExcessDeviation = 10000 - deviationThreshold;
        
        uint256 deviationRatio = (excessDeviation * 10000) / maxExcessDeviation;
        uint256 scaledRatio = (deviationRatio * scalingFactor) / 10000;
        
        uint256 range = maxBuybackAmount - minBuybackAmount;
        uint256 additionalAmount = (range * scaledRatio) / 10000;
        
        uint256 calculatedAmount = minBuybackAmount + additionalAmount;
        
        // Check available reserves
        uint256 availableReserves = reserveChecker.getAvailableReserves();
        uint256 maxReservesPercentage = reserveChecker.getMaxReservesPercentage();
        uint256 maxReservesAmount = (availableReserves * maxReservesPercentage) / 10000;
        
        // Cap the amount to the maximum allowed by reserves
        if (calculatedAmount > maxReservesAmount) {
            return maxReservesAmount;
        }
        
        // Cap the amount to the maximum buyback amount
        if (calculatedAmount > maxBuybackAmount) {
            return maxBuybackAmount;
        }
        
        return calculatedAmount;
    }
    
    /// @notice Get the maximum buyback amount
    /// @return The maximum buyback amount
    function getMaxBuybackAmount() external view returns (uint256) {
        return maxBuybackAmount;
    }
    
    /// @notice Get the minimum buyback amount
    /// @return The minimum buyback amount
    function getMinBuybackAmount() external view returns (uint256) {
        return minBuybackAmount;
    }
    
    /// @notice Get the scaling factor for buyback calculations
    /// @return The scaling factor in basis points
    function getScalingFactor() external view returns (uint256) {
        return scalingFactor;
    }
    
    /// @notice Set the maximum buyback amount
    /// @param _maxBuybackAmount The new maximum buyback amount
    function setMaxBuybackAmount(uint256 _maxBuybackAmount) external onlyOwner {
        if (_maxBuybackAmount == 0 || _maxBuybackAmount < minBuybackAmount) {
            revert BuybackVolumeCalculator_InvalidAmount();
        }
        
        uint256 oldAmount = maxBuybackAmount;
        maxBuybackAmount = _maxBuybackAmount;
        
        emit MaxBuybackAmountUpdated(oldAmount, _maxBuybackAmount);
    }
    
    /// @notice Set the minimum buyback amount
    /// @param _minBuybackAmount The new minimum buyback amount
    function setMinBuybackAmount(uint256 _minBuybackAmount) external onlyOwner {
        if (_minBuybackAmount == 0 || _minBuybackAmount > maxBuybackAmount) {
            revert BuybackVolumeCalculator_InvalidAmount();
        }
        
        uint256 oldAmount = minBuybackAmount;
        minBuybackAmount = _minBuybackAmount;
        
        emit MinBuybackAmountUpdated(oldAmount, _minBuybackAmount);
    }
    
    /// @notice Set the scaling factor for buyback calculations
    /// @param _scalingFactor The new scaling factor in basis points
    function setScalingFactor(uint256 _scalingFactor) external onlyOwner {
        if (_scalingFactor == 0 || _scalingFactor > MAX_SCALING_FACTOR) {
            revert BuybackVolumeCalculator_InvalidFactor();
        }
        
        uint256 oldFactor = scalingFactor;
        scalingFactor = _scalingFactor;
        
        emit ScalingFactorUpdated(oldFactor, _scalingFactor);
    }
    
    /// @notice Set the deviation monitor address
    /// @param _deviationMonitor The new deviation monitor address
    function setDeviationMonitor(address _deviationMonitor) external onlyOwner {
        if (_deviationMonitor == address(0)) {
            revert BuybackVolumeCalculator_InvalidAddress();
        }
        
        address oldMonitor = address(deviationMonitor);
        deviationMonitor = IBuybackDeviationMonitor(_deviationMonitor);
        
        emit DeviationMonitorUpdated(oldMonitor, _deviationMonitor);
    }
    
    /// @notice Set the reserve checker address
    /// @param _reserveChecker The new reserve checker address
    function setReserveChecker(address _reserveChecker) external onlyOwner {
        if (_reserveChecker == address(0)) {
            revert BuybackVolumeCalculator_InvalidAddress();
        }
        
        address oldChecker = address(reserveChecker);
        reserveChecker = IBuybackReserveChecker(_reserveChecker);
        
        emit ReserveCheckerUpdated(oldChecker, _reserveChecker);
    }
    
    /// @notice Transfer ownership of the contract
    /// @param newOwner The address of the new owner
    function transferOwnership(address newOwner) public override onlyOwner {
        super.transferOwnership(newOwner);
    }
}