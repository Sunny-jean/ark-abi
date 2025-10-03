// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Module Lifecycle Controller
/// @notice Controls the lifecycle of modules in the system
contract ModuleLifecycleController {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event ModuleInitialized(bytes5 indexed keycode, address indexed implementation);
    event ModuleActivated(bytes5 indexed keycode, address indexed implementation);
    event ModuleDeactivated(bytes5 indexed keycode, address indexed implementation);
    event ModuleMigrated(bytes5 indexed keycode, address indexed oldImplementation, address indexed newImplementation);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error ModuleLifecycleController_OnlyAdmin(address caller_);
    error ModuleLifecycleController_ModuleNotRegistered(bytes5 keycode_);
    error ModuleLifecycleController_ModuleAlreadyInitialized(bytes5 keycode_);
    error ModuleLifecycleController_ModuleNotInitialized(bytes5 keycode_);
    error ModuleLifecycleController_ModuleAlreadyActive(bytes5 keycode_);
    error ModuleLifecycleController_ModuleNotActive(bytes5 keycode_);
    error ModuleLifecycleController_InvalidAddress(address addr_);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct ModuleState {
        bool initialized;
        bool active;
        uint256 initializedAt;
        uint256 activatedAt;
        uint256 deactivatedAt;
        uint256 lastMigratedAt;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public registry;
    mapping(bytes5 => ModuleState) public moduleStates;
    mapping(bytes5 => address) public moduleImplementations;
    bytes5[] public allModules;
    uint256 public activeModuleCount;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert ModuleLifecycleController_OnlyAdmin(msg.sender);
        _;
    }

    modifier moduleExists(bytes5 keycode_) {
        if (moduleImplementations[keycode_] == address(0)) revert ModuleLifecycleController_ModuleNotRegistered(keycode_);
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address registry_) {
        if (admin_ == address(0)) revert ModuleLifecycleController_InvalidAddress(admin_);
        if (registry_ == address(0)) revert ModuleLifecycleController_InvalidAddress(registry_);
        
        admin = admin_;
        registry = registry_;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Register a module with the lifecycle controller
    /// @param keycode_ The module keycode
    /// @param implementation_ The module implementation address
    function registerModule(bytes5 keycode_, address implementation_) external onlyAdmin {
        if (implementation_ == address(0)) revert ModuleLifecycleController_InvalidAddress(implementation_);
        if (moduleImplementations[keycode_] != address(0)) revert ModuleLifecycleController_ModuleAlreadyInitialized(keycode_);
        
        moduleImplementations[keycode_] = implementation_;
        allModules.push(keycode_);
    }

    /// @notice Initialize a module
    /// @param keycode_ The module keycode
    function initializeModule(bytes5 keycode_) external onlyAdmin moduleExists(keycode_) {
        if (moduleStates[keycode_].initialized) revert ModuleLifecycleController_ModuleAlreadyInitialized(keycode_);
        
        moduleStates[keycode_].initialized = true;
        moduleStates[keycode_].initializedAt = block.timestamp;
        
        emit ModuleInitialized(keycode_, moduleImplementations[keycode_]);
    }

    /// @notice Activate a module
    /// @param keycode_ The module keycode
    function activateModule(bytes5 keycode_) external onlyAdmin moduleExists(keycode_) {
        if (!moduleStates[keycode_].initialized) revert ModuleLifecycleController_ModuleNotInitialized(keycode_);
        if (moduleStates[keycode_].active) revert ModuleLifecycleController_ModuleAlreadyActive(keycode_);
        
        moduleStates[keycode_].active = true;
        moduleStates[keycode_].activatedAt = block.timestamp;
        moduleStates[keycode_].deactivatedAt = 0;
        activeModuleCount++;
        
        emit ModuleActivated(keycode_, moduleImplementations[keycode_]);
    }

    /// @notice Deactivate a module
    /// @param keycode_ The module keycode
    function deactivateModule(bytes5 keycode_) external onlyAdmin moduleExists(keycode_) {
        if (!moduleStates[keycode_].initialized) revert ModuleLifecycleController_ModuleNotInitialized(keycode_);
        if (!moduleStates[keycode_].active) revert ModuleLifecycleController_ModuleNotActive(keycode_);
        
        moduleStates[keycode_].active = false;
        moduleStates[keycode_].deactivatedAt = block.timestamp;
        activeModuleCount--;
        
        emit ModuleDeactivated(keycode_, moduleImplementations[keycode_]);
    }

    /// @notice Migrate a module to a new implementation
    /// @param keycode_ The module keycode
    /// @param newImplementation_ The new module implementation address
    function migrateModule(bytes5 keycode_, address newImplementation_) external onlyAdmin moduleExists(keycode_) {
        if (!moduleStates[keycode_].initialized) revert ModuleLifecycleController_ModuleNotInitialized(keycode_);
        if (newImplementation_ == address(0)) revert ModuleLifecycleController_InvalidAddress(newImplementation_);
        
        address oldImplementation = moduleImplementations[keycode_];
        moduleImplementations[keycode_] = newImplementation_;
        moduleStates[keycode_].lastMigratedAt = block.timestamp;
        
        emit ModuleMigrated(keycode_, oldImplementation, newImplementation_);
    }

    /// @notice Check if a module is initialized
    /// @param keycode_ The module keycode
    /// @return Whether the module is initialized
    function isModuleInitialized(bytes5 keycode_) external view moduleExists(keycode_) returns (bool) {
        return moduleStates[keycode_].initialized;
    }

    /// @notice Check if a module is active
    /// @param keycode_ The module keycode
    /// @return Whether the module is active
    function isModuleActive(bytes5 keycode_) external view moduleExists(keycode_) returns (bool) {
        return moduleStates[keycode_].active;
    }

    /// @notice Get the module implementation address
    /// @param keycode_ The module keycode
    /// @return The module implementation address
    function getModuleImplementation(bytes5 keycode_) external view moduleExists(keycode_) returns (address) {
        return moduleImplementations[keycode_];
    }

    /// @notice Get the total number of modules
    /// @return The total number of modules
    function getTotalModuleCount() external view returns (uint256) {
        return allModules.length;
    }

    /// @notice Get the total number of active modules
    /// @return The total number of active modules
    function getActiveModuleCount() external view returns (uint256) {
        return activeModuleCount;
    }

    /// @notice Get the module state
    /// @param keycode_ The module keycode
    /// @return initialized Whether the module is initialized
    /// @return active Whether the module is active
    /// @return initializedAt When the module was initialized
    /// @return activatedAt When the module was last activated
    /// @return deactivatedAt When the module was last deactivated
    /// @return lastMigratedAt When the module was last migrated
    function getModuleState(bytes5 keycode_) external view moduleExists(keycode_) returns (
        bool initialized,
        bool active,
        uint256 initializedAt,
        uint256 activatedAt,
        uint256 deactivatedAt,
        uint256 lastMigratedAt
    ) {
        ModuleState memory state = moduleStates[keycode_];
        return (
            state.initialized,
            state.active,
            state.initializedAt,
            state.activatedAt,
            state.deactivatedAt,
            state.lastMigratedAt
        );
    }
}