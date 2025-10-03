// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ParameterControl {
    /**
     * @dev Emitted when a governance parameter is updated.
     * @param parameterName The name of the parameter that was updated.
     * @param oldValue The previous value of the parameter.
     * @param newValue The new value of the parameter.
     */
    event ParameterUpdated(string indexed parameterName, bytes oldValue, bytes newValue);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a parameter with the given name is not found.
     */
    error ParameterNotFound(string parameterName);

    /**
     * @dev Thrown when an attempt is made to set a parameter to an invalid value.
     */
    error InvalidParameterValue(string parameterName, bytes providedValue);

    /**
     * @dev Updates the value of a specific governance parameter.
     * Only callable by authorized governance entities.
     * @param parameterName The name of the parameter to update.
     * @param newValue The new value for the parameter.
     */
    function updateParameter(string calldata parameterName, bytes calldata newValue) external;

    /**
     * @dev Retrieves the current value of a governance parameter.
     * @param parameterName The name of the parameter to query.
     * @return value The current value of the parameter.
     */
    function getParameter(string calldata parameterName) external view returns (bytes memory value);

    /**
     * @dev Retrieves a list of all available governance parameters.
     * @return parameterNames An array of all parameter names.
     */
    function getAllParameterNames() external view returns (string[] memory parameterNames);
}