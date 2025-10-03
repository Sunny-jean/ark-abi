// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface PredictiveReportingAI {
    /**
     * @dev Emitted when a predictive report is generated.
     * @param reportId A unique identifier for the report.
     * @param reportType The type of predictive report.
     * @param predictionHorizon The time horizon for the prediction (e.g., "1_day", "1_week").
     * @param reportHash A hash of the detailed predictive report.
     */
    event PredictiveReportGenerated(bytes32 reportId, string reportType, string predictionHorizon, bytes32 reportHash);

    /**
     * @dev Emitted when the accuracy of a past prediction is evaluated.
     * @param reportId The ID of the predictive report.
     * @param accuracy The accuracy score (e.g., 0-100).
     * @param evaluationDetails Details about the accuracy evaluation.
     */
    event PredictionAccuracyEvaluated(bytes32 reportId, uint256 accuracy, string evaluationDetails);

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
     * @dev Thrown when a predictive report generation fails.
     */
    error PredictiveReportFailed(string reason);

    /**
     * @dev Generates a predictive report based on historical data and current trends.
     * This function would typically trigger an off-chain AI model to forecast future states.
     * @param reportType The type of predictive report to generate (e.g., "FutureMarketTrends", "ResourceUtilizationForecast").
     * @param predictionHorizon The time horizon for the prediction (e.g., "1_day", "1_week", "1_month").
     * @param parameters Specific parameters for the prediction model.
     * @return reportId A unique identifier for the generated predictive report.
     * @return reportHash A hash of the detailed predictive report content.
     */
    function generatePredictiveReport(string calldata reportType, string calldata predictionHorizon, bytes calldata parameters) external returns (bytes32 reportId, bytes32 reportHash);

    /**
     * @dev Evaluates the accuracy of a previously generated predictive report against actual outcomes.
     * @param reportId The unique identifier of the predictive report to evaluate.
     * @param actualOutcomesHash A hash of the actual outcomes data for comparison.
     * @return accuracy The accuracy score of the prediction (e.g., 0-100).
     * @return evaluationDetails Details about the accuracy evaluation.
     */
    function getPredictionAccuracy(bytes32 reportId, bytes32 actualOutcomesHash) external returns (uint256 accuracy, string memory evaluationDetails);

    /**
     * @dev Retrieves the content of a generated predictive report.
     * @param reportId The unique identifier for the report.
     * @return reportContentUri A URI or link to access the report content.
     */
    function getPredictiveReportContent(bytes32 reportId) external view returns (string memory reportContentUri);

    /**
     * @dev Submits actual outcome data to be used for evaluating prediction accuracy.
     * @param reportId The ID of the predictive report this outcome data corresponds to.
     * @param outcomesDataHash A hash of the actual outcome data.
     */
    function submitActualOutcomes(bytes32 reportId, bytes32 outcomesDataHash) external;
}