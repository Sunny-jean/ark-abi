// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ParameterValidationAI - AI for parameter validation
/// @notice This interface defines functions for an AI system that validates proposed parameter changes for rationality and safety.
interface ParameterValidationAI {
    /// @notice Validates a proposed parameter change.
    /// @param parameterName The name of the parameter.
    /// @param proposedValue The proposed new value for the parameter.
    /// @return isValid True if the proposed value is valid, false otherwise.
    /// @return validationReport A string detailing the validation outcome and any issues found.
    function validateParameterChange(
        string calldata parameterName,
        uint256 proposedValue
    ) external view returns (bool isValid, string memory validationReport);

    /// @notice Sets or updates validation rules for a specific parameter.
    /// @param parameterName The name of the parameter.
    /// @param rulesHash A hash of the new validation rules.
    /// @return success True if the rules were updated successfully, false otherwise.
    function setValidationRules(
        string calldata parameterName,
        bytes32 rulesHash
    ) external returns (bool success);

    /// @notice Event emitted when a parameter change is validated.
    /// @param parameterName The name of the parameter.
    /// @param proposedValue The proposed value.
    /// @param isValid True if valid, false otherwise.
    /// @param timestamp The timestamp of the validation.
    event ParameterChangeValidated(
        string indexed parameterName,
        uint256 proposedValue,
        bool isValid,
        uint256 timestamp
    );

    /// @notice Error indicating that the parameter name is invalid.
    error InvalidParameterName(string parameterName);

    /// @notice Error indicating that the proposed value is out of bounds or violates rules.
    error ValueValidationFailed(string message);

    /// @notice Error indicating a failure in the parameter validation process.
    error ParameterValidationFailed(string message);
}