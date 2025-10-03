// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Kernel Lifecycle Manager
/// @notice Manages the lifecycle of the kernel system
contract KernelLifecycleManager {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event KernelInitialized(uint256 timestamp);
    event KernelUpgraded(uint256 oldVersion, uint256 newVersion, uint256 timestamp);
    event KernelPaused(address indexed pauser, uint256 timestamp);
    event KernelUnpaused(address indexed unpauser, uint256 timestamp);
    event KernelShutdown(address indexed initiator, uint256 timestamp);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error KernelLifecycleManager_OnlyAdmin(address caller_);
    error KernelLifecycleManager_AlreadyInitialized();
    error KernelLifecycleManager_NotInitialized();
    error KernelLifecycleManager_Paused();
    error KernelLifecycleManager_NotPaused();
    error KernelLifecycleManager_AlreadyShutdown();
    error KernelLifecycleManager_InvalidVersion(uint256 version_);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct VersionData {
        uint256 version;
        uint256 timestamp;
        bytes32 commitHash;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    bool public initialized;
    bool public paused;
    bool public _shutdown;
    uint256 public currentVersion;
    mapping(uint256 => VersionData) public versionHistory;
    uint256 public versionCount;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert KernelLifecycleManager_OnlyAdmin(msg.sender);
        _;
    }

    modifier whenInitialized() {
        if (!initialized) revert KernelLifecycleManager_NotInitialized();
        _;
    }

    modifier whenNotPaused() {
        if (paused) revert KernelLifecycleManager_Paused();
        _;
    }

    modifier whenPaused() {
        if (!paused) revert KernelLifecycleManager_NotPaused();
        _;
    }

    modifier whenNotShutdown() {
        if (_shutdown) revert KernelLifecycleManager_AlreadyShutdown();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_) {
        admin = admin_;
        initialized = false;
        paused = false;
        _shutdown = false;
        currentVersion = 0;
        versionCount = 0;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Initialize the kernel system
    /// @param initialVersion_ The initial version
    /// @param commitHash_ The commit hash of the initial version
    function initialize(uint256 initialVersion_, bytes32 commitHash_) external onlyAdmin {
        if (initialized) revert KernelLifecycleManager_AlreadyInitialized();
        
        initialized = true;
        currentVersion = initialVersion_;
        
        versionHistory[initialVersion_] = VersionData({
            version: initialVersion_,
            timestamp: block.timestamp,
            commitHash: commitHash_
        });
        
        versionCount = 1;
        
        emit KernelInitialized(block.timestamp);
    }

    /// @notice Upgrade the kernel system to a new version
    /// @param newVersion_ The new version
    /// @param commitHash_ The commit hash of the new version
    function upgrade(uint256 newVersion_, bytes32 commitHash_) external onlyAdmin whenInitialized whenNotPaused whenNotShutdown {
        if (newVersion_ <= currentVersion) revert KernelLifecycleManager_InvalidVersion(newVersion_);
        
        uint256 oldVersion = currentVersion;
        currentVersion = newVersion_;
        
        versionHistory[newVersion_] = VersionData({
            version: newVersion_,
            timestamp: block.timestamp,
            commitHash: commitHash_
        });
        
        versionCount++;
        
        emit KernelUpgraded(oldVersion, newVersion_, block.timestamp);
    }

    /// @notice Pause the kernel system
    function pause() external onlyAdmin whenInitialized whenNotPaused whenNotShutdown {
        paused = true;
        emit KernelPaused(msg.sender, block.timestamp);
    }

    /// @notice Unpause the kernel system
    function unpause() external onlyAdmin whenInitialized whenPaused whenNotShutdown {
        paused = false;
        emit KernelUnpaused(msg.sender, block.timestamp);
    }

    /// @notice Shutdown the kernel system permanently
    function shutdown() external onlyAdmin whenInitialized whenNotShutdown {
        _shutdown = true;
        emit KernelShutdown(msg.sender, block.timestamp);
    }

    /// @notice Get the current version of the kernel system
    /// @return The current version
    function getVersion() external view returns (uint256) {
        return currentVersion;
    }

    /// @notice Get the version data for a specific version
    /// @param version_ The version to get data for
    /// @return The version, timestamp, and commit hash
    function getVersionData(uint256 version_) external view returns (uint256, uint256, bytes32) {
        VersionData memory data = versionHistory[version_];
        return (data.version, data.timestamp, data.commitHash);
    }

    /// @notice Get the system status
    /// @return Whether the system is initialized, paused, and shutdown
    function getStatus() external view returns (bool, bool, bool) {
        return (initialized, paused, _shutdown);
    }
}