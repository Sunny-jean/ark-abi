// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ForensicAnalysisAI {
    /**
     * @dev Emitted when a forensic analysis is initiated.
     * @param incidentId The ID of the incident under analysis.
     * @param analysisId A unique identifier for the analysis session.
     * @param initiatedBy The address that initiated the analysis.
     */
    event AnalysisInitiated(bytes32 incidentId, bytes32 analysisId, address initiatedBy);

    /**
     * @dev Emitted when forensic analysis results are available.
     * @param analysisId The unique identifier for the analysis session.
     * @param reportHash A hash of the detailed forensic report.
     * @param summary A brief summary of the findings.
     */
    event AnalysisResultsAvailable(bytes32 analysisId, bytes32 reportHash, string summary);

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
     * @dev Thrown when an incident is not found.
     */
    error IncidentNotFound(bytes32 incidentId);

    /**
     * @dev Initiates a forensic analysis on a specific incident or set of events.
     * This function would typically trigger an off-chain AI process to collect and analyze data.
     * @param incidentId The unique identifier of the incident to analyze.
     * @param scope A string defining the scope of the analysis (e.g., "transaction_logs", "system_state").
     * @return analysisId A unique identifier for the initiated analysis session.
     */
    function initiateForensicAnalysis(bytes32 incidentId, string calldata scope) external returns (bytes32 analysisId);

    /**
     * @dev Retrieves the results of a completed forensic analysis.
     * @param analysisId The unique identifier for the analysis session.
     * @return status The current status of the analysis (e.g., "InProgress", "Completed", "Failed").
     * @return reportHash A hash of the detailed forensic report if completed, otherwise zero.
     * @return summary A brief summary of the findings if completed.
     */
    function getAnalysisResults(bytes32 analysisId) external view returns (string memory status, bytes32 reportHash, string memory summary);

    /**
     * @dev Submits data relevant to an incident for forensic analysis.
     * This could be called by other system components or monitoring AIs.
     * @param incidentId The ID of the incident.
     * @param dataType The type of data being submitted (e.g., "log_file", "snapshot").
     * @param dataHash A hash of the data content.
     */
    function submitIncidentData(bytes32 incidentId, string calldata dataType, bytes32 dataHash) external;

    /**
     * @dev Marks an incident as resolved after forensic analysis and remediation.
     * @param incidentId The ID of the incident to resolve.
     * @param resolutionDetails A description of how the incident was resolved.
     */
    function resolveIncident(bytes32 incidentId, string calldata resolutionDetails) external;
}