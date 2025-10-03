// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface DataVisualizationAI {
    /**
     * @dev Emitted when a data visualization is successfully created.
     * @param visualizationId A unique identifier for the visualization.
     * @param visualizationType The type of visualization created (e.g., "Chart", "Graph", "Dashboard").
     * @param dataHash A hash of the data used for the visualization.
     * @param uri A URI or link to access the generated visualization.
     */
    event VisualizationCreated(bytes32 visualizationId, string visualizationType, bytes32 dataHash, string uri);

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
     * @dev Thrown when visualization creation fails.
     */
    error VisualizationCreationFailed(string reason);

    /**
     * @dev Creates a visual representation of given data.
     * This function would typically trigger an off-chain AI process to render charts, graphs, or dashboards.
     * @param visualizationType The desired type of visualization (e.g., "LineChart", "BarGraph", "Heatmap").
     * @param dataHash A hash of the data to be visualized, accessible off-chain.
     * @param parameters Specific parameters for visualization (e.g., axis labels, colors, time ranges).
     * @return visualizationId A unique identifier for the created visualization.
     * @return uri A URI or link to access the generated visualization.
     */
    function createVisualization(string calldata visualizationType, bytes32 dataHash, bytes calldata parameters) external returns (bytes32 visualizationId, string memory uri);

    /**
     * @dev Retrieves the underlying data used for a specific visualization.
     * @param visualizationId The unique identifier for the visualization.
     * @return dataHash A hash of the data used for the visualization.
     * @return dataType A string describing the type of data.
     */
    function getVisualizationData(bytes32 visualizationId) external view returns (bytes32 dataHash, string memory dataType);

    /**
     * @dev Updates an existing visualization with new data or parameters.
     * @param visualizationId The unique identifier for the visualization to update.
     * @param newDataHash A hash of the new data to be used (if applicable).
     * @param newParameters New parameters for rendering the visualization.
     * @return success True if the update was successful.
     */
    function updateVisualization(bytes32 visualizationId, bytes32 newDataHash, bytes calldata newParameters) external returns (bool success);

    /**
     * @dev Deletes a previously created visualization.
     * @param visualizationId The unique identifier for the visualization to delete.
     * @return success True if the deletion was successful.
     */
    function deleteVisualization(bytes32 visualizationId) external returns (bool success);
}