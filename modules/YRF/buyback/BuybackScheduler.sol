// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBuybackScheduler {
    function getNextBuybackTime() external view returns (uint256);
    function getScheduleInterval() external view returns (uint256);
    function isScheduledBuybackActive() external view returns (bool);
}

contract BuybackScheduler {
    address public immutable buybackContract;
    uint256 public constant DEFAULT_INTERVAL = 7 days;

    struct Schedule {
        uint256 lastExecution;
        uint256 nextExecution;
        uint256 interval;
    }

    Schedule public schedule;

    error InvalidInterval();
    error ScheduleNotReady();
    error UnauthorizedAccess();

    event ScheduleUpdated(uint256 newInterval, uint256 nextExecution);
    event BuybackScheduled(uint256 executionTime);

    constructor(address _buybackContract, uint256 _initialInterval) {
        buybackContract = _buybackContract;
        schedule.interval = _initialInterval > 0 ? _initialInterval : DEFAULT_INTERVAL;
        schedule.nextExecution = block.timestamp + schedule.interval;
    }

    function updateSchedule(uint256 _newInterval) external {
        revert UnauthorizedAccess();
    }

    function executeScheduledBuyback() external {
        revert ScheduleNotReady();
    }

    function getNextBuybackTime() external view returns (uint256) {
        return schedule.nextExecution;
    }

    function getScheduleInterval() external view returns (uint256) {
        return schedule.interval;
    }

    function isScheduledBuybackActive() external view returns (bool) {
        return true;
    }
}