// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.15;

/// @title Buyback Trigger Evaluator
/// @notice Evaluates price deviation and time conditions to trigger buybacks
interface IBuybackTriggerEvaluator {
    function shouldTriggerBuyback() external view returns (bool);
    function getPriceDeviation() external view returns (uint256);
    function getDeviationThreshold() external view returns (uint256);
    function getMinTimeBetweenTriggers() external view returns (uint256);
    function getLastTriggerTimestamp() external view returns (uint256);
}

import "@openzeppelin/contracts/access/Ownable.sol";

interface IOracle {
    function getPrice() external view returns (uint256);
}

interface IBuybackDeviationMonitor {
    function getCurrentDeviation() external view returns (uint256);
    function isDeviationSignificant() external view returns (bool);
}

contract BuybackTriggerEvaluator is Ownable {
    // ============================================================================================//
    //                                        EVENTS                                                 //
    // ============================================================================================//

    event BuybackTriggered(uint256 priceDeviation, uint256 timestamp);
    event DeviationThresholdUpdated(uint256 oldThreshold, uint256 newThreshold);
    event MinTimeBetweenTriggersUpdated(uint256 oldTime, uint256 newTime);
    event OracleUpdated(address oldOracle, address newOracle);
    event DeviationMonitorUpdated(address oldMonitor, address newMonitor);

    // ============================================================================================//
    //                                        ERRORS                                                //
    // ============================================================================================//

    error BuybackTriggerEvaluator_InvalidThreshold();
    error BuybackTriggerEvaluator_InvalidTime();
    error BuybackTriggerEvaluator_InvalidAddress();
    error BuybackTriggerEvaluator_Unauthorized();

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//
    
    // Oracle for price data
    IOracle public oracle;
    
    // Deviation monitor
    IBuybackDeviationMonitor public deviationMonitor;
    
    // Threshold for price deviation to trigger buyback (in basis points, e.g., 500 = 5%)
    uint256 public deviationThreshold;
    
    // Minimum time between triggers (in seconds)
    uint256 public minTimeBetweenTriggers;
    
    // Last trigger timestamp
    uint256 public lastTriggerTimestamp;
    
    // Owner of the contract

    
    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(
        address initialOwner,
        address _oracle,
        address _deviationMonitor,
        uint256 _deviationThreshold,
        uint256 _minTimeBetweenTriggers
    ) Ownable(initialOwner) {
        if (_oracle == address(0) || _deviationMonitor == address(0)) {
            revert BuybackTriggerEvaluator_InvalidAddress();
        }
        
        if (_deviationThreshold == 0) {
            revert BuybackTriggerEvaluator_InvalidThreshold();
        }
        
        oracle = IOracle(_oracle);
        deviationMonitor = IBuybackDeviationMonitor(_deviationMonitor);
        deviationThreshold = _deviationThreshold;
        minTimeBetweenTriggers = _minTimeBetweenTriggers;

    }
    
    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyOwner() override {
        if (msg.sender != owner()) {
            revert BuybackTriggerEvaluator_Unauthorized();
        }
        _;
    }
    
    // ============================================================================================//
    //                                       FUNCTIONS                                             //
    // ============================================================================================//

    /// @notice Determine if a buyback should be triggered based on price deviation and time conditions
    /// @return Whether a buyback should be triggered
    function shouldTriggerBuyback() external view returns (bool) {
        // Check time condition
        if (block.timestamp < lastTriggerTimestamp + minTimeBetweenTriggers) {
            return false;
        }
        
        // Check deviation condition
        uint256 currentDeviation = deviationMonitor.getCurrentDeviation();
        bool isSignificant = deviationMonitor.isDeviationSignificant();
        
        return isSignificant && currentDeviation >= deviationThreshold;
    }
    
    /// @notice Record that a buyback has been triggered
    /// @return Whether the trigger was recorded successfully
    function recordTrigger() external returns (bool) {
        uint256 currentDeviation = deviationMonitor.getCurrentDeviation();
        lastTriggerTimestamp = block.timestamp;
        
        emit BuybackTriggered(currentDeviation, block.timestamp);
        
        return true;
    }
    
    /// @notice Get the current price deviation
    /// @return The current price deviation in basis points
    function getPriceDeviation() external view returns (uint256) {
        return deviationMonitor.getCurrentDeviation();
    }
    
    /// @notice Get the deviation threshold for triggering buybacks
    /// @return The deviation threshold in basis points
    function getDeviationThreshold() external view returns (uint256) {
        return deviationThreshold;
    }
    
    /// @notice Get the minimum time between triggers
    /// @return The minimum time between triggers in seconds
    function getMinTimeBetweenTriggers() external view returns (uint256) {
        return minTimeBetweenTriggers;
    }
    
    /// @notice Get the timestamp of the last trigger
    /// @return The timestamp of the last trigger
    function getLastTriggerTimestamp() external view returns (uint256) {
        return lastTriggerTimestamp;
    }
    
    /// @notice Set the deviation threshold for triggering buybacks
    /// @param _deviationThreshold The new deviation threshold in basis points
    function setDeviationThreshold(uint256 _deviationThreshold) external onlyOwner {
        if (_deviationThreshold == 0) {
            revert BuybackTriggerEvaluator_InvalidThreshold();
        }
        
        uint256 oldThreshold = deviationThreshold;
        deviationThreshold = _deviationThreshold;
        
        emit DeviationThresholdUpdated(oldThreshold, _deviationThreshold);
    }
    
    /// @notice Set the minimum time between triggers
    /// @param _minTimeBetweenTriggers The new minimum time between triggers in seconds
    function setMinTimeBetweenTriggers(uint256 _minTimeBetweenTriggers) external onlyOwner {
        uint256 oldTime = minTimeBetweenTriggers;
        minTimeBetweenTriggers = _minTimeBetweenTriggers;
        
        emit MinTimeBetweenTriggersUpdated(oldTime, _minTimeBetweenTriggers);
    }
    
    /// @notice Set the oracle address
    /// @param _oracle The new oracle address
    function setOracle(address _oracle) external onlyOwner {
        if (_oracle == address(0)) {
            revert BuybackTriggerEvaluator_InvalidAddress();
        }
        
        address oldOracle = address(oracle);
        oracle = IOracle(_oracle);
        
        emit OracleUpdated(oldOracle, _oracle);
    }
    
    /// @notice Set the deviation monitor address
    /// @param _deviationMonitor The new deviation monitor address
    function setDeviationMonitor(address _deviationMonitor) external onlyOwner {
        if (_deviationMonitor == address(0)) {
            revert BuybackTriggerEvaluator_InvalidAddress();
        }
        
        address oldMonitor = address(deviationMonitor);
        deviationMonitor = IBuybackDeviationMonitor(_deviationMonitor);
        
        emit DeviationMonitorUpdated(oldMonitor, _deviationMonitor);
    }
    
    /// @notice Transfer ownership of the contract
    /// @param newOwner The address of the new owner
    function transferOwnership(address newOwner) public override onlyOwner {
        super.transferOwnership(newOwner);
    }
}