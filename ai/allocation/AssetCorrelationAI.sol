// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title AssetCorrelationAI - AI for asset correlation analysis
/// @notice This interface defines functions for an AI system that analyzes correlations between different assets.
interface AssetCorrelationAI {
    /// @notice Analyzes the correlation between two specified assets over a given period.
    /// @param asset1Identifier The identifier of the first asset.
    /// @param asset2Identifier The identifier of the second asset.
    /// @param period The time period over which to calculate correlation.
    /// @return correlationCoefficient A numerical value representing the correlation (e.g., -1.0 to 1.0).
    /// @return analysisDetails A string providing details about the correlation analysis.
    function analyzeAssetCorrelation(
        string calldata asset1Identifier,
        string calldata asset2Identifier,
        uint256 period
    ) external view returns (int256 correlationCoefficient, string memory analysisDetails);

    /// @notice Retrieves a matrix of correlations for a set of assets.
    /// @param assetIdentifiers An array of asset identifiers.
    /// @param period The time period for correlation calculation.
    /// @return correlationMatrix A string representation of the correlation matrix.
    function getCorrelationMatrix(
        string[] calldata assetIdentifiers,
        uint256 period
    ) external view returns (string memory correlationMatrix);

    /// @notice Event emitted when asset correlation is analyzed.
    /// @param asset1Identifier The identifier of the first asset.
    /// @param asset2Identifier The identifier of the second asset.
    /// @param correlationCoefficient The calculated correlation coefficient.
    /// @param timestamp The timestamp of the analysis.
    event AssetCorrelationAnalyzed(
        string indexed asset1Identifier,
        string indexed asset2Identifier,
        int256 correlationCoefficient,
        uint256 timestamp
    );

    /// @notice Error indicating that an asset identifier is invalid.
    error InvalidAssetIdentifier(string assetIdentifier);

    /// @notice Error indicating that correlation data is insufficient or unavailable.
    error InsufficientCorrelationData();

    /// @notice Error indicating a failure in the asset correlation analysis process.
    error AssetCorrelationAnalysisFailed(string message);
}