// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title PortfolioOptimizationAI - AI for portfolio optimization
/// @notice This interface defines functions for an AI system that optimizes asset portfolios based on various criteria.
interface PortfolioOptimizationAI {
    struct AssetAmount {
        string asset;
        uint256 amount;
    }

    /// @notice Optimizes a portfolio based on specified risk tolerance and return goals.
    /// @param currentPortfolio An array of AssetAmount structs representing the current portfolio.
    /// @param riskTolerance A numerical value representing risk tolerance (e.g., 1-10).
    /// @param returnGoal A numerical value representing the desired return goal.
    /// @return optimizedPortfolio An array of AssetAmount structs representing the recommended optimized amounts.
    /// @return optimizationReport A string detailing the optimization process and results.
    function optimizePortfolio(
        AssetAmount[] calldata currentPortfolio,
        uint256 riskTolerance,
        uint256 returnGoal
    ) external view returns (
        AssetAmount[] memory optimizedPortfolio,
        string memory optimizationReport
    );

    /// @notice Retrieves historical optimization recommendations for a portfolio.
    /// @param portfolioHash A hash identifying the portfolio.
    /// @return historicalOptimizations An array of strings, each representing a past optimization report.
    function getHistoricalOptimizations(
        bytes32 portfolioHash
    ) external view returns (string[] memory historicalOptimizations);

    /// @notice Event emitted when a portfolio is optimized.
    /// @param portfolioHash A hash identifying the portfolio.
    /// @param timestamp The timestamp of the optimization.
    event PortfolioOptimized(
        bytes32 indexed portfolioHash,
        uint256 timestamp
    );

    /// @notice Error indicating that portfolio data is invalid or insufficient.
    error InvalidPortfolioData();

    /// @notice Error indicating a failure in the portfolio optimization process.
    error PortfolioOptimizationFailed(string message);
}