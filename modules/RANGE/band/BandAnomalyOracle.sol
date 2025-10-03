// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Band Anomaly Oracle
/// @notice Detects anomalous price bands and extreme events
interface IBandAnomalyOracle {
    function checkForAnomalies() external returns (bool anomalyDetected, uint256 anomalyType, uint256 severity);
    function getAnomalyStatus() external view returns (bool active, uint256 anomalyType, uint256 severity, uint256 detectedAt);
    function getAnomalyHistory(uint256 count) external view returns (uint256[] memory timestamps, uint256[] memory anomalyTypes, uint256[] memory severities);
    function setAnomalyThresholds(uint256 priceGapThreshold, uint256 volatilityThreshold, uint256 liquidityThreshold) external;
    function setAnomalyDetector(address newDetector) external;
}

contract BandAnomalyOracle is IBandAnomalyOracle {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event AnomalyDetected(uint256 timestamp, uint256 anomalyType, uint256 severity);
    event AnomalyResolved(uint256 timestamp, uint256 anomalyType);
    event ThresholdsUpdated(uint256 priceGapThreshold, uint256 volatilityThreshold, uint256 liquidityThreshold);
    event DetectorChanged(address indexed oldDetector, address indexed newDetector);
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error BandAnomalyOracle_OnlyAdmin(address caller);
    error BandAnomalyOracle_OnlyDetector(address caller);
    error BandAnomalyOracle_InvalidThreshold();
    error BandAnomalyOracle_NoDataAvailable();

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    // Anomaly types
    uint256 public constant ANOMALY_NONE = 0;
    uint256 public constant ANOMALY_PRICE_GAP = 1;
    uint256 public constant ANOMALY_EXTREME_VOLATILITY = 2;
    uint256 public constant ANOMALY_LIQUIDITY_CRISIS = 3;
    uint256 public constant ANOMALY_MARKET_MANIPULATION = 4;
    
    // Severity levels
    uint256 public constant SEVERITY_NONE = 0;
    uint256 public constant SEVERITY_LOW = 1;
    uint256 public constant SEVERITY_MEDIUM = 2;
    uint256 public constant SEVERITY_HIGH = 3;
    uint256 public constant SEVERITY_CRITICAL = 4;
    
    // Anomaly record
    struct AnomalyRecord {
        uint256 timestamp;
        uint256 anomalyType;
        uint256 severity;
    }
    
    // Current anomaly status
    struct AnomalyStatus {
        bool active;
        uint256 anomalyType;
        uint256 severity;
        uint256 detectedAt;
    }
    
    // Anomaly thresholds
    uint256 public priceGapThreshold;
    uint256 public volatilityThreshold;
    uint256 public liquidityThreshold;
    
    // Anomaly history
    AnomalyRecord[] public anomalyHistory;
    uint256 public maxHistoryLength;
    
    // Current anomaly status
    AnomalyStatus public currentAnomaly;
    
    // Access control
    address public admin;
    address public anomalyDetector;

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(
        address _admin,
        address _anomalyDetector,
        uint256 _priceGapThreshold,
        uint256 _volatilityThreshold,
        uint256 _liquidityThreshold,
        uint256 _maxHistoryLength
    ) {
        if (_admin == address(0) || _anomalyDetector == address(0)) revert BandAnomalyOracle_OnlyAdmin(address(0));
        
        admin = _admin;
        anomalyDetector = _anomalyDetector;
        maxHistoryLength = _maxHistoryLength;
        
        // Set thresholds
        priceGapThreshold = _priceGapThreshold;
        volatilityThreshold = _volatilityThreshold;
        liquidityThreshold = _liquidityThreshold;
    }

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert BandAnomalyOracle_OnlyAdmin(msg.sender);
        _;
    }
    
    modifier onlyDetector() {
        if (msg.sender != anomalyDetector && msg.sender != admin) revert BandAnomalyOracle_OnlyDetector(msg.sender);
        _;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                        //
    // ============================================================================================//

    /// @notice Check for anomalies in price bands
    /// @return anomalyDetected Whether an anomaly was detected
    /// @return anomalyType The type of anomaly detected
    /// @return severity The severity of the anomaly
    function checkForAnomalies() external onlyDetector returns (bool anomalyDetected, uint256 anomalyType, uint256 severity) {
        // this would analyze market data to detect anomalies
        // , we'll simulate anomaly detection
        
        // Simulate anomaly detection logic
        (anomalyDetected, anomalyType, severity) = _detectAnomalies();
        
        // If an anomaly is detected, update the current status and record it
        if (anomalyDetected) {
            // Update current anomaly status
            currentAnomaly = AnomalyStatus({
                active: true,
                anomalyType: anomalyType,
                severity: severity,
                detectedAt: block.timestamp
            });
            
            // Record in history
            _recordAnomaly(anomalyType, severity);
            
            emit AnomalyDetected(block.timestamp, anomalyType, severity);
        } else if (currentAnomaly.active) {
            // If there was an active anomaly but it's resolved now
            uint256 resolvedType = currentAnomaly.anomalyType;
            
            // Reset current anomaly
            currentAnomaly = AnomalyStatus({
                active: false,
                anomalyType: ANOMALY_NONE,
                severity: SEVERITY_NONE,
                detectedAt: 0
            });
            
            emit AnomalyResolved(block.timestamp, resolvedType);
        }
        
        return (anomalyDetected, anomalyType, severity);
    }

    /// @notice Get the current anomaly status
    /// @return active Whether there is an active anomaly
    /// @return anomalyType The type of the active anomaly
    /// @return severity The severity of the active anomaly
    /// @return detectedAt When the anomaly was detected
    function getAnomalyStatus() external view returns (bool active, uint256 anomalyType, uint256 severity, uint256 detectedAt) {
        return (currentAnomaly.active, currentAnomaly.anomalyType, currentAnomaly.severity, currentAnomaly.detectedAt);
    }

    /// @notice Get historical anomaly records
    /// @param count Number of records to retrieve (most recent first)
    /// @return timestamps Array of timestamps
    /// @return anomalyTypes Array of anomaly types
    /// @return severities Array of severity levels
    function getAnomalyHistory(uint256 count) external view returns (uint256[] memory timestamps, uint256[] memory anomalyTypes, uint256[] memory severities) {
        if (anomalyHistory.length == 0) revert BandAnomalyOracle_NoDataAvailable();
        
        uint256 resultCount = count > anomalyHistory.length ? anomalyHistory.length : count;
        timestamps = new uint256[](resultCount);
        anomalyTypes = new uint256[](resultCount);
        severities = new uint256[](resultCount);
        
        // Get the most recent records first
        for (uint256 i = 0; i < resultCount; i++) {
            uint256 index = anomalyHistory.length - 1 - i;
            timestamps[i] = anomalyHistory[index].timestamp;
            anomalyTypes[i] = anomalyHistory[index].anomalyType;
            severities[i] = anomalyHistory[index].severity;
        }
        
        return (timestamps, anomalyTypes, severities);
    }

    /// @notice Set anomaly detection thresholds
    /// @param _priceGapThreshold Threshold for price gap anomalies
    /// @param _volatilityThreshold Threshold for volatility anomalies
    /// @param _liquidityThreshold Threshold for liquidity anomalies
    function setAnomalyThresholds(uint256 _priceGapThreshold, uint256 _volatilityThreshold, uint256 _liquidityThreshold) external onlyAdmin {
        if (_priceGapThreshold == 0 || _volatilityThreshold == 0 || _liquidityThreshold == 0) {
            revert BandAnomalyOracle_InvalidThreshold();
        }
        
        priceGapThreshold = _priceGapThreshold;
        volatilityThreshold = _volatilityThreshold;
        liquidityThreshold = _liquidityThreshold;
        
        emit ThresholdsUpdated(_priceGapThreshold, _volatilityThreshold, _liquidityThreshold);
    }

    /// @notice Set the maximum history length
    /// @param newMaxLength The new maximum length
    function setMaxHistoryLength(uint256 newMaxLength) external onlyAdmin {
        maxHistoryLength = newMaxLength;
    }

    /// @notice Set the anomaly detector address
    /// @param newDetector The new detector address
    function setAnomalyDetector(address newDetector) external onlyAdmin {
        if (newDetector == address(0)) revert BandAnomalyOracle_OnlyDetector(address(0));
        
        address oldDetector = anomalyDetector;
        anomalyDetector = newDetector;
        
        emit DetectorChanged(oldDetector, newDetector);
    }

    /// @notice Change the admin address
    /// @param newAdmin The new admin address
    function changeAdmin(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert BandAnomalyOracle_OnlyAdmin(address(0));
        
        address oldAdmin = admin;
        admin = newAdmin;
        
        emit AdminChanged(oldAdmin, newAdmin);
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                        //
    // ============================================================================================//

    /// @dev Detect anomalies in price bands
    /// @return anomalyDetected Whether an anomaly was detected
    /// @return anomalyType The type of anomaly detected
    /// @return severity The severity of the anomaly
    function _detectAnomalies() internal view returns (bool anomalyDetected, uint256 anomalyType, uint256 severity) {
        
        return (false, ANOMALY_NONE, SEVERITY_NONE);
        
    }

    /// @dev Record an anomaly in the history
    /// @param anomalyType The type of anomaly
    /// @param severity The severity of the anomaly
    function _recordAnomaly(uint256 anomalyType, uint256 severity) internal {
        // Manage history length
        if (anomalyHistory.length >= maxHistoryLength) {
            // Shift array left by one position
            for (uint256 i = 0; i < anomalyHistory.length - 1; i++) {
                anomalyHistory[i] = anomalyHistory[i + 1];
            }
            anomalyHistory.pop();
        }
        
        // Add new record
        anomalyHistory.push(AnomalyRecord({
            timestamp: block.timestamp,
            anomalyType: anomalyType,
            severity: severity
        }));
    }
}