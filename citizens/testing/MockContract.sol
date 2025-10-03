// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface MockContract {
    /**
     * @dev Emitted when a function call is mocked.
     * @param functionSignature The signature of the mocked function.
     * @param mockData The data returned by the mock.
     */
    event FunctionMocked(bytes4 indexed functionSignature, bytes mockData);

    /**
     * @dev Emitted when a function call is reset.
     * @param functionSignature The signature of the reset function.
     */
    event FunctionReset(bytes4 indexed functionSignature);

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
     * @dev Mocks the return value of a specific function call.
     * @param functionSignature The 4-byte function signature (e.g., `this.myFunction.selector`).
     * @param mockData The bytes to return when the mocked function is called.
     */
    function mockFunction(bytes4 functionSignature, bytes calldata mockData) external;

    /**
     * @dev Resets the mock for a specific function, reverting to its original behavior.
     * @param functionSignature The 4-byte function signature.
     */
    function resetFunction(bytes4 functionSignature) external;

    /**
     * @dev Resets all mocked functions, reverting the contract to its original state.
     */
    function resetAll() external;

    /**
     * @dev Retrieves the mock data set for a specific function.
     * @param functionSignature The 4-byte function signature.
     * @return mockData The mock data set for the function.
     * @return isMocked True if the function is currently mocked, false otherwise.
     */
    function getMockData(bytes4 functionSignature) external view returns (bytes memory mockData, bool isMocked);
}