// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.15;

/// @title Oracle interface
/// @notice interface for price oracle
interface IOracle {
    function getPrice() external view returns (uint256);
}

/// @title Buyback Deviation Monitor
/// @notice Continuously monitors price deviation from target
interface IBuybackDeviationMonitor {
    function getCurrentDeviation() external view returns (uint256);
    function getDeviationThreshold() external view returns (uint256);
    function isDeviationSignificant() external view returns (bool);
    function getTargetPrice() external view returns (uint256);
    function getCurrentPrice() external view returns (uint256);
}

contract BuybackDeviationMonitor {
    // ============================================================================================//
    //                                        EVENTS                                                 //
    // ============================================================================================//

    event DeviationThresholdUpdated(uint256 oldThreshold, uint256 newThreshold);
    event OracleUpdated(address oldOracle, address newOracle);
    event TargetPriceUpdated(uint256 oldPrice, uint256 newPrice);
    event SignificantDeviation(uint256 currentPrice, uint256 targetPrice, uint256 deviation, uint256 timestamp);

    // ============================================================================================//
    //                                        ERRORS                                                //
    // ============================================================================================//

    error BuybackDeviationMonitor_InvalidThreshold();
    error BuybackDeviationMonitor_InvalidPrice();
    error BuybackDeviationMonitor_InvalidAddress();
    error BuybackDeviationMonitor_Unauthorized();

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    // Oracle for price data
    IOracle public oracle;
    
    // Target price (in reserve tokens per protocol token, scaled by 1e18)
    uint256 public targetPrice;
    
    // Deviation threshold (in basis points, e.g., 500 = 5%)
    uint256 public deviationThreshold;
    
    // Maximum deviation threshold (in basis points)
    uint256 public constant MAX_DEVIATION_THRESHOLD = 5000; // 50%
    
    // Owner of the contract
    address public owner;
    
    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(
        address _oracle,
        uint256 _targetPrice,
        uint256 _deviationThreshold
    ) {
        if (_oracle == address(0)) {
            revert BuybackDeviationMonitor_InvalidAddress();
        }
        
        if (_targetPrice == 0) {
            revert BuybackDeviationMonitor_InvalidPrice();
        }
        
        if (_deviationThreshold == 0 || _deviationThreshold > MAX_DEVIATION_THRESHOLD) {
            revert BuybackDeviationMonitor_InvalidThreshold();
        }
        
        oracle = IOracle(_oracle);
        targetPrice = _targetPrice;
        deviationThreshold = _deviationThreshold;
        owner = msg.sender;
    }
    
    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert BuybackDeviationMonitor_Unauthorized();
        }
        _;
    }
    
    // ============================================================================================//
    //                                       FUNCTIONS                                             //
    // ============================================================================================//

    /// @notice Get the current price deviation from target in basis points
    /// @return The current deviation in basis points
    function getCurrentDeviation() public view returns (uint256) {
        uint256 currentPrice = oracle.getPrice();
        
        // If prices are equal, deviation is 0
        if (currentPrice == targetPrice) {
            return 0;
        }
        
        // Calculate deviation based on whether current price is above or below target
        if (currentPrice > targetPrice) {
            // Current price is above target (positive deviation)
            return ((currentPrice - targetPrice) * 10000) / targetPrice;
        } else {
            // Current price is below target (negative deviation, but we return absolute value)
            return ((targetPrice - currentPrice) * 10000) / targetPrice;
        }
    }
    
    /// @notice Check if the current deviation is significant (exceeds threshold)
    /// @return Whether the deviation is significant
    function isDeviationSignificant() external view returns (bool) {
        uint256 deviation = getCurrentDeviation();
        bool isSignificant = deviation >= deviationThreshold;
        
        return isSignificant;
    }
    
    /// @notice Check and record if there is a significant deviation
    /// @return Whether a significant deviation was detected and recorded
    function checkAndRecordDeviation() external returns (bool) {
        uint256 currentPrice = oracle.getPrice();
        uint256 deviation = getCurrentDeviation();
        
        if (deviation >= deviationThreshold) {
            emit SignificantDeviation(currentPrice, targetPrice, deviation, block.timestamp);
            return true;
        }
        
        return false;
    }
    
    /// @notice Get the deviation threshold
    /// @return The deviation threshold in basis points
    function getDeviationThreshold() external view returns (uint256) {
        return deviationThreshold;
    }
    
    /// @notice Get the target price
    /// @return The target price
    function getTargetPrice() external view returns (uint256) {
        return targetPrice;
    }
    
    /// @notice Get the current price from the oracle
    /// @return The current price
    function getCurrentPrice() external view returns (uint256) {
        return oracle.getPrice();
    }
    
    /// @notice Set the deviation threshold
    /// @param _deviationThreshold The new deviation threshold in basis points
    function setDeviationThreshold(uint256 _deviationThreshold) external onlyOwner {
        if (_deviationThreshold == 0 || _deviationThreshold > MAX_DEVIATION_THRESHOLD) {
            revert BuybackDeviationMonitor_InvalidThreshold();
        }
        
        uint256 oldThreshold = deviationThreshold;
        deviationThreshold = _deviationThreshold;
        
        emit DeviationThresholdUpdated(oldThreshold, _deviationThreshold);
    }
    
    /// @notice Set the oracle address
    /// @param _oracle The new oracle address
    function setOracle(address _oracle) external onlyOwner {
        if (_oracle == address(0)) {
            revert BuybackDeviationMonitor_InvalidAddress();
        }
        
        address oldOracle = address(oracle);
        oracle = IOracle(_oracle);
        
        emit OracleUpdated(oldOracle, _oracle);
    }
    
    /// @notice Set the target price
    /// @param _targetPrice The new target price
    function setTargetPrice(uint256 _targetPrice) external onlyOwner {
        if (_targetPrice == 0) {
            revert BuybackDeviationMonitor_InvalidPrice();
        }
        
        uint256 oldPrice = targetPrice;
        targetPrice = _targetPrice;
        
        emit TargetPriceUpdated(oldPrice, _targetPrice);
    }
    
    /// @notice Transfer ownership of the contract
    /// @param newOwner The address of the new owner
    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) {
            revert BuybackDeviationMonitor_InvalidAddress();
        }
        
        owner = newOwner;
    }
}