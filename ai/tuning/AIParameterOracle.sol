// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title AIParameterOracle - AI-powered parameter oracle
/// @notice This interface defines functions for an AI-powered oracle that provides and monitors optimal parameters.
interface AIParameterOracle {
    /// @notice Retrieves the current optimal value for a specific parameter.
    /// @param parameterName The name of the parameter.
    /// @return optimalValue The current optimal value for the parameter.
    /// @return lastUpdated The timestamp when the optimal value was last updated.
    function getOptimalParameterValue(
        string calldata parameterName
    ) external view returns (uint256 optimalValue, uint256 lastUpdated);

    /// @notice Submits a new optimal parameter value, typically after an AI tuning process.
    /// @param parameterName The name of the parameter.
    /// @param newValue The new optimal value.
    /// @return success True if the update was successful, false otherwise.
    function submitOptimalParameterValue(
        string calldata parameterName,
        uint256 newValue
    ) external returns (bool success);

    /// @notice Event emitted when an optimal parameter value is updated.
    /// @param parameterName The name of the parameter.
    /// @param newValue The new optimal value.
    /// @param timestamp The timestamp of the update.
    event OptimalParameterValueUpdated(
        string indexed parameterName,
        uint256 newValue,
        uint256 timestamp
    );

    /// @notice Error indicating that the parameter name is invalid.
    error InvalidParameterName(string parameterName);

    /// @notice Error indicating that the new value is outside acceptable bounds.
    error ValueOutOfBounds(uint256 newValue);

    /// @notice Error indicating a failure in the parameter oracle process.
    error ParameterOracleFailed(string message);
}