// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAIOracle {
    /**
     * @dev Emitted when a data request is made to the oracle.
     * @param requestId A unique identifier for the data request.
     * @param dataSource The identifier of the data source being queried.
     * @param queryHash A hash of the specific query parameters.
     */
    event DataRequested(bytes32 requestId, string dataSource, bytes32 queryHash);

    /**
     * @dev Emitted when data is successfully retrieved and provided by the oracle.
     * @param requestId The unique identifier for the data request.
     * @param dataHash A hash of the retrieved data.
     * @param timestamp The time at which the data was retrieved.
     */
    event DataProvided(bytes32 requestId, bytes32 dataHash, uint256 timestamp);

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
     * @dev Thrown when the oracle fails to retrieve data for a given request.
     */
    error DataRetrievalFailed(bytes32 requestId, string reason);

    /**
     * @dev Requests data from the AI oracle based on specific parameters.
     * This function would typically trigger an off-chain AI process to fetch and process data.
     * @param dataSource The identifier of the data source to query (e.g., "MarketData", "NewsFeeds").
     * @param queryParameters Specific parameters for the data query (e.g., asset symbol, date range).
     * @return requestId A unique identifier for the data request.
     */
    function requestData(string calldata dataSource, bytes calldata queryParameters) external returns (bytes32 requestId);

    /**
     * @dev Retrieves the data associated with a previously made request.
     * @param requestId The unique identifier for the data request.
     * @return status The current status of the request (e.g., "Pending", "Fulfilled", "Failed").
     * @return dataHash A hash of the retrieved data if available, otherwise zero.
     * @return timestamp The time at which the data was provided if available, otherwise zero.
     */
    function retrieveData(bytes32 requestId) external view returns (string memory status, bytes32 dataHash, uint256 timestamp);

    /**
     * @dev Allows an authorized data provider to submit data to the oracle for a given request.
     * This function would typically be called by an off-chain oracle service.
     * @param requestId The unique identifier for the data request.
     * @param data The actual data to be provided.
     */
    function fulfillRequest(bytes32 requestId, bytes calldata data) external;

    /**
     * @dev Sets the data sources that the AI oracle is authorized to query.
     * @param sources An array of data source identifiers.
     */
    function setAuthorizedDataSources(string[] calldata sources) external;
}