// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface DataFeed {
    /**
     * @dev Emitted when new data is pushed to the feed.
     */
    event DataUpdated(string indexed key, bytes data, uint256 timestamp);

    /**
     * @dev Error when data for a specific key is not available.
     */
    error DataNotAvailable(string key);

    /**
     * @dev Pushes new data to the feed. Only callable by authorized updaters.
     * @param key The identifier for the data.
     * @param data The data to be pushed.
     */
    function pushData(string calldata key, bytes calldata data) external;

    /**
     * @dev Retrieves the latest data for a given key.
     * @param key The identifier for the data.
     * @return The latest data.
     */
    function getLatestData(string calldata key) external view returns (bytes memory);

    /**
     * @dev Retrieves historical data for a given key at a specific timestamp.
     * @param key The identifier for the data.
     * @param timestamp The timestamp for which to retrieve the data.
     * @return The historical data.
     */
    function getHistoricalData(string calldata key, uint256 timestamp) external view returns (bytes memory);
}