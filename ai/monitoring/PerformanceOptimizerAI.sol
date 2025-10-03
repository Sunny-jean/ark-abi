// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface PerformanceOptimizerAI {
    /**
     * @dev Emitted when a performance analysis is completed.
     * @param timestamp The time at which the analysis was completed.
     * @param reportHash A hash of the detailed performance report.
     * @param summary A brief summary of the analysis findings.
     */
    event PerformanceAnalysisCompleted(uint256 timestamp, bytes32 reportHash, string summary);

    /**
     * @dev Emitted when optimization recommendations are generated.
     * @param timestamp The time at which recommendations were generated.
     * @param recommendationHash A hash of the detailed optimization recommendations.
     * @param impactEstimate An estimate of the performance improvement from applying recommendations.
     */
    event OptimizationRecommendationsGenerated(uint256 timestamp, bytes32 recommendationHash, string impactEstimate);

    /**
     * @dev Emitted when an optimization is applied or initiated.
     * @param optimizationId A unique identifier for the optimization.
     * @param description A description of the optimization applied.
     * @param success True if the optimization was successfully applied, false otherwise.
     */
    event OptimizationApplied(bytes32 optimizationId, string description, bool success);

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
     * @dev Thrown when a performance analysis fails to complete.
     */
    error AnalysisFailed(string reason);

    /**
     * @dev Analyzes the current system performance, identifying bottlenecks and inefficiencies.
     * This function would typically trigger an off-chain AI process to perform deep analysis.
     * @param scope A string defining the scope of the analysis (e.g., "overall", "specific_module", "transaction_type").
     * @return reportHash A hash of the detailed performance report, accessible off-chain.
     */
    function analyzePerformance(string calldata scope) external returns (bytes32 reportHash);

    /**
     * @dev Retrieves and recommends optimizations based on the latest performance analysis.
     * @param reportHash The hash of the performance report for which to generate recommendations.
     * @return recommendationHash A hash of the detailed optimization recommendations.
     * @return impactEstimate An estimate of the performance improvement from applying recommendations.
     */
    function recommendOptimizations(bytes32 reportHash) external returns (bytes32 recommendationHash, string memory impactEstimate);

    /**
     * @dev Applies a specific optimization or set of optimizations to the system.
     * This function might trigger an off-chain process to enact the changes.
     * @param optimizationId The unique identifier of the optimization to apply.
     * @param parameters Specific parameters required for applying the optimization.
     * @return success True if the optimization was successfully initiated/applied.
     */
    function applyOptimization(bytes32 optimizationId, bytes calldata parameters) external returns (bool success);

    /**
     * @dev Retrieves the status of a previously initiated optimization.
     * @param optimizationId The unique identifier of the optimization.
     * @return status A string describing the current status (e.g., "Pending", "InProgress", "Completed", "Failed").
     * @return details Additional details about the optimization status.
     */
    function getOptimizationStatus(bytes32 optimizationId) external view returns (string memory status, string memory details);
}