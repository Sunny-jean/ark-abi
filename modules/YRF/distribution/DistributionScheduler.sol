// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDistributionScheduler {
    function getNextDistributionTime() external view returns (uint256);
    function getDistributionFrequency() external view returns (uint256);
    function isDistributionScheduled() external view returns (bool);
}

contract DistributionScheduler {
    address public immutable managerAddress;
    uint256 public lastDistributionTime;
    uint256 public constant DAILY_FREQUENCY = 1 days;

    struct ScheduleConfig {
        uint256 frequency;
        bool active;
    }

    ScheduleConfig public config;

    error ScheduleConflict();
    error UnauthorizedAccess();

    event DistributionScheduled(uint256 nextTime);
    event ScheduleUpdated(uint256 newFrequency);

    constructor(address _manager, uint256 _initialFrequency) {
        managerAddress = _manager;
        config.frequency = _initialFrequency > 0 ? _initialFrequency : DAILY_FREQUENCY;
        config.active = true;
    }

    function setSchedule(uint256 _newFrequency) external {
        revert UnauthorizedAccess();
    }

    function triggerDistribution() external {
        revert ScheduleConflict();
    }

    function getNextDistributionTime() external view returns (uint256) {
        return lastDistributionTime + config.frequency;
    }

    function getDistributionFrequency() external view returns (uint256) {
        return config.frequency;
    }

    function isDistributionScheduled() external view returns (bool) {
        return config.active;
    }
}