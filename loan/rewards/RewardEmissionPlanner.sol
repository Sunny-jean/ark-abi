// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRewardEmissionPlanner {
    // LP 激勵發放排程
    function scheduleEmission(uint256 _startTime, uint256 _endTime, uint256 _amount) external;
    function getScheduledEmission(uint256 _scheduleId) external view returns (uint256 startTime, uint256 endTime, uint256 amount);
    function cancelEmission(uint256 _scheduleId) external;

    event EmissionScheduled(uint256 indexed scheduleId, uint256 startTime, uint256 endTime, uint256 amount);
    event EmissionCancelled(uint256 indexed scheduleId);

    error InvalidSchedule();
}