// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEpochManager {
    event EpochStarted(uint256 indexed epochId, uint256 startTime);
    event EpochEnded(uint256 indexed epochId, uint256 endTime);

    error InvalidEpochId(uint256 epochId);
    error EpochAlreadyActive(uint256 epochId);

    function startNewEpoch() external returns (uint256);
    function endCurrentEpoch() external;
    function getCurrentEpoch() external view returns (uint256);
    function getEpochStartTime(uint256 _epochId) external view returns (uint256);
    function getEpochEndTime(uint256 _epochId) external view returns (uint256);
}