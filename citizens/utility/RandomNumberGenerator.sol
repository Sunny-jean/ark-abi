// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface RandomNumberGenerator {
    /**
     * @dev Emitted when a random number request is made.
     * @param requestId The unique ID of the request.
     * @param consumer The address of the contract requesting the random number.
     * @param seed The seed used for the random number generation.
     */
    event RandomRequest(bytes32 indexed requestId, address indexed consumer, bytes32 seed);

    /**
     * @dev Emitted when a random number is generated and fulfilled.
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
     * @dev Thrown when the random number generation fails.
     */
    error GenerationFailed(bytes32 requestId, string reason);

    /**
     * @dev Requests a random number.
     * @param seed A seed value to influence the randomness (e.g., block hash, timestamp).
     * @param callbackAddress The address of the contract to call back with the result.
     * @param callbackFunctionSignature The signature of the function to call on the callbackAddress.
     * @return requestId The unique ID generated for this random number request.
     */
    function requestRandomNumber(bytes32 seed, address callbackAddress, bytes4 callbackFunctionSignature) external returns (bytes32 requestId);

    /**
     * @dev Fulfills a random number request.
     * This function is typically called by an authorized oracle or VRF provider.
     * @param requestId The unique ID of the request.
     * @param randomNumber The generated random number.
     */
    function fulfillRandomNumber(bytes32 requestId, uint256 randomNumber) external;

    /**
     * @dev Retrieves a previously generated random number.
     * @param requestId The unique ID of the request.
     * @return randomNumber The generated random number.
     * @return isFulfilled True if the request has been fulfilled, false otherwise.
     */
    function getRandomNumber(bytes32 requestId) external view returns (uint256 randomNumber, bool isFulfilled);
}