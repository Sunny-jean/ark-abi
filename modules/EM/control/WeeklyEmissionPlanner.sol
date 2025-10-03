// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

// --- interfaces ---
interface IEmissionManager {
    function getEmissionRate() external view returns (uint256);
    function adjustEmissionRate(uint256 newRate) external;
}

/// @title Weekly Emission Planner interface
/// @notice interface for the weekly emission planner contract
interface IWeeklyEmissionPlanner {
    function getWeeklyEmissionCap() external view returns (uint256);
    function getCurrentWeekNumber() external view returns (uint256);
    function getWeeklyPlan(uint256 weekNumber) external view returns (uint256[] memory);
    function getWeeklyEmissionUsed(uint256 weekNumber) external view returns (uint256);
}

/// @title Weekly Emission Planner
/// @notice Plans and manages weekly token emission schedules
contract WeeklyEmissionPlanner {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event WeeklyCapUpdated(uint256 oldCap, uint256 newCap);
    event WeeklyPlanCreated(uint256 indexed weekNumber, uint256[] dailyAllocations);
    event WeeklyPlanUpdated(uint256 indexed weekNumber, uint256[] dailyAllocations);
    event EmissionRecorded(uint256 indexed weekNumber, uint256 indexed dayOfWeek, uint256 amount);
    event WeekRolledOver(uint256 indexed previousWeek, uint256 indexed newWeek, uint256 unusedEmission);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error WEP_OnlyAdmin();
    error WEP_OnlyAuthorized();
    error WEP_ZeroAddress();
    error WEP_InvalidAmount();
    error WEP_InvalidWeek();
    error WEP_InvalidDayOfWeek();
    error WEP_InvalidAllocation();
    error WEP_WeeklyCapExceeded();
    error WEP_PlanAlreadyExists();
    error WEP_PlanNotFound();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct WeeklyPlan {
        uint256[] dailyAllocations; // 7 elements, one for each day of the week
        uint256 totalAllocated;
        uint256 totalUsed;
        bool exists;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public emissionManager;
    
    uint256 public weeklyEmissionCap;
    uint256 public currentWeekNumber;
    uint256 public weekStartTimestamp;
    uint256 public constant WEEK_IN_SECONDS = 604800; // 7 days
    uint256 public constant DAYS_IN_WEEK = 7;
    
    mapping(uint256 => WeeklyPlan) public weeklyPlans; // week number => plan
    mapping(address => bool) public authorizedPlanners;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert WEP_OnlyAdmin();
        _;
    }

    modifier onlyAuthorized() {
        if (!authorizedPlanners[msg.sender] && msg.sender != admin) revert WEP_OnlyAuthorized();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address emissionManager_, uint256 weeklyEmissionCap_) {
        if (admin_ == address(0) || emissionManager_ == address(0)) revert WEP_ZeroAddress();
        if (weeklyEmissionCap_ == 0) revert WEP_InvalidAmount();
        
        admin = admin_;
        emissionManager = emissionManager_;
        weeklyEmissionCap = weeklyEmissionCap_;
        
        // Calculate current week number (weeks since Unix epoch)
        currentWeekNumber = block.timestamp / WEEK_IN_SECONDS;
        weekStartTimestamp = currentWeekNumber * WEEK_IN_SECONDS;
        
        // Authorize admin as a planner
        authorizedPlanners[admin_] = true;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function setWeeklyEmissionCap(uint256 newCap_) external onlyAdmin {
        if (newCap_ == 0) revert WEP_InvalidAmount();
        
        uint256 oldCap = weeklyEmissionCap;
        weeklyEmissionCap = newCap_;
        
        emit WeeklyCapUpdated(oldCap, newCap_);
    }

    function authorizeWeeklyPlanner(address planner_) external onlyAdmin {
        if (planner_ == address(0)) revert WEP_ZeroAddress();
        authorizedPlanners[planner_] = true;
    }

    function revokeWeeklyPlanner(address planner_) external onlyAdmin {
        if (planner_ == address(0)) revert WEP_ZeroAddress();
        if (planner_ == admin) revert WEP_OnlyAdmin(); // Cannot revoke admin
        authorizedPlanners[planner_] = false;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function createWeeklyPlan(uint256 weekNumber_, uint256[] calldata dailyAllocations_) external onlyAuthorized {
        if (weekNumber_ < currentWeekNumber) revert WEP_InvalidWeek();
        if (dailyAllocations_.length != DAYS_IN_WEEK) revert WEP_InvalidDayOfWeek();
        if (weeklyPlans[weekNumber_].exists) revert WEP_PlanAlreadyExists();
        
        uint256 totalAllocated = 0;
        for (uint256 i = 0; i < DAYS_IN_WEEK; i++) {
            totalAllocated += dailyAllocations_[i];
        }
        
        if (totalAllocated > weeklyEmissionCap) revert WEP_WeeklyCapExceeded();
        
        weeklyPlans[weekNumber_] = WeeklyPlan({
            dailyAllocations: dailyAllocations_,
            totalAllocated: totalAllocated,
            totalUsed: 0,
            exists: true
        });
        
        emit WeeklyPlanCreated(weekNumber_, dailyAllocations_);
    }

    function updateWeeklyPlan(uint256 weekNumber_, uint256[] calldata dailyAllocations_) external onlyAuthorized {
        if (weekNumber_ < currentWeekNumber) revert WEP_InvalidWeek();
        if (dailyAllocations_.length != DAYS_IN_WEEK) revert WEP_InvalidDayOfWeek();
        if (!weeklyPlans[weekNumber_].exists) revert WEP_PlanNotFound();
        
        WeeklyPlan storage plan = weeklyPlans[weekNumber_];
        
        uint256 totalAllocated = 0;
        for (uint256 i = 0; i < DAYS_IN_WEEK; i++) {
            totalAllocated += dailyAllocations_[i];
        }
        
        if (totalAllocated > weeklyEmissionCap) revert WEP_WeeklyCapExceeded();
        
        plan.dailyAllocations = dailyAllocations_;
        plan.totalAllocated = totalAllocated;
        
        emit WeeklyPlanUpdated(weekNumber_, dailyAllocations_);
    }

    function recordEmission(uint256 amount_) external onlyAuthorized returns (bool) {
        if (amount_ == 0) revert WEP_InvalidAmount();
        
        _checkAndUpdateWeek();
        
        WeeklyPlan storage plan = weeklyPlans[currentWeekNumber];
        if (!plan.exists) {
            // Create a default plan if none exists
            uint256[] memory defaultAllocations = new uint256[](DAYS_IN_WEEK);
            uint256 dailyAllocation = weeklyEmissionCap / DAYS_IN_WEEK;
            
            for (uint256 i = 0; i < DAYS_IN_WEEK; i++) {
                defaultAllocations[i] = dailyAllocation;
            }
            
            plan.dailyAllocations = defaultAllocations;
            plan.totalAllocated = weeklyEmissionCap;
            plan.totalUsed = 0;
            plan.exists = true;
            
            emit WeeklyPlanCreated(currentWeekNumber, defaultAllocations);
        }
        
        if (plan.totalUsed + amount_ > plan.totalAllocated) {
            revert WEP_WeeklyCapExceeded();
        }
        
        plan.totalUsed += amount_;
        
        // Calculate current day of week (0-6, where 0 is Monday)
        uint256 dayOfWeek = (block.timestamp - weekStartTimestamp) / 86400;
        
        emit EmissionRecorded(currentWeekNumber, dayOfWeek, amount_);
        
        return true;
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getWeeklyEmissionCap() external view returns (uint256) {
        return weeklyEmissionCap;
    }

    function getCurrentWeekNumber() external view returns (uint256) {
        return currentWeekNumber;
    }

    function getWeeklyPlan(uint256 weekNumber_) external view returns (uint256[] memory) {
        if (!weeklyPlans[weekNumber_].exists) revert WEP_PlanNotFound();
        return weeklyPlans[weekNumber_].dailyAllocations;
    }

    function getWeeklyEmissionUsed(uint256 weekNumber_) external view returns (uint256) {
        if (!weeklyPlans[weekNumber_].exists) revert WEP_PlanNotFound();
        return weeklyPlans[weekNumber_].totalUsed;
    }

    function getRemainingWeeklyEmission() external view returns (uint256) {
        uint256 weekNumber = block.timestamp / WEEK_IN_SECONDS;
        
        if (weekNumber > currentWeekNumber || !weeklyPlans[currentWeekNumber].exists) {
            // New week has started but state hasn't been updated, or no plan exists
            return weeklyEmissionCap;
        }
        
        WeeklyPlan storage plan = weeklyPlans[currentWeekNumber];
        return plan.totalAllocated > plan.totalUsed ? plan.totalAllocated - plan.totalUsed : 0;
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function _checkAndUpdateWeek() internal {
        uint256 weekNumber = block.timestamp / WEEK_IN_SECONDS;
        
        if (weekNumber > currentWeekNumber) {
            // Roll over to new week
            uint256 previousWeek = currentWeekNumber;
            uint256 unusedEmission = 0;
            
            if (weeklyPlans[previousWeek].exists) {
                unusedEmission = weeklyPlans[previousWeek].totalAllocated - weeklyPlans[previousWeek].totalUsed;
            }
            
            currentWeekNumber = weekNumber;
            weekStartTimestamp = weekNumber * WEEK_IN_SECONDS;
            
            emit WeekRolledOver(previousWeek, weekNumber, unusedEmission);
        }
    }
}