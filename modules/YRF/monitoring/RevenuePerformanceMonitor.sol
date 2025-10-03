// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IRevenuePerformanceMonitor
 * @dev interface for the RevenuePerformanceMonitor contract.
 */
interface IRevenuePerformanceMonitor {
    /**
     * @dev Error indicating that the caller is not authorized to perform the action.
     */
    error Unauthorized();

    /**
     * @dev Error indicating that a metric with the given ID does not exist.
     * @param metricId The ID of the non-existent metric.
     */
    error MetricNotFound(uint256 metricId);

    /**
     * @dev Error indicating that a metric with the given ID already exists.
     * @param metricId The ID of the existing metric.
     */
    error MetricAlreadyExists(uint256 metricId);

    /**
     * @dev Emitted when a new revenue performance metric is registered.
     * @param metricId The ID of the registered metric.
     * @param name The name of the metric.
     * @param description A description of the metric.
     * @param isActive Whether the metric is active upon registration.
     */
    event PerformanceMetricRegistered(uint256 metricId, string name, string description, bool isActive);

    /**
     * @dev Emitted when an existing revenue performance metric is updated.
     * @param metricId The ID of the updated metric.
     * @param newName The new name of the metric.
     * @param newDescription The new description of the metric.
     */
    event PerformanceMetricUpdated(uint256 metricId, string newName, string newDescription);

    /**
     * @dev Emitted when a revenue performance metric's active status is changed.
     * @param metricId The ID of the metric.
     * @param newStatus The new active status (true for active, false for inactive).
     */
    event PerformanceMetricStatusChanged(uint256 metricId, bool newStatus);

    /**
     * @dev Registers a new revenue performance metric.
     * @param name The name of the metric (e.g., "Daily Revenue", "Conversion Rate").
     * @param description A detailed description of the metric.
     * @param isActive Initial active status of the metric.
     * @return The unique ID assigned to the registered metric.
     */
    function registerPerformanceMetric(string calldata name, string calldata description, bool isActive) external returns (uint256);

    /**
     * @dev Updates the details of an existing revenue performance metric.
     * @param metricId The ID of the metric to update.
     * @param newName The new name for the metric.
     * @param newDescription The new description for the metric.
     */
    function updatePerformanceMetric(uint256 metricId, string calldata newName, string calldata newDescription) external;

    /**
     * @dev Changes the active status of a revenue performance metric.
     * @param metricId The ID of the metric.
     * @param newStatus The new active status (true to activate, false to deactivate).
     */
    function setPerformanceMetricStatus(uint256 metricId, bool newStatus) external;

    /**
     * @dev Records a new data point for a specific revenue performance metric.
     * @param metricId The ID of the metric.
     * @param value The value of the data point.
     * @param timestamp The timestamp of the data point.
     */
    function recordMetricData(uint256 metricId, uint256 value, uint256 timestamp) external;

    /**
     * @dev Retrieves the details of a specific revenue performance metric.
     * @param metricId The ID of the metric.
     * @return name The name of the metric.
     * @return description The description of the metric.
     * @return isActive The active status of the metric.
     */
    function getPerformanceMetricDetails(uint256 metricId) external view returns (string memory name, string memory description, bool isActive);

    /**
     * @dev Retrieves the latest data point for a specific revenue performance metric.
     * @param metricId The ID of the metric.
     * @return value The latest recorded value.
     * @return timestamp The timestamp of the latest recorded value.
     */
    function getLatestMetricData(uint256 metricId) external view returns (uint256 value, uint256 timestamp);

    /**
     * @dev Retrieves a list of all registered performance metric IDs.
     * @return An array of all metric IDs.
     */
    function getAllPerformanceMetricIds() external view returns (uint256[] memory);

    /**
     * @dev Retrieves a list of active performance metric IDs.
     * @return An array of active metric IDs.
     */
    function getActivePerformanceMetricIds() external view returns (uint256[] memory);
}

/**
 * @title RevenuePerformanceMonitor
 * @dev Manages and tracks various revenue performance metrics within the DAO.
 *      Allows for registration, updating, status management, and data recording of different metrics.
 */
