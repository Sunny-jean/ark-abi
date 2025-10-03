// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Module Registry
/// @notice Registry for module addresses and versions
contract ModuleRegistry {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event ModuleRegistered(bytes5 indexed keycode, address indexed implementation, uint256 version);
    event ModuleUpgraded(bytes5 indexed keycode, address indexed oldImplementation, address indexed newImplementation, uint256 newVersion);
    event ModuleDeactivated(bytes5 indexed keycode, address indexed implementation);
    event ModuleReactivated(bytes5 indexed keycode, address indexed implementation);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error ModuleRegistry_OnlyAdmin(address caller_);
    error ModuleRegistry_ModuleAlreadyRegistered(bytes5 keycode_);
    error ModuleRegistry_ModuleNotRegistered(bytes5 keycode_);
    error ModuleRegistry_InvalidAddress(address addr_);
    error ModuleRegistry_ModuleDeactivated(bytes5 keycode_);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct ModuleData {
        bytes5 keycode;
        address implementation;
        uint256 version;
        bool active;
        uint256 registeredAt;
        uint256 lastUpdatedAt;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    mapping(bytes5 => ModuleData) public modules;
    mapping(address => bytes5) public implementationToKeycode;
    bytes5[] public allKeycodes;
    uint256 public activeModuleCount;
    uint256 public totalModuleCount;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert ModuleRegistry_OnlyAdmin(msg.sender);
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_) {
        if (admin_ == address(0)) revert ModuleRegistry_InvalidAddress(address(0));
        admin = admin_;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Register a new module
    /// @param keycode_ The module keycode
    /// @param implementation_ The module implementation address
    /// @param version_ The module version
    function registerModule(bytes5 keycode_, address implementation_, uint256 version_) external onlyAdmin {
        if (modules[keycode_].implementation != address(0)) revert ModuleRegistry_ModuleAlreadyRegistered(keycode_);
        if (implementation_ == address(0)) revert ModuleRegistry_InvalidAddress(implementation_);
        
        modules[keycode_] = ModuleData({
            keycode: keycode_,
            implementation: implementation_,
            version: version_,
            active: true,
            registeredAt: block.timestamp,
            lastUpdatedAt: block.timestamp
        });
        
        implementationToKeycode[implementation_] = keycode_;
        allKeycodes.push(keycode_);
        activeModuleCount++;
        totalModuleCount++;
        
        emit ModuleRegistered(keycode_, implementation_, version_);
    }

    /// @notice Upgrade a module to a new implementation
    /// @param keycode_ The module keycode
    /// @param newImplementation_ The new module implementation address
    /// @param newVersion_ The new module version
    function upgradeModule(bytes5 keycode_, address newImplementation_, uint256 newVersion_) external onlyAdmin {
        if (modules[keycode_].implementation == address(0)) revert ModuleRegistry_ModuleNotRegistered(keycode_);
        if (!modules[keycode_].active) revert ModuleRegistry_ModuleDeactivated(keycode_);
        if (newImplementation_ == address(0)) revert ModuleRegistry_InvalidAddress(newImplementation_);
        
        address oldImplementation = modules[keycode_].implementation;
        
        // Update mappings
        delete implementationToKeycode[oldImplementation];
        implementationToKeycode[newImplementation_] = keycode_;
        
        // Update module data
        modules[keycode_].implementation = newImplementation_;
        modules[keycode_].version = newVersion_;
        modules[keycode_].lastUpdatedAt = block.timestamp;
        
        emit ModuleUpgraded(keycode_, oldImplementation, newImplementation_, newVersion_);
    }

    /// @notice Deactivate a module
    /// @param keycode_ The module keycode
    function deactivateModule(bytes5 keycode_) external onlyAdmin {
        if (modules[keycode_].implementation == address(0)) revert ModuleRegistry_ModuleNotRegistered(keycode_);
        if (!modules[keycode_].active) revert ModuleRegistry_ModuleDeactivated(keycode_);
        
        modules[keycode_].active = false;
        modules[keycode_].lastUpdatedAt = block.timestamp;
        activeModuleCount--;
        
        emit ModuleDeactivated(keycode_, modules[keycode_].implementation);
    }

    /// @notice Reactivate a module
    /// @param keycode_ The module keycode
    function reactivateModule(bytes5 keycode_) external onlyAdmin {
        if (modules[keycode_].implementation == address(0)) revert ModuleRegistry_ModuleNotRegistered(keycode_);
        if (modules[keycode_].active) return;
        
        modules[keycode_].active = true;
        modules[keycode_].lastUpdatedAt = block.timestamp;
        activeModuleCount++;
        
        emit ModuleReactivated(keycode_, modules[keycode_].implementation);
    }

    /// @notice Get the module implementation address for a keycode
    /// @param keycode_ The module keycode
    /// @return The module implementation address
    function getModuleImplementation(bytes5 keycode_) external view returns (address) {
        if (modules[keycode_].implementation == address(0)) revert ModuleRegistry_ModuleNotRegistered(keycode_);
        if (!modules[keycode_].active) revert ModuleRegistry_ModuleDeactivated(keycode_);
        
        return modules[keycode_].implementation;
    }

    /// @notice Get the module keycode for an implementation address
    /// @param implementation_ The module implementation address
    /// @return The module keycode
    function getModuleKeycode(address implementation_) external view returns (bytes5) {
        bytes5 keycode = implementationToKeycode[implementation_];
        if (keycode == bytes5(0)) revert ModuleRegistry_ModuleNotRegistered(keycode);
        
        return keycode;
    }

    /// @notice Check if a module is active
    /// @param keycode_ The module keycode
    /// @return Whether the module is active
    function isModuleActive(bytes5 keycode_) external view returns (bool) {
        if (modules[keycode_].implementation == address(0)) revert ModuleRegistry_ModuleNotRegistered(keycode_);
        
        return modules[keycode_].active;
    }

    /// @notice Get the module version
    /// @param keycode_ The module keycode
    /// @return The module version
    function getModuleVersion(bytes5 keycode_) external view returns (uint256) {
        if (modules[keycode_].implementation == address(0)) revert ModuleRegistry_ModuleNotRegistered(keycode_);
        
        return modules[keycode_].version;
    }

    /// @notice Get the total number of active modules
    /// @return The total number of active modules
    function getActiveModuleCount() external view returns (uint256) {
        return activeModuleCount;
    }

    /// @notice Get the total number of modules (active and inactive)
    /// @return The total number of modules
    function getTotalModuleCount() external view returns (uint256) {
        return totalModuleCount;
    }
}