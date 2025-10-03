// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title DecisionModelEvaluator - interface for evaluating AI decision models
/// @notice This interface defines functions for assessing the performance and reliability of AI decision-making models.
interface DecisionModelEvaluator {
    /// @notice Evaluates a specific AI decision model based on a dataset.
    /// @param modelId The unique identifier of the AI model to evaluate.
    /// @param datasetHash A hash of the dataset used for evaluation.
    /// @return accuracy The accuracy score of the model (e.g., 0-10000 for 0-100%).
    /// @return precision The precision score of the model.
    /// @return recall The recall score of the model.
    /// @return f1Score The F1 score of the model.
    /// @return evaluationReport A string containing a detailed report of the evaluation.
    function evaluateModel(
        uint256 modelId,
        bytes32 datasetHash
    ) external view returns (
        uint256 accuracy,
        uint256 precision,
        uint256 recall,
        uint256 f1Score,
        string memory evaluationReport
    );

    /// @notice Compares the performance of two AI decision models.
    /// @param modelId1 The ID of the first model.
    /// @param modelId2 The ID of the second model.
    /// @param datasetHash A hash of the dataset used for comparison.
    /// @return comparisonReport A string detailing the comparison results.
    function compareModels(
        uint256 modelId1,
        uint256 modelId2,
        bytes32 datasetHash
    ) external view returns (string memory comparisonReport);

    /// @notice Retrieves the historical evaluation results for a given model.
    /// @param modelId The unique identifier of the AI model.
    /// @return historicalEvaluations An array of strings, each representing a past evaluation report.
    function getHistoricalEvaluations(
        uint256 modelId
    ) external view returns (string[] memory historicalEvaluations);

    /// @notice Event emitted when an AI decision model is evaluated.
    /// @param modelId The unique identifier of the model.
    /// @param datasetHash The hash of the dataset used.
    /// @param accuracy The accuracy score.
    /// @param evaluationReport The detailed evaluation report.
    event ModelEvaluated(
        uint256 indexed modelId,
        bytes32 indexed datasetHash,
        uint256 accuracy,
        string evaluationReport
    );

    /// @notice Event emitted when two AI decision models are compared.
    /// @param modelId1 The ID of the first model.
    /// @param modelId2 The ID of the second model.
    /// @param comparisonReport The comparison results.
    event ModelsCompared(
        uint256 indexed modelId1,
        uint256 indexed modelId2,
        string comparisonReport
    );

    /// @notice Error indicating that the model ID is invalid.
    error InvalidModelId(uint256 modelId);

    /// @notice Error indicating that the dataset is not found or invalid.
    error DatasetNotFound(bytes32 datasetHash);

    /// @notice Error indicating a failure during the evaluation process.
    error EvaluationFailed(string message);
}