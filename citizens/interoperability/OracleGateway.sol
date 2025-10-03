// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface OracleGateway {
    /**
     * @dev Emitted when a new data request is made to the oracle.
     * @param requestId The unique ID of the data request.
     * @param consumer The address of the contract requesting data.
     * @param query The query string for the oracle.
     */
    event OracleRequest(bytes32 indexed requestId, address indexed consumer, string query);

    /**
     * @dev Emitted when data is received from the oracle.
     * @param requestId The unique ID of the data request.
     * @param data The data returned by the oracle.
     * @param timestamp The time when the data was received.
     */
    event OracleResponse(bytes32 indexed requestId, bytes data, uint256 timestamp);

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
     * @dev Thrown when an oracle request with the given ID is not found.
     */
    error RequestNotFound(bytes32 requestId);

    /**
     * @dev Thrown when the oracle query is invalid or not supported.
     */
    error InvalidQuery(string query);

    /**
     * @dev Requests data from an external oracle.
     * @param query The query string for the oracle (e.g., "ETH/USD_price", "module_popularity").
     * @param callbackAddress The address of the contract to call back with the result.
     * @param callbackFunctionSignature The signature of the function to call on the callbackAddress.
     * @return requestId The unique ID generated for this data request.
     */
    function requestData(string calldata query, address callbackAddress, bytes4 callbackFunctionSignature) external returns (bytes32 requestId);

    /**
     * @dev Receives data from the oracle and processes it.
     * This function is typically called by the oracle itself or an authorized relayer.
     * @param requestId The unique ID of the data request.
     * @param data The data returned by the oracle.
     */
    function fulfillRequest(bytes32 requestId, bytes calldata data) external;

    /**
     * @dev Retrieves the latest data for a specific query.
     * @param query The query string.
     * @return data The latest data received for the query.
     * @return timestamp The timestamp when the data was last updated.
     */
    function getLatestData(string calldata query) external view returns (bytes memory data, uint256 timestamp);
}