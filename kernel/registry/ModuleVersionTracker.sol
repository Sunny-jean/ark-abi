// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Module Version Tracker
/// @notice Tracks versions of modules in the system
contract ModuleVersionTracker {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event VersionRegistered(bytes5 indexed keycode, uint256 indexed version, address implementation);
    event VersionActivated(bytes5 indexed keycode, uint256 indexed version);
    event VersionDeactivated(bytes5 indexed keycode, uint256 indexed version);
    event VersionDeprecated(bytes5 indexed keycode, uint256 indexed version);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error ModuleVersionTracker_OnlyAdmin(address caller_);
    error ModuleVersionTracker_ModuleNotRegistered(bytes5 keycode_);
    error ModuleVersionTracker_VersionNotRegistered(bytes5 keycode_, uint256 version_);
    error ModuleVersionTracker_VersionAlreadyRegistered(bytes5 keycode_, uint256 version_);
    error ModuleVersionTracker_VersionAlreadyActive(bytes5 keycode_, uint256 version_);
    error ModuleVersionTracker_VersionNotActive(bytes5 keycode_, uint256 version_);
    error ModuleVersionTracker_VersionAlreadyDeprecated(bytes5 keycode_, uint256 version_);
    error ModuleVersionTracker_InvalidAddress(address addr_);
    error ModuleVersionTracker_InvalidVersion(uint256 version_);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct VersionData {
        bool registered;
        bool active;
        bool deprecated;
        address implementation;
        uint256 registeredAt;
        uint256 activatedAt;
        uint256 deactivatedAt;
        uint256 deprecatedAt;
        string metadata;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public registry;
    
    // Module versions: keycode => version => VersionData
    mapping(bytes5 => mapping(uint256 => VersionData)) public versions;
    
    // Latest version for each module
    mapping(bytes5 => uint256) public latestVersion;
    
    // Active version for each module
    mapping(bytes5 => uint256) public activeVersion;
    
    // All versions for a module
    mapping(bytes5 => uint256[]) public allVersionsForModule;
    
    // Total registered modules
    uint256 public totalModuleCount;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert ModuleVersionTracker_OnlyAdmin(msg.sender);
        _;
    }

    modifier moduleExists(bytes5 keycode_) {
        if (latestVersion[keycode_] == 0) revert ModuleVersionTracker_ModuleNotRegistered(keycode_);
        _;
    }

    modifier versionExists(bytes5 keycode_, uint256 version_) {
        if (!versions[keycode_][version_].registered) {
            revert ModuleVersionTracker_VersionNotRegistered(keycode_, version_);
        }
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address registry_) {
        if (admin_ == address(0)) revert ModuleVersionTracker_InvalidAddress(admin_);
        if (registry_ == address(0)) revert ModuleVersionTracker_InvalidAddress(registry_);
        
        admin = admin_;
        registry = registry_;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Register a new version for a module
    /// @param keycode_ The module keycode
    /// @param version_ The version number
    /// @param implementation_ The implementation address
    /// @param metadata_ Additional version metadata
    function registerVersion(
        bytes5 keycode_,
        uint256 version_,
        address implementation_,
        string calldata metadata_
    ) external onlyAdmin {
        if (implementation_ == address(0)) revert ModuleVersionTracker_InvalidAddress(implementation_);
        if (version_ == 0) revert ModuleVersionTracker_InvalidVersion(version_);
        
        // Check if version already exists
        if (versions[keycode_][version_].registered) {
            revert ModuleVersionTracker_VersionAlreadyRegistered(keycode_, version_);
        }
        
        // Register version
        versions[keycode_][version_] = VersionData({
            registered: true,
            active: false,
            deprecated: false,
            implementation: implementation_,
            registeredAt: block.timestamp,
            activatedAt: 0,
            deactivatedAt: 0,
            deprecatedAt: 0,
            metadata: metadata_
        });
        
        // Update latest version if needed
        if (version_ > latestVersion[keycode_]) {
            latestVersion[keycode_] = version_;
        }
        
        // Add to versions array if this is the first version
        if (allVersionsForModule[keycode_].length == 0) {
            totalModuleCount++;
        }
        
        // Add to versions array
        allVersionsForModule[keycode_].push(version_);
        
        emit VersionRegistered(keycode_, version_, implementation_);
    }

    /// @notice Activate a version for a module
    /// @param keycode_ The module keycode
    /// @param version_ The version number
    function activateVersion(bytes5 keycode_, uint256 version_) external onlyAdmin moduleExists(keycode_) versionExists(keycode_, version_) {
        // Check if version is already active
        if (versions[keycode_][version_].active) {
            revert ModuleVersionTracker_VersionAlreadyActive(keycode_, version_);
        }
        
        // Check if version is deprecated
        if (versions[keycode_][version_].deprecated) {
            revert ModuleVersionTracker_VersionAlreadyDeprecated(keycode_, version_);
        }
        
        // Deactivate current active version if exists
        uint256 currentActiveVersion = activeVersion[keycode_];
        if (currentActiveVersion != 0) {
            versions[keycode_][currentActiveVersion].active = false;
            versions[keycode_][currentActiveVersion].deactivatedAt = block.timestamp;
            
            emit VersionDeactivated(keycode_, currentActiveVersion);
        }
        
        // Activate new version
        versions[keycode_][version_].active = true;
        versions[keycode_][version_].activatedAt = block.timestamp;
        activeVersion[keycode_] = version_;
        
        emit VersionActivated(keycode_, version_);
    }

    /// @notice Deactivate the active version for a module
    /// @param keycode_ The module keycode
    function deactivateVersion(bytes5 keycode_) external onlyAdmin moduleExists(keycode_) {
        uint256 currentActiveVersion = activeVersion[keycode_];
        
        // Check if there is an active version
        if (currentActiveVersion == 0) {
            revert ModuleVersionTracker_VersionNotActive(keycode_, 0);
        }
        
        // Deactivate version
        versions[keycode_][currentActiveVersion].active = false;
        versions[keycode_][currentActiveVersion].deactivatedAt = block.timestamp;
        activeVersion[keycode_] = 0;
        
        emit VersionDeactivated(keycode_, currentActiveVersion);
    }

    /// @notice Deprecate a version for a module
    /// @param keycode_ The module keycode
    /// @param version_ The version number
    function deprecateVersion(bytes5 keycode_, uint256 version_) external onlyAdmin moduleExists(keycode_) versionExists(keycode_, version_) {
        // Check if version is already deprecated
        if (versions[keycode_][version_].deprecated) {
            revert ModuleVersionTracker_VersionAlreadyDeprecated(keycode_, version_);
        }
        
        // Check if version is active
        if (versions[keycode_][version_].active) {
            revert ModuleVersionTracker_VersionAlreadyActive(keycode_, version_);
        }
        
        // Deprecate version
        versions[keycode_][version_].deprecated = true;
        versions[keycode_][version_].deprecatedAt = block.timestamp;
        
        emit VersionDeprecated(keycode_, version_);
    }

    /// @notice Get the implementation address for a specific version
    /// @param keycode_ The module keycode
    /// @param version_ The version number
    /// @return The implementation address
    function getImplementation(bytes5 keycode_, uint256 version_) external view moduleExists(keycode_) versionExists(keycode_, version_) returns (address) {
        return versions[keycode_][version_].implementation;
    }

    /// @notice Get the active implementation address for a module
    /// @param keycode_ The module keycode
    /// @return The active implementation address
    function getActiveImplementation(bytes5 keycode_) external view moduleExists(keycode_) returns (address) {
        uint256 version = activeVersion[keycode_];
        if (version == 0) return address(0);
        return versions[keycode_][version].implementation;
    }

    /// @notice Get the latest implementation address for a module
    /// @param keycode_ The module keycode
    /// @return The latest implementation address
    function getLatestImplementation(bytes5 keycode_) external view moduleExists(keycode_) returns (address) {
        uint256 version = latestVersion[keycode_];
        return versions[keycode_][version].implementation;
    }

    /// @notice Check if a version is active
    /// @param keycode_ The module keycode
    /// @param version_ The version number
    /// @return Whether the version is active
    function isVersionActive(bytes5 keycode_, uint256 version_) external view moduleExists(keycode_) versionExists(keycode_, version_) returns (bool) {
        return versions[keycode_][version_].active;
    }

    /// @notice Check if a version is deprecated
    /// @param keycode_ The module keycode
    /// @param version_ The version number
    /// @return Whether the version is deprecated
    function isVersionDeprecated(bytes5 keycode_, uint256 version_) external view moduleExists(keycode_) versionExists(keycode_, version_) returns (bool) {
        return versions[keycode_][version_].deprecated;
    }

    /// @notice Get all versions for a module
    /// @param keycode_ The module keycode
    /// @return Array of version numbers
    function getAllVersions(bytes5 keycode_) external view moduleExists(keycode_) returns (uint256[] memory) {
        return allVersionsForModule[keycode_];
    }

    /// @notice Get version count for a module
    /// @param keycode_ The module keycode
    /// @return The number of versions
    function getVersionCount(bytes5 keycode_) external view moduleExists(keycode_) returns (uint256) {
        return allVersionsForModule[keycode_].length;
    }

    /// @notice Get detailed version data
    /// @param keycode_ The module keycode
    /// @param version_ The version number
    /// @return registered Whether the version is registered
    /// @return active Whether the version is active
    /// @return deprecated Whether the version is deprecated
    /// @return implementation The implementation address
    /// @return registeredAt When the version was registered
    /// @return activatedAt When the version was activated
    /// @return deactivatedAt When the version was deactivated
    /// @return deprecatedAt When the version was deprecated
    /// @return metadata Additional version metadata
    function getVersionData(bytes5 keycode_, uint256 version_) external view moduleExists(keycode_) versionExists(keycode_, version_) returns (
        bool registered,
        bool active,
        bool deprecated,
        address implementation,
        uint256 registeredAt,
        uint256 activatedAt,
        uint256 deactivatedAt,
        uint256 deprecatedAt,
        string memory metadata
    ) {
        VersionData memory data = versions[keycode_][version_];
        return (
            data.registered,
            data.active,
            data.deprecated,
            data.implementation,
            data.registeredAt,
            data.activatedAt,
            data.deactivatedAt,
            data.deprecatedAt,
            data.metadata
        );
    }
}