contract RevenuePerformanceMonitor is IRevenuePerformanceMonitor {
    // State variables
    address public immutable i_owner;
    uint256 private s_nextMetricId;

    struct PerformanceMetric {
        string name;
        string description;
        bool isActive;
        uint256 latestValue;
        uint256 latestTimestamp;
    }

    mapping(uint256 => PerformanceMetric) private s_performanceMetrics;
    uint256[] private s_allMetricIds;

    // Constructor
    constructor() {
        i_owner = msg.sender;
        s_nextMetricId = 1;
    }

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Unauthorized();
        }
        _;
    }

    /**
     * @inheritdoc IRevenuePerformanceMonitor
     */
    function registerPerformanceMetric(string calldata name, string calldata description, bool isActive) external onlyOwner returns (uint256) {
        uint256 metricId = s_nextMetricId++;
        s_performanceMetrics[metricId] = PerformanceMetric(name, description, isActive, 0, 0);
        s_allMetricIds.push(metricId);
        emit PerformanceMetricRegistered(metricId, name, description, isActive);
        return metricId;
    }

    /**
     * @inheritdoc IRevenuePerformanceMonitor
     */
    function updatePerformanceMetric(uint256 metricId, string calldata newName, string calldata newDescription) external onlyOwner {
        PerformanceMetric storage metric = s_performanceMetrics[metricId];
        if (bytes(metric.name).length == 0) {
            revert MetricNotFound(metricId);
        }
        metric.name = newName;
        metric.description = newDescription;
        emit PerformanceMetricUpdated(metricId, newName, newDescription);
    }

    /**
     * @inheritdoc IRevenuePerformanceMonitor
     */
    function setPerformanceMetricStatus(uint256 metricId, bool newStatus) external onlyOwner {
        PerformanceMetric storage metric = s_performanceMetrics[metricId];
        if (bytes(metric.name).length == 0) {
            revert MetricNotFound(metricId);
        }
        if (metric.isActive != newStatus) {
            metric.isActive = newStatus;
            emit PerformanceMetricStatusChanged(metricId, newStatus);
        }
    }

    /**
     * @inheritdoc IRevenuePerformanceMonitor
     */
    function recordMetricData(uint256 metricId, uint256 value, uint256 timestamp) external onlyOwner {
        PerformanceMetric storage metric = s_performanceMetrics[metricId];
        if (bytes(metric.name).length == 0) {
            revert MetricNotFound(metricId);
        }
        metric.latestValue = value;
        metric.latestTimestamp = timestamp;
    }

    /**
     * @inheritdoc IRevenuePerformanceMonitor
     */
    function getPerformanceMetricDetails(uint256 metricId) external view returns (string memory name, string memory description, bool isActive) {
        PerformanceMetric storage metric = s_performanceMetrics[metricId];
        if (bytes(metric.name).length == 0) {
            revert MetricNotFound(metricId);
        }
        return (metric.name, metric.description, metric.isActive);
    }

    /**
     * @inheritdoc IRevenuePerformanceMonitor
     */
    function getLatestMetricData(uint256 metricId) external view returns (uint256 value, uint256 timestamp) {
        PerformanceMetric storage metric = s_performanceMetrics[metricId];
        if (bytes(metric.name).length == 0) {
            revert MetricNotFound(metricId);
        }
        return (metric.latestValue, metric.latestTimestamp);
    }

    /**
     * @inheritdoc IRevenuePerformanceMonitor
     */
    function getAllPerformanceMetricIds() external view returns (uint256[] memory) {
        return s_allMetricIds;
    }

    /**
     * @inheritdoc IRevenuePerformanceMonitor
     */
    function getActivePerformanceMetricIds() external view returns (uint256[] memory) {
        uint256[] memory activeIds = new uint256[](s_allMetricIds.length);
        uint256 count = 0;
        for (uint256 i = 0; i < s_allMetricIds.length; i++) {
            uint256 metricId = s_allMetricIds[i];
            if (s_performanceMetrics[metricId].isActive) {
                activeIds[count] = metricId;
                count++;
            }
        }
        assembly {
            mstore(activeIds, count)
        }
        return activeIds;
    }
}