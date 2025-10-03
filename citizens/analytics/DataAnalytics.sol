// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface DataAnalytics {
    /**
     * @dev Emitted when a data point is recorded.
     */
    event DataPointRecorded(string indexed category, bytes32 indexed key, uint256 value, uint256 timestamp);

    /**
     * @dev Error when an unauthorized address tries to record data.
     */
    error UnauthorizedDataRecording(address caller);

    /**
     * @dev Records a data point for analytics.
     * @param category The category of the data (e.g., "user_activity", "transaction_volume").
     * @param key A specific identifier within the category (e.g., user ID, token address).
     * @param value The numerical value of the data point.
     */
    function recordDataPoint(string calldata category, bytes32 key, uint256 value) external;

    /**
     * @dev Retrieves aggregated data for a specific category and key over a time range.
     * @param category The category of the data.
     * @param key A specific identifier within the category.
     * @param startTime The start timestamp for the aggregation.
     * @param endTime The end timestamp for the aggregation.
     * @return The aggregated value (e.g., sum, average).
     */
    function getAggregatedData(string calldata category, bytes32 key, uint256 startTime, uint256 endTime) external view returns (uint256);

    /**
     * @dev Retrieves the count of data points for a specific category and key over a time range.
     * @param category The category of the data.
     * @param key A specific identifier within the category.
     * @param startTime The start timestamp for the count.
     * @param endTime The end timestamp for the count.
     * @return The count of data points.
     */
    function getDataPointCount(string calldata category, bytes32 key, uint256 startTime, uint256 endTime) external view returns (uint256);
}