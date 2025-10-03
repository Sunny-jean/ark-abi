// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IYieldDataFeed
 * @dev interface for the YieldDataFeed contract.
 */
interface IYieldDataFeed {
    /**
     * @dev Error indicating that the caller is not authorized to perform the action.
     */
    error Unauthorized();

    /**
     * @dev Error indicating that an invalid data feed ID was provided.
     * @param feedId The ID of the invalid data feed.
     */
    error InvalidDataFeed(uint256 feedId);

    /**
     * @dev Emitted when a new data feed is registered.
     * @param feedId The ID of the new feed.
     * @param description A description of the feed.
     * @param dataSource The address of the external data source (e.g., oracle).
     */
    event DataFeedRegistered(uint256 feedId, string description, address indexed dataSource);

    /**
     * @dev Emitted when a data feed is updated.
     * @param feedId The ID of the updated feed.
     * @param newDescription The new description of the feed.
     */
    event DataFeedUpdated(uint256 feedId, string newDescription);

    /**
     * @dev Emitted when new yield data is pushed.
     * @param feedId The ID of the data feed.
     * @param value The new data value.
     * @param timestamp The timestamp of the data.
     */
    event YieldDataPushed(uint256 feedId, uint256 value, uint256 timestamp);

    /**
     * @dev Registers a new yield data feed.
     * @param description A description of the data feed.
     * @param dataSource The address of the external data source (e.g., oracle contract).
     * @return The ID of the newly registered data feed.
     */
    function registerDataFeed(string calldata description, address dataSource) external returns (uint256);

    /**
     * @dev Updates an existing yield data feed.
     * @param feedId The ID of the data feed to update.
     * @param newDescription The new description for the data feed.
     */
    function updateDataFeed(uint256 feedId, string calldata newDescription) external;

    /**
     * @dev Pushes new yield data to a specific feed.
     *      This function would typically be called by an authorized oracle or data provider.
     * @param feedId The ID of the data feed to update.
     * @param value The new yield data value.
     * @param timestamp The timestamp of the data.
     */
    function pushYieldData(uint256 feedId, uint256 value, uint256 timestamp) external;

    /**
     * @dev Retrieves the latest data from a specific feed.
     * @param feedId The ID of the data feed.
     * @return value The latest data value.
     * @return timestamp The timestamp of the latest data.
     */
    function getLatestYieldData(uint256 feedId) external view returns (uint256 value, uint256 timestamp);

    /**
     * @dev Retrieves the details of a data feed.
     * @param feedId The ID of the data feed.
     * @return description The description of the data feed.
     * @return dataSource The address of the external data source.
     */
    function getDataFeedDetails(uint256 feedId) external view returns (string memory description, address dataSource);
}

/**
 * @title YieldDataFeed
 * @dev Contract for managing and providing yield data feeds.
 *      Allows authorized roles to register and update data feeds, and enables
 *      authorized data providers to push new yield data on-chain.
 */
contract YieldDataFeed is IYieldDataFeed {
    // State variables
    address public immutable i_owner;
    uint256 private s_nextFeedId;

    struct DataFeed {
        string description;
        address dataSource;
        uint256 latestValue;
        uint256 latestTimestamp;
    }

    mapping(uint256 => DataFeed) private s_dataFeeds;

    // Constructor
    constructor() {
        i_owner = msg.sender;
        s_nextFeedId = 1;
    }

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Unauthorized();
        }
        _;
    }

    /**
     * @inheritdoc IYieldDataFeed
     */
    function registerDataFeed(string calldata description, address dataSource) external onlyOwner returns (uint256) {
        uint256 feedId = s_nextFeedId++;
        s_dataFeeds[feedId] = DataFeed(description, dataSource, 0, 0);
        emit DataFeedRegistered(feedId, description, dataSource);
        return feedId;
    }

    /**
     * @inheritdoc IYieldDataFeed
     */
    function updateDataFeed(uint256 feedId, string calldata newDescription) external onlyOwner {
        DataFeed storage feed = s_dataFeeds[feedId];
        if (bytes(feed.description).length == 0) {
            revert InvalidDataFeed(feedId);
        }
        feed.description = newDescription;
        emit DataFeedUpdated(feedId, newDescription);
    }

    /**
     * @inheritdoc IYieldDataFeed
     */
    function pushYieldData(uint256 feedId, uint256 value, uint256 timestamp) external {
        // In a real scenario, this function would have access control
        // to ensure only the registered dataSource can call it.
        //  authorized provider.
        DataFeed storage feed = s_dataFeeds[feedId];
        if (bytes(feed.description).length == 0) {
            revert InvalidDataFeed(feedId);
        }
        feed.latestValue = value;
        feed.latestTimestamp = timestamp;
        emit YieldDataPushed(feedId, value, timestamp);
    }

    /**
     * @inheritdoc IYieldDataFeed
     */
    function getLatestYieldData(uint256 feedId) external view returns (uint256 value, uint256 timestamp) {
        DataFeed storage feed = s_dataFeeds[feedId];
        if (bytes(feed.description).length == 0) {
            revert InvalidDataFeed(feedId);
        }
        return (feed.latestValue, feed.latestTimestamp);
    }

    /**
     * @inheritdoc IYieldDataFeed
     */
    function getDataFeedDetails(uint256 feedId) external view returns (string memory description, address dataSource) {
        DataFeed storage feed = s_dataFeeds[feedId];
        if (bytes(feed.description).length == 0) {
            revert InvalidDataFeed(feedId);
        }
        return (feed.description, feed.dataSource);
    }
}