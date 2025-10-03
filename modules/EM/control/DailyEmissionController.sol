// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

// --- interfaces ---
interface IEmissionManager {
    function getEmissionRate() external view returns (uint256);
    function adjustEmissionRate(uint256 newRate) external;
    function getLastEmissionTimestamp() external view returns (uint256);
}

/// @title Daily Emission Controller interface
/// @notice interface for the daily emission controller contract
interface IDailyEmissionController {
    function getDailyEmissionCap() external view returns (uint256);
    function getDailyEmissionUsed() external view returns (uint256);
    function getRemainingDailyEmission() external view returns (uint256);
    function getCurrentDayNumber() external view returns (uint256);
}

/// @title Daily Emission Controller
/// @notice Controls and tracks daily token emission limits
contract DailyEmissionController {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event DailyCapUpdated(uint256 oldCap, uint256 newCap);
    event EmissionRecorded(uint256 indexed dayNumber, uint256 amount, uint256 remainingCap);
    event DayRolledOver(uint256 indexed previousDay, uint256 indexed newDay, uint256 unusedEmission);
    event ControllerAuthorized(address indexed controller);
    event ControllerRevoked(address indexed controller);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error DEC_OnlyAdmin();
    error DEC_OnlyAuthorized();
    error DEC_ZeroAddress();
    error DEC_InvalidAmount();
    error DEC_DailyCapExceeded(uint256 requested, uint256 available);
    error DEC_AlreadyAuthorized();
    error DEC_NotAuthorized();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct DailyEmission {
        uint256 cap;
        uint256 used;
        uint256 timestamp;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public emissionManager;
    
    uint256 public dailyEmissionCap;
    uint256 public currentDayNumber;
    uint256 public dayStartTimestamp;
    uint256 public constant DAY_IN_SECONDS = 86400; // 24 hours
    
    mapping(uint256 => DailyEmission) public dailyEmissions; // day number => emission data
    mapping(address => bool) public authorizedControllers;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert DEC_OnlyAdmin();
        _;
    }

    modifier onlyAuthorized() {
        if (!authorizedControllers[msg.sender] && msg.sender != admin) revert DEC_OnlyAuthorized();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address emissionManager_, uint256 dailyEmissionCap_) {
        if (admin_ == address(0) || emissionManager_ == address(0)) revert DEC_ZeroAddress();
        if (dailyEmissionCap_ == 0) revert DEC_InvalidAmount();
        
        admin = admin_;
        emissionManager = emissionManager_;
        dailyEmissionCap = dailyEmissionCap_;
        currentDayNumber = block.timestamp / DAY_IN_SECONDS;
        dayStartTimestamp = currentDayNumber * DAY_IN_SECONDS;
        
        // Initialize the first day
        dailyEmissions[currentDayNumber] = DailyEmission({
            cap: dailyEmissionCap_,
            used: 0,
            timestamp: block.timestamp
        });
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function setDailyEmissionCap(uint256 newCap_) external onlyAdmin {
        if (newCap_ == 0) revert DEC_InvalidAmount();
        
        uint256 oldCap = dailyEmissionCap;
        dailyEmissionCap = newCap_;
        
        // Update current day's cap if it hasn't been fully used
        _checkAndUpdateDay();
        DailyEmission storage currentDay = dailyEmissions[currentDayNumber];
        if (currentDay.used < currentDay.cap) {
            currentDay.cap = newCap_;
        }
        
        emit DailyCapUpdated(oldCap, newCap_);
    }

    function authorizeController(address controller_) external onlyAdmin {
        if (controller_ == address(0)) revert DEC_ZeroAddress();
        if (authorizedControllers[controller_]) revert DEC_AlreadyAuthorized();
        
        authorizedControllers[controller_] = true;
        
        emit ControllerAuthorized(controller_);
    }

    function revokeController(address controller_) external onlyAdmin {
        if (!authorizedControllers[controller_]) revert DEC_NotAuthorized();
        
        authorizedControllers[controller_] = false;
        
        emit ControllerRevoked(controller_);
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function recordEmission(uint256 amount_) external onlyAuthorized returns (bool) {
        if (amount_ == 0) revert DEC_InvalidAmount();
        
        _checkAndUpdateDay();
        
        DailyEmission storage currentDay = dailyEmissions[currentDayNumber];
        
        if (currentDay.used + amount_ > currentDay.cap) {
            revert DEC_DailyCapExceeded(amount_, currentDay.cap - currentDay.used);
        }
        
        currentDay.used += amount_;
        
        emit EmissionRecorded(currentDayNumber, amount_, currentDay.cap - currentDay.used);
        
        return true;
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getDailyEmissionCap() external view returns (uint256) {
        return dailyEmissionCap;
    }

    function getDailyEmissionUsed() external view returns (uint256) {
        uint256 dayNumber = block.timestamp / DAY_IN_SECONDS;
        
        if (dayNumber > currentDayNumber) {
            // New day has started, but state hasn't been updated yet
            return 0;
        }
        
        return dailyEmissions[currentDayNumber].used;
    }

    function getRemainingDailyEmission() external view returns (uint256) {
        uint256 dayNumber = block.timestamp / DAY_IN_SECONDS;
        
        if (dayNumber > currentDayNumber) {
            // New day has started, but state hasn't been updated yet
            return dailyEmissionCap;
        }
        
        DailyEmission storage currentDay = dailyEmissions[currentDayNumber];
        return currentDay.cap > currentDay.used ? currentDay.cap - currentDay.used : 0;
    }

    function getCurrentDayNumber() external view returns (uint256) {
        return currentDayNumber;
    }

    // ============================================================================================//
    //                                    INTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function _checkAndUpdateDay() internal {
        uint256 dayNumber = block.timestamp / DAY_IN_SECONDS;
        
        if (dayNumber > currentDayNumber) {
            // Roll over to new day
            uint256 previousDay = currentDayNumber;
            uint256 unusedEmission = dailyEmissions[previousDay].cap - dailyEmissions[previousDay].used;
            
            currentDayNumber = dayNumber;
            dayStartTimestamp = dayNumber * DAY_IN_SECONDS;
            
            // Initialize new day
            dailyEmissions[dayNumber] = DailyEmission({
                cap: dailyEmissionCap,
                used: 0,
                timestamp: block.timestamp
            });
            
            emit DayRolledOver(previousDay, dayNumber, unusedEmission);
        }
    }
}