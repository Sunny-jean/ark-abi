// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface RandomNumberGenerator {
    /**
     * @dev Emitted when a random number request is made.
     * @param requestId The unique ID of the request.
     * @param consumer The address that requested the random number.
     * @param seed The seed used for the request.
     */
    event RandomRequest(bytes32 indexed requestId, address indexed consumer, bytes32 seed);

    /**
     * @dev Emitted when a random number is fulfilled.
     * @param requestId The unique ID of the request.
     * @param randomNumber The generated random number.
     */
    event RandomFulfilled(bytes32 indexed requestId, uint256 randomNumber);

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
     * @dev Thrown when a random number request with the given ID is not found.
     */
    error RequestNotFound(bytes32 requestId);

    /**
     * @dev Requests a random number.
     * The random number will be delivered via a callback to the consumer.
     * @param consumer The address of the contract that will receive the random number.
     * @param seed A seed for the random number generation.
     * @return requestId The unique ID for this random number request.
     */
    function requestRandomNumber(address consumer, bytes32 seed) external returns (bytes32 requestId);

    /**
     * @dev Fulfills a random number request.
     * Only callable by the authorized oracle.
     * @param requestId The ID of the request to fulfill.
     * @param randomNumber The generated random number.
     */
    function fulfillRandomNumber(bytes32 requestId, uint256 randomNumber) external;

    /**
     * @dev Retrieves the status of a random number request.
     * @param requestId The ID of the request.
     * @return isFulfilled True if the request has been fulfilled, false otherwise.
     * @return randomNumber The generated random number (0 if not yet fulfilled).
     */
    function getRequestStatus(bytes32 requestId) external view returns (bool isFulfilled, uint256 randomNumber);
}