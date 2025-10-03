// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title AutomatedTradingAI - AI for automated trading
/// @notice This interface defines functions for an AI system that executes automated trading strategies.
interface AutomatedTradingAI {
    /// @notice Activates an automated trading strategy.
    /// @param strategyId The unique identifier of the trading strategy.
    /// @param parameters A string containing strategy-specific parameters (e.g., entry/exit points, volume limits).
    /// @return success True if the strategy was activated successfully, false otherwise.
    function activateStrategy(
        uint256 strategyId,
        string calldata parameters
    ) external returns (bool success);

    /// @notice Deactivates a running automated trading strategy.
    /// @param strategyId The unique identifier of the trading strategy.
    /// @return success True if the strategy was deactivated successfully, false otherwise.
    function deactivateStrategy(
        uint256 strategyId
    ) external returns (bool success);

    /// @notice Executes a trade based on AI recommendations.
    /// @param assetIn The identifier of the asset to sell.
    /// @param amountIn The amount of asset to sell.
    /// @param assetOut The identifier of the asset to buy.
    /// @param minAmountOut The minimum amount of assetOut to receive.
    /// @return actualAmountOut The actual amount of assetOut received.
    function executeTrade(
        string calldata assetIn,
        uint256 amountIn,
        string calldata assetOut,
        uint256 minAmountOut
    ) external returns (uint256 actualAmountOut);

    /// @notice Event emitted when a trading strategy is activated.
    /// @param strategyId The unique identifier of the strategy.
    /// @param timestamp The timestamp of activation.
    event StrategyActivated(
        uint256 indexed strategyId,
        uint256 timestamp
    );

    /// @notice Event emitted when a trading strategy is deactivated.
    /// @param strategyId The unique identifier of the strategy.
    /// @param timestamp The timestamp of deactivation.
    event StrategyDeactivated(
        uint256 indexed strategyId,
        uint256 timestamp
    );

    /// @notice Event emitted when a trade is executed by the AI.
    /// @param assetIn The asset sold.
    /// @param amountIn The amount sold.
    /// @param assetOut The asset bought.
    /// @param actualAmountOut The amount bought.
    /// @param timestamp The timestamp of the trade.
    event TradeExecuted(
        string indexed assetIn,
        uint256 amountIn,
        string indexed assetOut,
        uint256 actualAmountOut,
        uint256 timestamp
    );

    /// @notice Error indicating that the strategy ID is invalid.
    error InvalidStrategyId(uint256 strategyId);

    /// @notice Error indicating a failure during trade execution.
    error TradeExecutionFailed(string message);
}