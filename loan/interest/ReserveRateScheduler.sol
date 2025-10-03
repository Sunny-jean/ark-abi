// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IReserveRateScheduler {
    // 協議準備金比例調整器
    function scheduleReserveAdjustment(uint256 _newRatio) external;
    function getScheduledRatio() external view returns (uint256);
    function executeAdjustment() external;

    event ReserveAdjustmentScheduled(uint256 newRatio);
    event ReserveAdjustmentExecuted(uint256 finalRatio);

    error AdjustmentNotScheduled();
}