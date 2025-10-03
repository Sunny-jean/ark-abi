// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title AssetRebalancingAI - AI for asset rebalancing
/// @notice This interface defines functions for an AI system that recommends and executes asset rebalancing strategies.
interface AssetRebalancingAI {
    struct AssetAmount {
        string asset;
        uint256 amount;
    }

    /// @notice Recommends an asset rebalancing strategy based on current portfolio and target allocations.
    /// @param currentPortfolio An array of AssetAmount structs representing the current portfolio.
    /// @param targetAllocations An array of AssetAmount structs representing the target percentage allocations.
    /// @return rebalancingPlan A string detailing the recommended rebalancing actions.
    /// @return estimatedGasCost The estimated gas cost for executing the rebalancing plan.
    function recommendRebalancing(
        AssetAmount[] calldata currentPortfolio,
        AssetAmount[] calldata targetAllocations
    ) external view returns (string memory rebalancingPlan, uint256 estimatedGasCost);

    /// @notice Executes a given rebalancing plan.
    /// @param rebalancingPlanHash A hash of the rebalancing plan to execute.
    /// @return success True if the execution was successful, false otherwise.
    function executeRebalancing(
        bytes32 rebalancingPlanHash
    ) external returns (bool success);

    /// @notice Event emitted when an asset rebalancing plan is recommended.
    /// @param rebalancingPlanHash A hash of the recommended plan.
    /// @param timestamp The timestamp of the recommendation.
    event RebalancingRecommended(
        bytes32 indexed rebalancingPlanHash,
        uint256 timestamp
    );

    /// @notice Event emitted when an asset rebalancing plan is executed.
    /// @param rebalancingPlanHash A hash of the executed plan.
    /// @param success True if successful, false otherwise.
    /// @param timestamp The timestamp of the execution.
    event RebalancingExecuted(
        bytes32 indexed rebalancingPlanHash,
        bool success,
        uint256 timestamp
    );

    /// @notice Error indicating that the rebalancing plan is invalid.
    error InvalidRebalancingPlan(bytes32 rebalancingPlanHash);

    /// @notice Error indicating a failure during rebalancing execution.
    error RebalancingExecutionFailed(string message);
}