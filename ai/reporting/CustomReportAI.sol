// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface CustomReportAI {
    /**
     * @dev Emitted when a custom report definition is created or updated.
     * @param definitionId A unique identifier for the report definition.
     * @param definedBy The address that defined the report.
     * @param name The name of the custom report.
     */
    event CustomReportDefinitionUpdated(bytes32 definitionId, address definedBy, string name);

    /**
     * @dev Emitted when a custom report is generated.
     * @param reportId A unique identifier for the generated report.
     * @param definitionId The ID of the report definition used.
     * @param reportHash A hash of the generated report content.
     */
    event CustomReportGenerated(bytes32 reportId, bytes32 definitionId, bytes32 reportHash);

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
     * @dev Thrown when a custom report definition is not found.
     */
    error ReportDefinitionNotFound(bytes32 definitionId);

    /**
     * @dev Creates a custom report based on a user-defined report definition.
     * This function allows users to specify criteria, data sources, and output formats.
     * @param definitionId The unique identifier of the custom report definition.
     * @param parameters Specific parameters for this report generation instance (e.g., date range).
     * @return reportId A unique identifier for the newly generated custom report.
     * @return reportHash A hash of the generated report content.
     */
    function createCustomReport(bytes32 definitionId, bytes calldata parameters) external returns (bytes32 reportId, bytes32 reportHash);

    /**
     * @dev Defines or updates a custom report structure and its data sources.
     * @param definitionId A unique identifier for this report definition.
     * @param name The name of the custom report.
     * @param description A description of what the report covers.
     * @param queryParameters The parameters defining the data query (e.g., JSON string).
     * @param outputFormat The desired output format (e.g., "CSV", "PDF", "JSON").
     */
    function defineCustomReport(bytes32 definitionId, string calldata name, string calldata description, bytes calldata queryParameters, string calldata outputFormat) external;

    /**
     * @dev Retrieves the definition of a custom report.
     * @param definitionId The unique identifier for the report definition.
     * @return name The name of the custom report.
     * @return description A description of what the report covers.
     * @return queryParameters The parameters defining the data query.
     * @return outputFormat The desired output format.
     */
    function getCustomReportDefinition(bytes32 definitionId) external view returns (string memory name, string memory description, bytes memory queryParameters, string memory outputFormat);

    /**
     * @dev Retrieves the content of a generated custom report.
     * @param reportId The unique identifier for the report.
     * @return reportContentUri A URI or link to access the report content.
     */
    function getCustomReportContent(bytes32 reportId) external view returns (string memory reportContentUri);
}