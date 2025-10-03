// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ParameterTuningAgent - AI for intelligent parameter tuning
/// @notice This interface defines functions for an AI agent that intelligently tunes system parameters.
interface ParameterTuningAgent {
    struct RecommendedParameter {
        string name;
        uint256 value;
    }

    /// @notice Recommends optimal values for a set of parameters based on system performance goals.
    /// @param parameterNames An array of names of the parameters to tune.
    /// @param performanceGoals A string describing the performance goals (e.g., "maximize yield", "minimize risk").
    /// @return recommendedValues An array of RecommendedParameter structs representing their recommended optimal values.
    /// @return tuningReport A string detailing the tuning process and rationale.
    function recommendParameterValues(
        string[] calldata parameterNames,
        string calldata performanceGoals
    ) external view returns (
        RecommendedParameter[] memory recommendedValues,
        string memory tuningReport
    );

    /// @notice Applies the recommended parameter values to the system.
    /// @param recommendedValuesHash A hash of the recommended values to apply.
    /// @return success True if the application was successful, false otherwise.
    function applyParameterValues(
        bytes32 recommendedValuesHash
    ) external returns (bool success);

    /// @notice Event emitted when parameter values are recommended.
    /// @param tuningSessionId A unique ID for the tuning session.
    /// @param performanceGoals The performance goals for the tuning.
    /// @param timestamp The timestamp of the recommendation.
    event ParameterValuesRecommended(
        uint256 indexed tuningSessionId,
        string performanceGoals,
        uint256 timestamp
    );

    /// @notice Event emitted when recommended parameter values are applied.
    /// @param tuningSessionId A unique ID for the tuning session.
    /// @param success True if application was successful, false otherwise.
    /// @param timestamp The timestamp of the application.
    event ParameterValuesApplied(
        uint256 indexed tuningSessionId,
        bool success,
        uint256 timestamp
    );

    /// @notice Error indicating that the parameter names are invalid.
    error InvalidParameterNames();

    /// @notice Error indicating a failure in the parameter tuning process.
    error ParameterTuningFailed(string message);
}