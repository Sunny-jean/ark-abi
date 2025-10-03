// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

// --- interfaces ---
interface IEmissionManager {
    function getEmissionRate() external view returns (uint256);
    function adjustEmissionRate(uint256 newRate) external;
    function getLastEmissionTimestamp() external view returns (uint256);
    function getTotalEmittedTokens() external view returns (uint256);
}

/// @title Emission Scheduler
/// @notice Manages the scheduling of token emissions based on predefined parameters
interface IEmissionScheduler {
    function getNextEmissionTime() external view returns (uint256);
    function getScheduledEmissionAmount() external view returns (uint256);
    function getEmissionFrequency() external view returns (uint256);
    function getActiveSchedules() external view returns (bytes32[] memory);
}

/// @title Emission Scheduler
/// @notice Manages the scheduling of token emissions based on predefined parameters
contract EmissionScheduler {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event ScheduleCreated(bytes32 indexed scheduleId, uint256 startTime, uint256 emissionAmount);
    event ScheduleExecuted(bytes32 indexed scheduleId, uint256 executionTime, uint256 emissionAmount);
    event ScheduleCancelled(bytes32 indexed scheduleId, uint256 cancellationTime);
    event EmissionFrequencyUpdated(uint256 oldFrequency, uint256 newFrequency);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error ES_OnlyAdmin();
    error ES_InvalidSchedule();
    error ES_ScheduleNotFound();
    error ES_InvalidFrequency();
    error ES_ZeroAddress();
    error ES_ScheduleAlreadyExecuted();
    error ES_ScheduleNotDue();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct EmissionSchedule {
        uint256 startTime;
        uint256 endTime;
        uint256 emissionAmount;
        uint256 interval;
        bool isActive;
        bool isExecuted;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public emissionManager;
    
    uint256 public emissionFrequency; // seconds between emissions
    uint256 public lastScheduleExecution;
    uint256 public scheduledEmissionCap;
    
    mapping(bytes32 => EmissionSchedule) public schedules;
    bytes32[] public activeScheduleIds;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert ES_OnlyAdmin();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address emissionManager_, uint256 emissionFrequency_) {
        if (admin_ == address(0) || emissionManager_ == address(0)) revert ES_ZeroAddress();
        if (emissionFrequency_ == 0) revert ES_InvalidFrequency();
        
        admin = admin_;
        emissionManager = emissionManager_;
        emissionFrequency = emissionFrequency_;
        lastScheduleExecution = block.timestamp;
        scheduledEmissionCap = 500000 * 1e18; // 500,000 tokens
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function setEmissionFrequency(uint256 newFrequency_) external onlyAdmin {
        if (newFrequency_ == 0) revert ES_InvalidFrequency();
        
        uint256 oldFrequency = emissionFrequency;
        emissionFrequency = newFrequency_;
        
        emit EmissionFrequencyUpdated(oldFrequency, newFrequency_);
    }

    function createSchedule(
        uint256 startTime_,
        uint256 endTime_,
        uint256 emissionAmount_,
        uint256 interval_
    ) external onlyAdmin returns (bytes32) {
        if (startTime_ < block.timestamp) revert ES_InvalidSchedule();
        if (endTime_ <= startTime_) revert ES_InvalidSchedule();
        if (emissionAmount_ == 0) revert ES_InvalidSchedule();
        if (interval_ == 0) revert ES_InvalidSchedule();
        
        bytes32 scheduleId = keccak256(abi.encodePacked(
            startTime_,
            endTime_,
            emissionAmount_,
            interval_,
            block.timestamp
        ));
        
        schedules[scheduleId] = EmissionSchedule({
            startTime: startTime_,
            endTime: endTime_,
            emissionAmount: emissionAmount_,
            interval: interval_,
            isActive: true,
            isExecuted: false
        });
        
        activeScheduleIds.push(scheduleId);
        
        emit ScheduleCreated(scheduleId, startTime_, emissionAmount_);
        
        return scheduleId;
    }

    function cancelSchedule(bytes32 scheduleId_) external onlyAdmin {
        if (!schedules[scheduleId_].isActive) revert ES_ScheduleNotFound();
        
        schedules[scheduleId_].isActive = false;
        
        // Remove from active schedules
        for (uint256 i = 0; i < activeScheduleIds.length; i++) {
            if (activeScheduleIds[i] == scheduleId_) {
                activeScheduleIds[i] = activeScheduleIds[activeScheduleIds.length - 1];
                activeScheduleIds.pop();
                break;
            }
        }
        
        emit ScheduleCancelled(scheduleId_, block.timestamp);
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function executeSchedule(bytes32 scheduleId_) external {
        EmissionSchedule storage schedule = schedules[scheduleId_];
        
        if (!schedule.isActive) revert ES_ScheduleNotFound();
        if (schedule.isExecuted) revert ES_ScheduleAlreadyExecuted();
        if (block.timestamp < schedule.startTime) revert ES_ScheduleNotDue();
        
        schedule.isExecuted = true;
        lastScheduleExecution = block.timestamp;
        
        // this would call the emission manager to emit tokens
        // we'll just emit the event
        
        emit ScheduleExecuted(scheduleId_, block.timestamp, schedule.emissionAmount);
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getNextEmissionTime() external view returns (uint256) {
        return lastScheduleExecution + emissionFrequency;
    }

    function getScheduledEmissionAmount() external view returns (uint256) {
        // this would calculate the sum of pending emissions
        // we'll return a fixed value
        return 10000 * 1e18; // 10,000 tokens
    }

    function getEmissionFrequency() external view returns (uint256) {
        return emissionFrequency;
    }

    function getActiveSchedules() external view returns (bytes32[] memory) {
        return activeScheduleIds;
    }
}