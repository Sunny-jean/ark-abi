// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Performance Monitor
/// @notice Monitors system performance metrics and provides insights
interface IPerformanceMonitor {
    function recordMetric(bytes32 metricId, uint256 value) external;
    function getMetricValue(bytes32 metricId) external view returns (uint256 value, uint256 timestamp);
    function getMetricHistory(bytes32 metricId, uint256 count) external view returns (uint256[] memory values, uint256[] memory timestamps);
    function getPerformanceReport() external view returns (bytes memory report);
}

contract PerformanceMonitor is IPerformanceMonitor {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event MetricRecorded(bytes32 indexed metricId, uint256 value, uint256 timestamp);
    event MetricRegistered(bytes32 indexed metricId, string name, string description, string unit, uint256 threshold);
    event MetricThresholdUpdated(bytes32 indexed metricId, uint256 oldThreshold, uint256 newThreshold);
    event MetricSourceAuthorized(address indexed source, bytes32[] metricIds);
    event MetricSourceDeauthorized(address indexed source);
    event PerformanceAlertTriggered(bytes32 indexed metricId, uint256 value, uint256 threshold, string message);
    event PerformanceAlertResolved(bytes32 indexed metricId);
    event PerformanceMonitorAdminChanged(address indexed oldAdmin, address indexed newAdmin);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error PerformanceMonitor_OnlyAdmin(address caller);
    error PerformanceMonitor_OnlyAuthorizedSource(address source, bytes32 metricId);
    error PerformanceMonitor_MetricNotRegistered(bytes32 metricId);
    error PerformanceMonitor_MetricAlreadyRegistered(bytes32 metricId);
    error PerformanceMonitor_InvalidAddress(address addr);
    error PerformanceMonitor_InvalidThreshold(uint256 threshold);
    error PerformanceMonitor_InvalidMetricValue(uint256 value);
    error PerformanceMonitor_NoDataAvailable(bytes32 metricId);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct MetricData {
        bytes32 id;
        string name;
        string description;
        string unit;
        uint256 threshold; // Alert threshold
        bool isRegistered;
        bool alertActive;
    }

    struct MetricValue {
        uint256 value;
        uint256 timestamp;
    }

    struct MetricSource {
        address source;
        bytes32[] authorizedMetrics;
        bool isAuthorized;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    
    // Metrics
    mapping(bytes32 => MetricData) public metrics;
    bytes32[] public registeredMetrics;
    
    // Metric values
    mapping(bytes32 => MetricValue[]) public metricHistory;
    mapping(bytes32 => MetricValue) public latestMetricValues;
    
    // Authorized sources
    mapping(address => MetricSource) public metricSources;
    mapping(bytes32 => mapping(address => bool)) public isAuthorizedForMetric;
    address[] public authorizedSources;
    
    // Performance reporting
    uint256 public reportingPeriod = 86400; // Default: 1 day
    uint256 public lastReportTimestamp;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert PerformanceMonitor_OnlyAdmin(msg.sender);
        _;
    }

    modifier metricRegistered(bytes32 metricId) {
        if (!metrics[metricId].isRegistered) {
            revert PerformanceMonitor_MetricNotRegistered(metricId);
        }
        _;
    }

    modifier onlyAuthorizedSource(bytes32 metricId) {
        if (!isAuthorizedForMetric[metricId][msg.sender] && msg.sender != admin) {
            revert PerformanceMonitor_OnlyAuthorizedSource(msg.sender, metricId);
        }
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_) {
        if (admin_ == address(0)) revert PerformanceMonitor_InvalidAddress(admin_);
        
        admin = admin_;
        
        // Initialize default metrics
        _registerMetric("GAS_USAGE", "Gas usage per transaction", "Gas units", 1000000);
        _registerMetric("RESPONSE_TIME", "Response time for operations", "Milliseconds", 5000);
        _registerMetric("TRANSACTION_COUNT", "Number of transactions", "Count", 0);
        _registerMetric("ERROR_RATE", "Rate of errors", "Percentage", 5);
        _registerMetric("MEMORY_USAGE", "Contract memory usage", "Bytes", 0);
        
        // Authorize admin for all metrics
        bytes32[] memory allMetrics = new bytes32[](5);
        allMetrics[0] = keccak256("GAS_USAGE");
        allMetrics[1] = keccak256("RESPONSE_TIME");
        allMetrics[2] = keccak256("TRANSACTION_COUNT");
        allMetrics[3] = keccak256("ERROR_RATE");
        allMetrics[4] = keccak256("MEMORY_USAGE");
        
        _authorizeSource(admin_, allMetrics);
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Record a metric value
    /// @param metricId The metric ID
    /// @param value The metric value
    function recordMetric(
        bytes32 metricId,
        uint256 value
    ) external override onlyAuthorizedSource(metricId) metricRegistered(metricId) {
        // Store the metric value
        MetricValue memory newValue = MetricValue({
            value: value,
            timestamp: block.timestamp
        });
        
        metricHistory[metricId].push(newValue);
        latestMetricValues[metricId] = newValue;
        
        // Check threshold and trigger alert if needed
        MetricData storage metric = metrics[metricId];
        if (metric.threshold > 0) {
            if (value > metric.threshold && !metric.alertActive) {
                // Trigger alert
                metric.alertActive = true;
                emit PerformanceAlertTriggered(
                    metricId,
                    value,
                    metric.threshold,
                    string(abi.encodePacked("Metric '", metric.name, "' exceeded threshold"))
                );
            } else if (value <= metric.threshold && metric.alertActive) {
                // Resolve alert
                metric.alertActive = false;
                emit PerformanceAlertResolved(metricId);
            }
        }
        
        emit MetricRecorded(metricId, value, block.timestamp);
    }

    /// @notice Register a new metric
    /// @param metricId The metric ID
    /// @param name The metric name
    /// @param description The metric description
    /// @param unit The metric unit
    /// @param threshold The alert threshold (0 for no threshold)
    function registerMetric(
        bytes32 metricId,
        string calldata name,
        string calldata description,
        string calldata unit,
        uint256 threshold
    ) external onlyAdmin {
        _registerMetric(name, description, unit, threshold);
    }

    /// @notice Update a metric's threshold
    /// @param metricId The metric ID
    /// @param newThreshold The new threshold
    function updateMetricThreshold(
        bytes32 metricId,
        uint256 newThreshold
    ) external onlyAdmin metricRegistered(metricId) {
        uint256 oldThreshold = metrics[metricId].threshold;
        metrics[metricId].threshold = newThreshold;
        
        emit MetricThresholdUpdated(metricId, oldThreshold, newThreshold);
    }

    /// @notice Authorize a source for specific metrics
    /// @param source The source address
    /// @param metricIds The metric IDs
    function authorizeSource(
        address source,
        bytes32[] calldata metricIds
    ) external onlyAdmin {
        _authorizeSource(source, metricIds);
    }

    /// @notice Deauthorize a source
    /// @param source The source address
    function deauthorizeSource(address source) external onlyAdmin {
        if (source == admin) revert PerformanceMonitor_InvalidAddress(source); // Can't deauthorize admin
        if (!metricSources[source].isAuthorized) return; // Not authorized
        
        // Remove authorization for all metrics
        bytes32[] storage authorizedMetrics = metricSources[source].authorizedMetrics;
        for (uint256 i = 0; i < authorizedMetrics.length; i++) {
            isAuthorizedForMetric[authorizedMetrics[i]][source] = false;
        }
        
        // Clear source data
        delete metricSources[source];
        
        // Remove from authorized sources array
        for (uint256 i = 0; i < authorizedSources.length; i++) {
            if (authorizedSources[i] == source) {
                authorizedSources[i] = authorizedSources[authorizedSources.length - 1];
                authorizedSources.pop();
                break;
            }
        }
        
        emit MetricSourceDeauthorized(source);
    }

    /// @notice Change the admin
    /// @param newAdmin The new admin address
    function changeAdmin(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert PerformanceMonitor_InvalidAddress(newAdmin);
        
        address oldAdmin = admin;
        admin = newAdmin;
        
        // Authorize new admin for all metrics if not already authorized
        if (!metricSources[newAdmin].isAuthorized) {
            _authorizeSource(newAdmin, registeredMetrics);
        }
        
        emit PerformanceMonitorAdminChanged(oldAdmin, newAdmin);
    }

    /// @notice Set the reporting period
    /// @param newPeriod The new reporting period in seconds
    function setReportingPeriod(uint256 newPeriod) external onlyAdmin {
        reportingPeriod = newPeriod;
    }

    /// @notice Get the current value of a metric
    /// @param metricId The metric ID
    /// @return value The metric value
    /// @return timestamp When the metric was last recorded
    function getMetricValue(
        bytes32 metricId
    ) external view override metricRegistered(metricId) returns (uint256 value, uint256 timestamp) {
        MetricValue memory latest = latestMetricValues[metricId];
        if (latest.timestamp == 0) revert PerformanceMonitor_NoDataAvailable(metricId);
        
        return (latest.value, latest.timestamp);
    }

    /// @notice Get the history of a metric
    /// @param metricId The metric ID
    /// @param count The number of historical values to retrieve
    /// @return values The metric values
    /// @return timestamps When the metrics were recorded
    function getMetricHistory(
        bytes32 metricId,
        uint256 count
    ) external view override metricRegistered(metricId) returns (uint256[] memory values, uint256[] memory timestamps) {
        MetricValue[] storage history = metricHistory[metricId];
        if (history.length == 0) revert PerformanceMonitor_NoDataAvailable(metricId);
        
        // Determine how many values to return
        uint256 resultCount = count;
        if (resultCount > history.length) {
            resultCount = history.length;
        }
        
        // Create result arrays
        values = new uint256[](resultCount);
        timestamps = new uint256[](resultCount);
        
        // Fill arrays with most recent values first
        for (uint256 i = 0; i < resultCount; i++) {
            uint256 index = history.length - 1 - i;
            values[i] = history[index].value;
            timestamps[i] = history[index].timestamp;
        }
        
        return (values, timestamps);
    }

    /// @notice Get a performance report
    /// @return report The performance report as bytes
    function getPerformanceReport() external view override returns (bytes memory report) {
        
        return abi.encode(
            block.timestamp,
            registeredMetrics.length,
            authorizedSources.length,
            lastReportTimestamp,
            reportingPeriod
        );
    }

    /// @notice Get metric details
    /// @param metricId The metric ID
    /// @return id The metric ID
    /// @return name The metric name
    /// @return description The metric description
    /// @return unit The metric unit
    /// @return threshold The alert threshold
    /// @return isRegistered Whether the metric is registered
    /// @return alertActive Whether an alert is active for this metric
    function getMetricDetails(bytes32 metricId) external view returns (
        bytes32 id,
        string memory name,
        string memory description,
        string memory unit,
        uint256 threshold,
        bool isRegistered,
        bool alertActive
    ) {
        MetricData storage metric = metrics[metricId];
        return (
            metric.id,
            metric.name,
            metric.description,
            metric.unit,
            metric.threshold,
            metric.isRegistered,
            metric.alertActive
        );
    }

    /// @notice Get all registered metrics
    /// @return Array of metric IDs
    function getRegisteredMetrics() external view returns (bytes32[] memory) {
        return registeredMetrics;
    }

    /// @notice Get all authorized sources
    /// @return Array of source addresses
    function getAuthorizedSources() external view returns (address[] memory) {
        return authorizedSources;
    }

    /// @notice Get metrics authorized for a source
    /// @param source The source address
    /// @return Array of metric IDs
    function getAuthorizedMetricsForSource(address source) external view returns (bytes32[] memory) {
        return metricSources[source].authorizedMetrics;
    }

    /// @notice Get metrics with active alerts
    /// @return Array of metric IDs
    function getMetricsWithActiveAlerts() external view returns (bytes32[] memory) {
        uint256 alertCount = 0;
        
        // Count metrics with active alerts
        for (uint256 i = 0; i < registeredMetrics.length; i++) {
            if (metrics[registeredMetrics[i]].alertActive) {
                alertCount++;
            }
        }
        
        // Create result array
        bytes32[] memory result = new bytes32[](alertCount);
        uint256 resultIndex = 0;
        
        // Fill result array
        for (uint256 i = 0; i < registeredMetrics.length && resultIndex < alertCount; i++) {
            if (metrics[registeredMetrics[i]].alertActive) {
                result[resultIndex++] = registeredMetrics[i];
            }
        }
        
        return result;
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Internal function to register a metric
    /// @param name The metric name
    /// @param description The metric description
    /// @param unit The metric unit
    /// @param threshold The alert threshold
    function _registerMetric(
        string memory name,
        string memory description,
        string memory unit,
        uint256 threshold
    ) internal {
        bytes32 metricId = keccak256(bytes(name));
        
        if (metrics[metricId].isRegistered) {
            revert PerformanceMonitor_MetricAlreadyRegistered(metricId);
        }
        
        metrics[metricId] = MetricData({
            id: metricId,
            name: name,
            description: description,
            unit: unit,
            threshold: threshold,
            isRegistered: true,
            alertActive: false
        });
        
        registeredMetrics.push(metricId);
        
        emit MetricRegistered(metricId, name, description, unit, threshold);
    }

    /// @notice Internal function to authorize a source for metrics
    /// @param source The source address
    /// @param metricIds The metric IDs
    function _authorizeSource(
        address source,
        bytes32[] memory metricIds
    ) internal {
        if (source == address(0)) revert PerformanceMonitor_InvalidAddress(source);
        
        // Create or update source data
        if (!metricSources[source].isAuthorized) {
            metricSources[source].source = source;
            metricSources[source].isAuthorized = true;
            authorizedSources.push(source);
        }
        
        // Authorize for each metric
        for (uint256 i = 0; i < metricIds.length; i++) {
            bytes32 metricId = metricIds[i];
            
            if (!metrics[metricId].isRegistered) {
                revert PerformanceMonitor_MetricNotRegistered(metricId);
            }
            
            if (!isAuthorizedForMetric[metricId][source]) {
                isAuthorizedForMetric[metricId][source] = true;
                metricSources[source].authorizedMetrics.push(metricId);
            }
        }
        
        emit MetricSourceAuthorized(source, metricIds);
    }
}