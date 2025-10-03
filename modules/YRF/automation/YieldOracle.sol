// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IYieldOracle
 * @dev interface for the YieldOracle contract.
 */
interface IYieldOracle {
    /**
     * @dev Error indicating that the caller is not authorized to perform the action.
     */
    error Unauthorized();

    /**
     * @dev Error indicating that an invalid data source ID was provided.
     * @param sourceId The ID of the invalid data source.
     */
    error InvalidDataSource(uint256 sourceId);

    /**
     * @dev Emitted when a new data source is registered.
     * @param sourceId The ID of the new source.
     * @param description A description of the source.
     * @param sourceAddress The address of the external data source.
     */
    event DataSourceRegistered(uint256 sourceId, string description, address indexed sourceAddress);

    /**
     * @dev Emitted when a data source is updated.
     * @param sourceId The ID of the updated source.
     * @param newDescription The new description of the source.
     */
    event DataSourceUpdated(uint256 sourceId, string newDescription);

    /**
     * @dev Emitted when new yield data is updated.
     * @param sourceId The ID of the data source.
     * @param value The new data value.
     * @param timestamp The timestamp of the data.
     */
    event YieldDataUpdated(uint256 sourceId, uint256 value, uint256 timestamp);

    /**
     * @dev Registers a new external data source for yield information.
     * @param description A description of the data source.
     * @param sourceAddress The address of the external data source (e.g., another oracle, a data provider contract).
     * @return The ID of the newly registered data source.
     */
    function registerDataSource(string calldata description, address sourceAddress) external returns (uint256);

    /**
     * @dev Updates an existing external data source.
     * @param sourceId The ID of the data source to update.
     * @param newDescription The new description for the data source.
     */
    function updateDataSource(uint256 sourceId, string calldata newDescription) external;

    /**
     * @dev Updates the yield data from a specific source.
     *      This function would typically be called by the registered data source itself.
     * @param sourceId The ID of the data source.
     * @param value The new yield data value.
     * @param timestamp The timestamp of the data.
     */
    function updateYieldData(uint256 sourceId, uint256 value, uint256 timestamp) external;

    /**
     * @dev Retrieves the latest yield data from a specific source.
     * @param sourceId The ID of the data source.
     * @return value The latest data value.
     * @return timestamp The timestamp of the latest data.
     */
    function getLatestYieldData(uint256 sourceId) external view returns (uint256 value, uint256 timestamp);

    /**
     * @dev Retrieves the details of a data source.
     * @param sourceId The ID of the data source.
     * @return description The description of the data source.
     * @return sourceAddress The address of the data source.
     */
    function getDataSourceDetails(uint256 sourceId) external view returns (string memory description, address sourceAddress);
}

/**
 * @title YieldOracle
 * @dev Contract for providing and managing yield data from various external sources.
 *      Acts as an on-chain oracle for yield-related information, allowing authorized
 *      data sources to push updates and other contracts to query the latest data.
 */
contract YieldOracle is IYieldOracle {
    // State variables
    address public immutable i_owner;
    uint256 private s_nextSourceId;

    struct DataSource {
        string description;
        address sourceAddress;
        uint256 latestValue;
        uint256 latestTimestamp;
    }

    mapping(uint256 => DataSource) private s_dataSources;

    // Constructor
    constructor() {
        i_owner = msg.sender;
        s_nextSourceId = 1;
    }

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Unauthorized();
        }
        _;
    }

    /**
     * @inheritdoc IYieldOracle
     */
    function registerDataSource(string calldata description, address sourceAddress) external onlyOwner returns (uint256) {
        uint256 sourceId = s_nextSourceId++;
        s_dataSources[sourceId] = DataSource(description, sourceAddress, 0, 0);
        emit DataSourceRegistered(sourceId, description, sourceAddress);
        return sourceId;
    }

    /**
     * @inheritdoc IYieldOracle
     */
    function updateDataSource(uint256 sourceId, string calldata newDescription) external onlyOwner {
        DataSource storage source = s_dataSources[sourceId];
        if (bytes(source.description).length == 0) {
            revert InvalidDataSource(sourceId);
        }
        source.description = newDescription;
        emit DataSourceUpdated(sourceId, newDescription);
    }

    /**
     * @inheritdoc IYieldOracle
     */
    function updateYieldData(uint256 sourceId, uint256 value, uint256 timestamp) external {
        // In a real scenario, this function would have access control
        // to ensure only the registered sourceAddress can call it.
        //  authorized source.
        DataSource storage source = s_dataSources[sourceId];
        if (bytes(source.description).length == 0) {
            revert InvalidDataSource(sourceId);
        }
        source.latestValue = value;
        source.latestTimestamp = timestamp;
        emit YieldDataUpdated(sourceId, value, timestamp);
    }

    /**
     * @inheritdoc IYieldOracle
     */
    function getLatestYieldData(uint256 sourceId) external view returns (uint256 value, uint256 timestamp) {
        DataSource storage source = s_dataSources[sourceId];
        if (bytes(source.description).length == 0) {
            revert InvalidDataSource(sourceId);
        }
        return (source.latestValue, source.latestTimestamp);
    }

    /**
     * @inheritdoc IYieldOracle
     */
    function getDataSourceDetails(uint256 sourceId) external view returns (string memory description, address sourceAddress) {
        DataSource storage source = s_dataSources[sourceId];
        if (bytes(source.description).length == 0) {
            revert InvalidDataSource(sourceId);
        }
        return (source.description, sourceAddress);
    }
}