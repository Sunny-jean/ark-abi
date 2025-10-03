// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAIDataFeed {
    /**
     * @dev Emitted when new data is available from the feed.
     * @param dataId A unique identifier for the data point.
     * @param timestamp The time at which the data was recorded.
     * @param dataHash A hash of the data content.
     */
    event NewDataAvailable(bytes32 dataId, uint256 timestamp, bytes32 dataHash);

    /**
     * @dev Emitted when a data feed configuration is updated.
     * @param feedId The unique identifier for the data feed.
     * @param configHash A hash of the new configuration.
     */
    event DataFeedConfigUpdated(bytes32 feedId, bytes32 configHash);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a required parameter is missing or invalid.
     */
    error InvalidParameter(string parameterName, string description);

    /**
     * @dev Thrown when data is not available for the requested parameters.
     */
    error DataNotAvailable(string reason);

    /**
     * @dev Retrieves the latest data from the AI-powered data feed.
     * @param dataType The type of data to retrieve (e.g., "Price", "Sentiment", "Volume").
     * @return dataHash A hash of the latest data content.
     * @return timestamp The timestamp of the latest data.
     */
    function getLatestData(string calldata dataType) external view returns (bytes32 dataHash, uint256 timestamp);

    /**
     * @dev Retrieves historical data from the AI-powered data feed within a specified range.
     * @param dataType The type of data to retrieve.
     * @param startTime The start timestamp for the historical data.
     * @param endTime The end timestamp for the historical data.
     * @return dataHashes An array of hashes of the historical data points.
     * @return timestamps An array of timestamps corresponding to the data points.
     */
    function getHistoricalData(string calldata dataType, uint256 startTime, uint256 endTime) external view returns (bytes32[] memory dataHashes, uint256[] memory timestamps);

    /**
     * @dev Submits new data to the feed. This function would typically be called by off-chain data providers.
     * @param dataType The type of data being submitted.
     * @param dataContent The raw data content.
     * @return dataId A unique identifier for the submitted data point.
     */
    function submitData(string calldata dataType, bytes calldata dataContent) external returns (bytes32 dataId);

    /**
     * @dev Configures the data feed, e.g., setting update intervals or data sources.
     * @param configHash A hash of the new configuration data.
     */
    function configureFeed(bytes32 configHash) external;
}