// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title DynamicAllocationAI - AI for dynamic asset allocation
/// @notice This interface defines functions for an AI system that provides dynamic asset allocation recommendations.
interface DynamicAllocationAI {
    struct AssetAllocation {
        string asset;
        uint256 percentage;
    }

    /// @notice Provides dynamic asset allocation recommendations based on real-time market conditions and predefined rules.
    /// @param currentMarketConditions A string describing current market conditions (e.g., "bull", "bear", "volatile").
    /// @param riskProfile A string describing the user's risk profile (e.g., "conservative", "moderate", "aggressive").
    /// @return recommendedAllocations An array of AssetAllocation structs representing the recommended percentage allocations.
    /// @return rationale A string explaining the rationale behind the recommendations.
    function getDynamicAllocation(
        string calldata currentMarketConditions,
        string calldata riskProfile
    ) external view returns (
        AssetAllocation[] memory recommendedAllocations,
        string memory rationale
    );

    /// @notice Updates the AI's allocation rules or parameters.
    /// @param newRules A string containing the new allocation rules or parameters.
    /// @return success True if the update was successful, false otherwise.
    function updateAllocationRules(
        string calldata newRules
    ) external returns (bool success);

    /// @notice Event emitted when dynamic allocation recommendations are provided.
    /// @param marketConditions The current market conditions.
    /// @param riskProfile The user's risk profile.
    /// @param timestamp The timestamp of the recommendation.
    event DynamicAllocationRecommended(
        string indexed marketConditions,
        string indexed riskProfile,
        uint256 timestamp
    );

    /// @notice Error indicating that market data is insufficient or invalid.
    error InvalidMarketData();

    /// @notice Error indicating a failure in the dynamic allocation process.
    error DynamicAllocationFailed(string message);
}