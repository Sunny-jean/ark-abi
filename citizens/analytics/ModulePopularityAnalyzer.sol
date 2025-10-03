// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ModulePopularityAnalyzer {
    /**
     * @dev Emitted when a module's popularity score is updated.
     * @param moduleId The ID of the module.
     * @param newScore The new popularity score.
     */
    event PopularityScoreUpdated(bytes32 indexed moduleId, uint256 newScore);

    /**
     * @dev Emitted when a popularity analysis report is generated.
     * @param reportId The unique ID of the report.
     * @param reportHash A hash of the report content.
     */
    event PopularityReportGenerated(bytes32 indexed reportId, bytes32 reportHash);

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
     * @dev Thrown when a report is not found.
     */
    error ReportNotFound(bytes32 reportId);

    /**
     * @dev Analyzes module usage data to determine popularity scores.
     * This function is typically called by an off-chain process or a privileged account.
     * @param moduleId The unique ID of the module to analyze.
     * @param timeRange The time range over which to analyze popularity.
     */
    function analyzeModulePopularity(bytes32 moduleId, uint256 timeRange) external;

    /**
     * @dev Retrieves the current popularity score for a specific module.
     * @param moduleId The unique ID of the module.
     * @return popularityScore The calculated popularity score.
     */
    function getModulePopularityScore(bytes32 moduleId) external view returns (uint256 popularityScore);

    /**
     * @dev Generates a report detailing module popularity trends.
     * @param reportType The type of report to generate (e.g., "top_10_modules", "trending_modules").
     * @param timeRange The time range for the report.
     * @return reportId The unique ID of the generated report.
     */
    function generatePopularityReport(string calldata reportType, uint256 timeRange) external returns (bytes32 reportId);
}