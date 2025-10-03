// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface APIConnector {
    /**
     * @dev Emitted when an external API request is made.
     * @param requestId The unique ID of the request.
     * @param endpoint The API endpoint being called.
     * @param caller The address that initiated the request.
     */
    event APIRequestMade(bytes32 indexed requestId, string indexed endpoint, address indexed caller);

    /**
     * @dev Emitted when a response is received from an external API.
     * @param requestId The unique ID of the request.
     * @param responseData The data received from the API.
     * @param statusCode The HTTP status code of the response.
     */
    event APIResponseReceived(bytes32 indexed requestId, bytes responseData, uint256 statusCode);

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
     * @dev Thrown when an API request with the given ID is not found.
     */
    error RequestNotFound(bytes32 requestId);

    /**
     * @dev Thrown when the API call fails (e.g., network error, invalid endpoint).
     */
    error APICallFailed(string endpoint, uint256 statusCode, string message);

    /**
     * @dev Makes a request to an external API.
     * @param endpoint The URL or identifier of the API endpoint.
     * @param method The HTTP method (e.g., "GET", "POST").
     * @param headers Optional HTTP headers in a JSON string format.
     * @param body Optional request body in bytes.
     * @param callbackAddress The address of the contract to call back with the result.
     * @param callbackFunctionSignature The signature of the function to call on the callbackAddress.
     * @return requestId The unique ID generated for this API request.
     */
    function makeAPIRequest(string calldata endpoint, string calldata method, string calldata headers, bytes calldata body, address callbackAddress, bytes4 callbackFunctionSignature) external returns (bytes32 requestId);

    /**
     * @dev Receives and processes the response from an external API.
     * This function is typically called by an authorized relayer or oracle.
     * @param requestId The unique ID of the API request.
     * @param responseData The raw response data from the API.
     * @param statusCode The HTTP status code of the response.
     */
    function fulfillAPIResponse(bytes32 requestId, bytes calldata responseData, uint256 statusCode) external;

    /**
     * @dev Retrieves the status and response data of a previously made API request.
     * @param requestId The unique ID of the API request.
     * @return responseData The raw response data.
     * @return statusCode The HTTP status code.
     * @return isCompleted True if the request has been completed, false otherwise.
     */
    function getAPIResponse(bytes32 requestId) external view returns (bytes memory responseData, uint256 statusCode, bool isCompleted);
}