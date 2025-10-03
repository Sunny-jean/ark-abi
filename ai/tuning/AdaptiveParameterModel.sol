// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title AdaptiveParameterModel - AI for adaptive parameter models
/// @notice This interface defines functions for an AI system that dynamically adjusts parameters based on real-time conditions.
interface AdaptiveParameterModel {
    struct AdjustedParameter {
        string name;
        uint256 value;
    }

    /// @notice Gets the current adaptive value for a specific parameter.
    /// @param parameterName The name of the parameter.
    /// @return currentValue The current adaptive value for the parameter.
    /// @return lastAdjusted The timestamp when the parameter was last adjusted.
    function getAdaptiveParameterValue(
        string calldata parameterName
    ) external view returns (uint256 currentValue, uint256 lastAdjusted);

    /// @notice Triggers the AI to re-evaluate and adjust parameters based on current system state.
    /// @param systemStateHash A hash representing the current system state.
    /// @return adjustedParameters An array of AdjustedParameter structs representing the newly adjusted values.
    /// @return adjustmentReport A string detailing the adjustments made and the reasons.
    function triggerParameterAdjustment(
        bytes32 systemStateHash
    ) external returns (
        AdjustedParameter[] memory adjustedParameters,
        string memory adjustmentReport
    );

    /// @notice Event emitted when an adaptive parameter is adjusted.
    /// @param parameterName The name of the parameter.
    /// @param newValue The new adjusted value.
    /// @param timestamp The timestamp of the adjustment.
    event ParameterAdjusted(
        string indexed parameterName,
        uint256 newValue,
        uint256 timestamp
    );

    /// @notice Error indicating that the parameter name is invalid.
    error InvalidParameterName(string parameterName);

    /// @notice Error indicating a failure in the adaptive parameter adjustment process.
    error AdaptiveAdjustmentFailed(string message);
}