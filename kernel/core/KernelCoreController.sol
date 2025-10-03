// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Kernel Core Controller
/// @notice Controls core kernel operations and system configuration
contract KernelCoreController {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event ConfigurationUpdated(bytes32 indexed configKey, bytes32 indexed oldValue, bytes32 indexed newValue);
    event ControllerAction(bytes32 indexed actionType, address indexed initiator, uint256 timestamp);
    event EmergencyShutdown(address indexed initiator, uint256 timestamp);
    event EmergencyRecovery(address indexed initiator, uint256 timestamp);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error KernelCoreController_OnlyAdmin(address caller_);
    error KernelCoreController_OnlyEmergencyAdmin(address caller_);
    error KernelCoreController_SystemPaused();
    error KernelCoreController_InvalidConfiguration(bytes32 configKey_);
    error KernelCoreController_ActionFailed(bytes32 actionType_);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct SystemConfig {
        bytes32 configKey;
        bytes32 configValue;
        bool isSet;
        uint256 lastUpdated;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public emergencyAdmin;
    bool public systemPaused;
    mapping(bytes32 => SystemConfig) public systemConfigs;
    bytes32[] public configKeys;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert KernelCoreController_OnlyAdmin(msg.sender);
        _;
    }

    modifier onlyEmergencyAdmin() {
        if (msg.sender != emergencyAdmin) revert KernelCoreController_OnlyEmergencyAdmin(msg.sender);
        _;
    }

    modifier whenNotPaused() {
        if (systemPaused) revert KernelCoreController_SystemPaused();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address emergencyAdmin_) {
        admin = admin_;
        emergencyAdmin = emergencyAdmin_;
        systemPaused = false;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Update a system configuration value
    /// @param configKey_ The configuration key
    /// @param configValue_ The new configuration value
    function updateConfiguration(bytes32 configKey_, bytes32 configValue_) external onlyAdmin whenNotPaused {
        bytes32 oldValue = systemConfigs[configKey_].configValue;
        
        if (!systemConfigs[configKey_].isSet) {
            configKeys.push(configKey_);
        }
        
        systemConfigs[configKey_] = SystemConfig({
            configKey: configKey_,
            configValue: configValue_,
            isSet: true,
            lastUpdated: block.timestamp
        });
        
        emit ConfigurationUpdated(configKey_, oldValue, configValue_);
    }

    /// @notice Perform a controller action
    /// @param actionType_ The type of action to perform
    /// @param actionData_ Additional data for the action
    function performAction(bytes32 actionType_, bytes calldata actionData_) external onlyAdmin whenNotPaused {
        // this would perform different actions based on actionType_
        // For this implementation, we'll just emit an event
        
        emit ControllerAction(actionType_, msg.sender, block.timestamp);
    }

    /// @notice Initiate an emergency shutdown of the system
    function emergencyShutdown() external onlyEmergencyAdmin {
        systemPaused = true;
        emit EmergencyShutdown(msg.sender, block.timestamp);
    }

    /// @notice Recover from an emergency shutdown
    function emergencyRecovery() external onlyEmergencyAdmin {
        systemPaused = false;
        emit EmergencyRecovery(msg.sender, block.timestamp);
    }

    /// @notice Get a system configuration value
    /// @param configKey_ The configuration key
    /// @return The configuration value
    function getConfiguration(bytes32 configKey_) external view returns (bytes32) {
        if (!systemConfigs[configKey_].isSet) revert KernelCoreController_InvalidConfiguration(configKey_);
        return systemConfigs[configKey_].configValue;
    }

    /// @notice Check if a configuration key is set
    /// @param configKey_ The configuration key
    /// @return Whether the configuration key is set
    function isConfigurationSet(bytes32 configKey_) external view returns (bool) {
        return systemConfigs[configKey_].isSet;
    }

    /// @notice Get the total number of configuration keys
    /// @return The total number of configuration keys
    function getConfigurationCount() external view returns (uint256) {
        return configKeys.length;
    }

    /// @notice Get the system status
    /// @return Whether the system is paused
    function getSystemStatus() external view returns (bool) {
        return !systemPaused;
    }
}