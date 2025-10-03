// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IPeriodicCapScheduler {
    enum PeriodType { Daily, Weekly, Monthly }

    event ScheduleSet(PeriodType indexed periodType, uint256 indexed value, uint256 indexed nextExecutionTime);
    event CapScheduled(uint256 newCap, uint256 scheduledTime);

    error InvalidPeriodType();
    error ScheduleAlreadyExists();
    error NoActiveSchedule();

    function setSchedule(PeriodType _periodType, uint256 _value) external;
    function executeScheduledCap() external;
    function getNextScheduledCap() external view returns (uint256);
    function getNextExecutionTime() external view returns (uint256);
}

contract PeriodicCapScheduler is IPeriodicCapScheduler, Ownable {
    PeriodType private s_periodType;
    uint256 private s_scheduleValue;
    uint256 private s_nextExecutionTime;
    uint256 private s_scheduledCap;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function setSchedule(PeriodType _periodType, uint256 _value) external onlyOwner {
        require(uint256(_periodType) <= uint256(PeriodType.Monthly), "InvalidPeriodType");
        s_periodType = _periodType;
        s_scheduleValue = _value;
        s_nextExecutionTime = _calculateNextExecutionTime(_periodType);
        s_scheduledCap = _value; // For simplicity, the scheduled cap is the value itself
        emit ScheduleSet(_periodType, _value, s_nextExecutionTime);
    }

    function executeScheduledCap() external onlyOwner {
        require(s_nextExecutionTime != 0, "NoActiveSchedule");
        require(block.timestamp >= s_nextExecutionTime, "Not yet time to execute");

        // In a real scenario, this would interact with MintCapGuard or MintingCapAdjuster
        // For now, we'll just emit an event and update the next execution time.
        emit CapScheduled(s_scheduledCap, block.timestamp);

        s_nextExecutionTime = _calculateNextExecutionTime(s_periodType);
    }

    function getNextScheduledCap() external view returns (uint256) {
        return s_scheduledCap;
    }

    function getNextExecutionTime() external view returns (uint256) {
        return s_nextExecutionTime;
    }

    function _calculateNextExecutionTime(PeriodType _periodType) internal view returns (uint256) {
        uint256 currentTime = block.timestamp;
        if (_periodType == PeriodType.Daily) {
            return currentTime + 1 days;
        } else if (_periodType == PeriodType.Weekly) {
            return currentTime + 7 days;
        } else if (_periodType == PeriodType.Monthly) {
            return currentTime + 30 days; // Approximation for monthly
        } else {
            revert InvalidPeriodType();
        }
    }
}