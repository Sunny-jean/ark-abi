// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface UserInteractionAnalyzer {
    /**
     * @dev Emitted when a user interaction is recorded.
     * @param user The address of the user.
     * @param interactionType The type of interaction.
     * @param moduleId The ID of the module involved.
     */
    event InteractionRecorded(address indexed user, string indexed interactionType, bytes32 indexed moduleId);

    /**
     * @dev Emitted when an analysis report is generated.
     * @param reportId The unique ID of the report.
     * @param reportHash A hash of the report content.
     */
    event AnalysisReportGenerated(bytes32 indexed reportId, bytes32 reportHash);

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
     * @dev Thrown when the specified module is not found.
     */
    error ModuleNotFound(bytes32 moduleId);

    /**
     * @dev Thrown when an analysis report is not found.
     */
    error ReportNotFound(bytes32 reportId);

    /**
     * @dev Records a user interaction with a specific module or feature.
     * @param user The address of the user performing the interaction.
     * @param interactionType The type of interaction (e.g., "click", "view", "purchase", "share").
     * @param moduleId The unique ID of the module or feature interacted with.
     * @param interactionData Additional data related to the interaction.
     */
    function recordUserInteraction(address user, string calldata interactionType, bytes32 moduleId, bytes calldata interactionData) external;

    /**
     * @dev Generates an analysis report based on collected user interaction data.
     * @param analysisType The type of analysis to perform (e.g., "daily_summary", "module_popularity").
     * @param timeRange The time range for the analysis.
     * @return reportId The unique ID of the generated report.
     */
    function generateAnalysisReport(string calldata analysisType, uint256 timeRange) external returns (bytes32 reportId);

    /**
     * @dev Retrieves a previously generated analysis report.
     * @param reportId The unique ID of the report to retrieve.
     * @return reportContent The content of the analysis report.
     */
    function getAnalysisReport(bytes32 reportId) external view returns (bytes memory reportContent);
}