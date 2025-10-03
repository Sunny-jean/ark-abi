// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Kernel Core
/// @notice Central component for system coordination and module management
contract Kernel {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event ModuleInstalled(bytes5 indexed keycode, address indexed module);
    event ModuleUpgraded(bytes5 indexed keycode, address indexed oldModule, address indexed newModule);
    event PolicyActivated(address indexed policy);
    event PolicyDeactivated(address indexed policy);
    event ExecutorChanged(address indexed oldExecutor, address indexed newExecutor);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error Kernel_OnlyExecutor(address caller_);
    error Kernel_ModuleAlreadyInstalled(bytes5 keycode_);
    error Kernel_ModuleNotInstalled(bytes5 keycode_);
    error Kernel_PolicyAlreadyActivated(address policy_);
    error Kernel_PolicyNotActivated(address policy_);
    error Kernel_InvalidAddress(address addr_);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct ModuleData {
        address addr;
        bytes5 keycode;
        uint256 installTimestamp;
        uint256 lastUpgradeTimestamp;
    }

    struct PolicyData {
        address addr;
        bool isActive;
        uint256 activationTimestamp;
        uint256 deactivationTimestamp;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public executor;
    mapping(bytes5 => ModuleData) public modules;
    mapping(address => PolicyData) public policies;
    bytes5[] public allKeycodes;
    address[] public allPolicies;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyExecutor() {
        if (msg.sender != executor) revert Kernel_OnlyExecutor(msg.sender);
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address executor_) {
        if (executor_ == address(0)) revert Kernel_InvalidAddress(address(0));
        executor = executor_;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Install a new module
    /// @param keycode_ The module keycode
    /// @param moduleAddr_ The module address
    function installModule(bytes5 keycode_, address moduleAddr_) external onlyExecutor {
        if (modules[keycode_].addr != address(0)) revert Kernel_ModuleAlreadyInstalled(keycode_);
        if (moduleAddr_ == address(0)) revert Kernel_InvalidAddress(moduleAddr_);
        
        modules[keycode_] = ModuleData({
            addr: moduleAddr_,
            keycode: keycode_,
            installTimestamp: block.timestamp,
            lastUpgradeTimestamp: block.timestamp
        });
        
        allKeycodes.push(keycode_);
        
        emit ModuleInstalled(keycode_, moduleAddr_);
    }

    /// @notice Upgrade an existing module
    /// @param keycode_ The module keycode
    /// @param newModuleAddr_ The new module address
    function upgradeModule(bytes5 keycode_, address newModuleAddr_) external onlyExecutor {
        if (modules[keycode_].addr == address(0)) revert Kernel_ModuleNotInstalled(keycode_);
        if (newModuleAddr_ == address(0)) revert Kernel_InvalidAddress(newModuleAddr_);
        
        address oldModuleAddr = modules[keycode_].addr;
        modules[keycode_].addr = newModuleAddr_;
        modules[keycode_].lastUpgradeTimestamp = block.timestamp;
        
        emit ModuleUpgraded(keycode_, oldModuleAddr, newModuleAddr_);
    }

    /// @notice Activate a policy
    /// @param policyAddr_ The policy address
    function activatePolicy(address policyAddr_) external onlyExecutor {
        if (policies[policyAddr_].isActive) revert Kernel_PolicyAlreadyActivated(policyAddr_);
        if (policyAddr_ == address(0)) revert Kernel_InvalidAddress(policyAddr_);
        
        policies[policyAddr_] = PolicyData({
            addr: policyAddr_,
            isActive: true,
            activationTimestamp: block.timestamp,
            deactivationTimestamp: 0
        });
        
        allPolicies.push(policyAddr_);
        
        emit PolicyActivated(policyAddr_);
    }

    /// @notice Deactivate a policy
    /// @param policyAddr_ The policy address
    function deactivatePolicy(address policyAddr_) external onlyExecutor {
        if (!policies[policyAddr_].isActive) revert Kernel_PolicyNotActivated(policyAddr_);
        
        policies[policyAddr_].isActive = false;
        policies[policyAddr_].deactivationTimestamp = block.timestamp;
        
        emit PolicyDeactivated(policyAddr_);
    }

    /// @notice Change the executor
    /// @param newExecutor_ The new executor address
    function changeExecutor(address newExecutor_) external onlyExecutor {
        if (newExecutor_ == address(0)) revert Kernel_InvalidAddress(newExecutor_);
        
        address oldExecutor = executor;
        executor = newExecutor_;
        
        emit ExecutorChanged(oldExecutor, newExecutor_);
    }

    /// @notice Get the module address for a keycode
    /// @param keycode_ The module keycode
    /// @return The module address
    function getModuleAddress(bytes5 keycode_) external view returns (address) {
        return modules[keycode_].addr;
    }

    /// @notice Check if a policy is active
    /// @param policyAddr_ The policy address
    /// @return Whether the policy is active
    function isPolicyActive(address policyAddr_) external view returns (bool) {
        return policies[policyAddr_].isActive;
    }

    /// @notice Get the total number of modules
    /// @return The total number of modules
    function getModuleCount() external view returns (uint256) {
        return allKeycodes.length;
    }

    /// @notice Get the total number of policies
    /// @return The total number of policies
    function getPolicyCount() external view returns (uint256) {
        return allPolicies.length;
    }
}