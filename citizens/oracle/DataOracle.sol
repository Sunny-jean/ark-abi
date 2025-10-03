// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface DataOracle {
    /**
     * @dev Emitted when a new data point is published.
     * @param key The unique key identifying the data.
     * @param value The value of the data.
     * @param timestamp The timestamp when the data was published.
     */
    event DataPublished(bytes32 indexed key, bytes value, uint256 timestamp);

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
     * @dev Thrown when data for a given key is not available.
     */
    error DataNotAvailable(bytes32 key);

    /**
     * @dev Publishes a new data point to the oracle.
     * Only callable by authorized data providers.
     * @param key The unique key for the data.
     * @param value The data value.
     */
    function publishData(bytes32 key, bytes calldata value) external;

    /**
     * @dev Retrieves the latest data for a given key.
     * @param key The unique key for the data.
     * @return value The latest data value.
     * @return timestamp The timestamp when the data was last updated.
     */
    function getData(bytes32 key) external view returns (bytes memory value, uint256 timestamp);

    /**
     * @dev Retrieves a list of all available data keys.
     * @return keys An array of all data keys published by this oracle.
     */
    function getAllDataKeys() external view returns (bytes32[] memory keys);
}