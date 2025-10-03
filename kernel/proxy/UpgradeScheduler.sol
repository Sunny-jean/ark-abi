// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Upgrade Scheduler
/// @notice Schedules and manages the timing of upgrades in the system
contract UpgradeScheduler {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event UpgradeScheduled(uint256 indexed upgradeId, address indexed proxy, address indexed implementation, uint256 scheduledTime);
    event UpgradeCancelled(uint256 indexed upgradeId);
    event UpgradeExecuted(uint256 indexed upgradeId, address indexed proxy, address indexed implementation);
    event UpgradeDelayed(uint256 indexed upgradeId, uint256 oldScheduledTime, uint256 newScheduledTime);
    event TimeDelayChanged(uint256 oldTimeDelay, uint256 newTimeDelay);
    event EmergencyUpgradeExecuted(uint256 indexed upgradeId, address indexed proxy, address indexed implementation);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error UpgradeScheduler_OnlyAdmin(address caller_);
    error UpgradeScheduler_OnlyUpgradeManager(address caller_);
    error UpgradeScheduler_InvalidAddress(address addr_);
    error UpgradeScheduler_UpgradeNotFound(uint256 upgradeId_);
    error UpgradeScheduler_UpgradeAlreadyExecuted(uint256 upgradeId_);
    error UpgradeScheduler_UpgradeAlreadyCancelled(uint256 upgradeId_);
    error UpgradeScheduler_TimeDelayNotMet(uint256 upgradeId_, uint256 scheduledTime_, uint256 currentTime_);
    error UpgradeScheduler_InvalidTimeDelay(uint256 timeDelay_);
    error UpgradeScheduler_NotEmergencyAdmin(address caller_);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    enum UpgradeStatus {
        Scheduled,
        Executed,
        Cancelled
    }

    struct ScheduledUpgrade {
        uint256 id;
        address proxy;
        address implementation;
        uint256 scheduledTime;
        UpgradeStatus status;
        uint256 createdAt;
        uint256 executedAt;
        string description;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public upgradeManager;
    address public emergencyAdmin;
    
    // Time delay for upgrades (in seconds)
    uint256 public timeDelay;
    
    // Scheduled upgrades
    mapping(uint256 => ScheduledUpgrade) public scheduledUpgrades;
    uint256 public nextUpgradeId;
    
    // Upgrades by proxy
    mapping(address => uint256[]) public upgradesByProxy;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert UpgradeScheduler_OnlyAdmin(msg.sender);
        _;
    }

    modifier onlyUpgradeManager() {
        if (msg.sender != upgradeManager) revert UpgradeScheduler_OnlyUpgradeManager(msg.sender);
        _;
    }

    modifier onlyEmergencyAdmin() {
        if (msg.sender != emergencyAdmin) revert UpgradeScheduler_NotEmergencyAdmin(msg.sender);
        _;
    }

    modifier upgradeExists(uint256 upgradeId_) {
        if (upgradeId_ >= nextUpgradeId || scheduledUpgrades[upgradeId_].id != upgradeId_) {
            revert UpgradeScheduler_UpgradeNotFound(upgradeId_);
        }
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address upgradeManager_, address emergencyAdmin_, uint256 timeDelay_) {
        if (admin_ == address(0)) revert UpgradeScheduler_InvalidAddress(admin_);
        if (upgradeManager_ == address(0)) revert UpgradeScheduler_InvalidAddress(upgradeManager_);
        if (emergencyAdmin_ == address(0)) revert UpgradeScheduler_InvalidAddress(emergencyAdmin_);
        if (timeDelay_ < 1 hours) revert UpgradeScheduler_InvalidTimeDelay(timeDelay_);
        
        admin = admin_;
        upgradeManager = upgradeManager_;
        emergencyAdmin = emergencyAdmin_;
        timeDelay = timeDelay_;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Schedule an upgrade
    /// @param proxy_ The proxy address
    /// @param implementation_ The new implementation address
    /// @param description_ A description of the upgrade
    /// @return upgradeId The ID of the scheduled upgrade
    function scheduleUpgrade(
        address proxy_,
        address implementation_,
        string calldata description_
    ) external onlyUpgradeManager returns (uint256) {
        if (proxy_ == address(0)) revert UpgradeScheduler_InvalidAddress(proxy_);
        if (implementation_ == address(0)) revert UpgradeScheduler_InvalidAddress(implementation_);
        
        uint256 upgradeId = nextUpgradeId++;
        uint256 scheduledTime = block.timestamp + timeDelay;
        
        // Create scheduled upgrade
        scheduledUpgrades[upgradeId] = ScheduledUpgrade({
            id: upgradeId,
            proxy: proxy_,
            implementation: implementation_,
            scheduledTime: scheduledTime,
            status: UpgradeStatus.Scheduled,
            createdAt: block.timestamp,
            executedAt: 0,
            description: description_
        });
        
        // Add to proxy upgrades
        upgradesByProxy[proxy_].push(upgradeId);
        
        emit UpgradeScheduled(upgradeId, proxy_, implementation_, scheduledTime);
        
        return upgradeId;
    }

    /// @notice Cancel a scheduled upgrade
    /// @param upgradeId_ The upgrade ID
    function cancelUpgrade(uint256 upgradeId_) external onlyAdmin upgradeExists(upgradeId_) {
        ScheduledUpgrade storage upgrade = scheduledUpgrades[upgradeId_];
        
        // Check upgrade status
        if (upgrade.status == UpgradeStatus.Executed) {
            revert UpgradeScheduler_UpgradeAlreadyExecuted(upgradeId_);
        }
        if (upgrade.status == UpgradeStatus.Cancelled) {
            revert UpgradeScheduler_UpgradeAlreadyCancelled(upgradeId_);
        }
        
        // Cancel upgrade
        upgrade.status = UpgradeStatus.Cancelled;
        
        emit UpgradeCancelled(upgradeId_);
    }

    /// @notice Execute a scheduled upgrade
    /// @param upgradeId_ The upgrade ID
    function executeUpgrade(uint256 upgradeId_) external onlyAdmin upgradeExists(upgradeId_) {
        ScheduledUpgrade storage upgrade = scheduledUpgrades[upgradeId_];
        
        // Check upgrade status
        if (upgrade.status == UpgradeStatus.Executed) {
            revert UpgradeScheduler_UpgradeAlreadyExecuted(upgradeId_);
        }
        if (upgrade.status == UpgradeStatus.Cancelled) {
            revert UpgradeScheduler_UpgradeAlreadyCancelled(upgradeId_);
        }
        
        // Check time delay
        if (block.timestamp < upgrade.scheduledTime) {
            revert UpgradeScheduler_TimeDelayNotMet(
                upgradeId_,
                upgrade.scheduledTime,
                block.timestamp
            );
        }
        
        // Execute upgrade
        upgrade.status = UpgradeStatus.Executed;
        upgrade.executedAt = block.timestamp;
        
        // this would call the proxy to update its implementation
        //  we just emit the event
        
        emit UpgradeExecuted(upgradeId_, upgrade.proxy, upgrade.implementation);
    }

    /// @notice Execute an emergency upgrade (bypassing time delay)
    /// @param upgradeId_ The upgrade ID
    function executeEmergencyUpgrade(uint256 upgradeId_) external onlyEmergencyAdmin upgradeExists(upgradeId_) {
        ScheduledUpgrade storage upgrade = scheduledUpgrades[upgradeId_];
        
        // Check upgrade status
        if (upgrade.status == UpgradeStatus.Executed) {
            revert UpgradeScheduler_UpgradeAlreadyExecuted(upgradeId_);
        }
        if (upgrade.status == UpgradeStatus.Cancelled) {
            revert UpgradeScheduler_UpgradeAlreadyCancelled(upgradeId_);
        }
        
        // Execute upgrade
        upgrade.status = UpgradeStatus.Executed;
        upgrade.executedAt = block.timestamp;
        
        // this would call the proxy to update its implementation
        //  we just emit the event
        
        emit EmergencyUpgradeExecuted(upgradeId_, upgrade.proxy, upgrade.implementation);
    }

    /// @notice Delay a scheduled upgrade
    /// @param upgradeId_ The upgrade ID
    /// @param additionalDelay_ Additional delay in seconds
    function delayUpgrade(uint256 upgradeId_, uint256 additionalDelay_) external onlyAdmin upgradeExists(upgradeId_) {
        ScheduledUpgrade storage upgrade = scheduledUpgrades[upgradeId_];
        
        // Check upgrade status
        if (upgrade.status == UpgradeStatus.Executed) {
            revert UpgradeScheduler_UpgradeAlreadyExecuted(upgradeId_);
        }
        if (upgrade.status == UpgradeStatus.Cancelled) {
            revert UpgradeScheduler_UpgradeAlreadyCancelled(upgradeId_);
        }
        
        uint256 oldScheduledTime = upgrade.scheduledTime;
        uint256 newScheduledTime = oldScheduledTime + additionalDelay_;
        
        // Update scheduled time
        upgrade.scheduledTime = newScheduledTime;
        
        emit UpgradeDelayed(upgradeId_, oldScheduledTime, newScheduledTime);
    }

    /// @notice Set the time delay for upgrades
    /// @param timeDelay_ The new time delay in seconds
    function setTimeDelay(uint256 timeDelay_) external onlyAdmin {
        if (timeDelay_ < 1 hours) revert UpgradeScheduler_InvalidTimeDelay(timeDelay_);
        
        uint256 oldTimeDelay = timeDelay;
        timeDelay = timeDelay_;
        
        emit TimeDelayChanged(oldTimeDelay, timeDelay_);
    }

    /// @notice Set the emergency admin
    /// @param emergencyAdmin_ The new emergency admin address
    function setEmergencyAdmin(address emergencyAdmin_) external onlyAdmin {
        if (emergencyAdmin_ == address(0)) revert UpgradeScheduler_InvalidAddress(emergencyAdmin_);
        
        emergencyAdmin = emergencyAdmin_;
    }

    /// @notice Get upgrades for a proxy
    /// @param proxy_ The proxy address
    /// @return Array of upgrade IDs for the proxy
    function getUpgradesForProxy(address proxy_) external view returns (uint256[] memory) {
        return upgradesByProxy[proxy_];
    }

    /// @notice Get pending upgrades for a proxy
    /// @param proxy_ The proxy address
    /// @return Array of pending upgrade IDs for the proxy
    function getPendingUpgradesForProxy(address proxy_) external view returns (uint256[] memory) {
        uint256[] memory allUpgrades = upgradesByProxy[proxy_];
        uint256 pendingCount = 0;
        
        // Count pending upgrades
        for (uint256 i = 0; i < allUpgrades.length; i++) {
            if (scheduledUpgrades[allUpgrades[i]].status == UpgradeStatus.Scheduled) {
                pendingCount++;
            }
        }
        
        // Create array of pending upgrades
        uint256[] memory pendingUpgrades = new uint256[](pendingCount);
        uint256 index = 0;
        
        for (uint256 i = 0; i < allUpgrades.length; i++) {
            if (scheduledUpgrades[allUpgrades[i]].status == UpgradeStatus.Scheduled) {
                pendingUpgrades[index++] = allUpgrades[i];
            }
        }
        
        return pendingUpgrades;
    }

    /// @notice Check if an upgrade is ready to execute
    /// @param upgradeId_ The upgrade ID
    /// @return Whether the upgrade is ready to execute
    function isUpgradeReady(uint256 upgradeId_) external view upgradeExists(upgradeId_) returns (bool) {
        ScheduledUpgrade memory upgrade = scheduledUpgrades[upgradeId_];
        
        return (
            upgrade.status == UpgradeStatus.Scheduled &&
            block.timestamp >= upgrade.scheduledTime
        );
    }

    /// @notice Get time remaining until an upgrade can be executed
    /// @param upgradeId_ The upgrade ID
    /// @return Time remaining in seconds (0 if ready or not pending)
    function getTimeRemaining(uint256 upgradeId_) external view upgradeExists(upgradeId_) returns (uint256) {
        ScheduledUpgrade memory upgrade = scheduledUpgrades[upgradeId_];
        
        if (upgrade.status != UpgradeStatus.Scheduled) {
            return 0;
        }
        
        if (block.timestamp >= upgrade.scheduledTime) {
            return 0;
        }
        
        return upgrade.scheduledTime - block.timestamp;
    }

    /// @notice Get detailed upgrade information
    /// @param upgradeId_ The upgrade ID
    /// @return id The upgrade ID
    /// @return proxy The proxy address
    /// @return implementation The new implementation address
    /// @return scheduledTime When the upgrade is scheduled to execute
    /// @return status The upgrade status
    /// @return createdAt When the upgrade was created
    /// @return executedAt When the upgrade was executed
    /// @return description The upgrade description
    function getUpgradeDetails(uint256 upgradeId_) external view upgradeExists(upgradeId_) returns (
        uint256 id,
        address proxy,
        address implementation,
        uint256 scheduledTime,
        UpgradeStatus status,
        uint256 createdAt,
        uint256 executedAt,
        string memory description
    ) {
        ScheduledUpgrade memory upgrade = scheduledUpgrades[upgradeId_];
        return (
            upgrade.id,
            upgrade.proxy,
            upgrade.implementation,
            upgrade.scheduledTime,
            upgrade.status,
            upgrade.createdAt,
            upgrade.executedAt,
            upgrade.description
        );
    }
}