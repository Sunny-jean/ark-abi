// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ModelValidationAI - AI for model validation
/// @notice This interface defines functions for an AI system that validates the performance and integrity of AI models.
interface ModelValidationAI {
    /// @notice Validates a specific AI model against a set of criteria or a validation dataset.
    /// @param modelId The unique identifier of the model to validate.
    /// @param validationDatasetHash A hash of the dataset used for validation.
    /// @return isValid True if the model passes validation, false otherwise.
    /// @return validationReport A string detailing the validation outcome and any issues found.
    function validateModel(
        uint256 modelId,
        bytes32 validationDatasetHash
    ) external view returns (bool isValid, string memory validationReport);

    /// @notice Retrieves the latest validation report for a given model.
    /// @param modelId The unique identifier of the model.
    /// @return latestReport A string containing the latest validation report.
    /// @return timestamp The timestamp of the latest validation.
    function getLatestValidationReport(
        uint256 modelId
    ) external view returns (string memory latestReport, uint256 timestamp);

    /// @notice Event emitted when an AI model is validated.
    /// @param modelId The unique identifier of the model.
    /// @param isValid True if the model passed validation, false otherwise.
    /// @param timestamp The timestamp of the validation.
    event ModelValidated(
        uint256 indexed modelId,
        bool isValid,
        uint256 timestamp
    );

    /// @notice Error indicating that the model ID is invalid.
    error InvalidModelId(uint256 modelId);

    /// @notice Error indicating that the validation dataset is not found or invalid.
    error ValidationDatasetNotFound(bytes32 validationDatasetHash);

    /// @notice Error indicating a failure in the model validation process.
    error ModelValidationFailed(string message);
}