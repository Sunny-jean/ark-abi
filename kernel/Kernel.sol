// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

// Forward declarations for type compatibility
contract Module {}
contract Policy {}

/// @notice Main contract that acts as a central component registry for the protocol.
contract Kernel {
    // ============================================================================================//
    //                                        GLOBAL TYPES                                        //
    // ============================================================================================//

    enum Actions {
        InstallModule,
        UpgradeModule,
        ActivatePolicy,
        DeactivatePolicy,
        ChangeExecutor,
        MigrateKernel
    }

    type Keycode is bytes5;

    struct Permissions {
        Keycode keycode;
        bytes4 funcSelector;
    }

    // ============================================================================================//
    //                                            ERRORS                                            //
    // ============================================================================================//

    error Kernel_OnlyExecutor(address caller_);
    error Kernel_ModuleAlreadyInstalled(Keycode module_);
    error Kernel_InvalidModuleUpgrade(Keycode module_);
    error Kernel_PolicyAlreadyActivated(address policy_);
    error Kernel_PolicyNotActivated(address policy_);

    // ============================================================================================//
    //                                       STATE VARIABLES                                      //
    // ============================================================================================//

    address public executor;
    Keycode[] public allKeycodes;
    mapping(Keycode => Module) public getModuleForKeycode;
    mapping(Module => Keycode) public getKeycodeForModule;
    mapping(Keycode => Policy[]) public moduleDependents;
    mapping(Keycode => mapping(Policy => uint256)) public getDependentIndex;
    mapping(Keycode => mapping(Policy => mapping(bytes4 => bool))) public modulePermissions;
    Policy[] public activePolicies;
    mapping(Policy => uint256) public getPolicyIndex;

    // ============================================================================================//
    //                                          MODIFIERS                                           //
    // ============================================================================================//

    modifier onlyExecutor() {
        if (msg.sender != executor) revert Kernel_OnlyExecutor(msg.sender);
        _;
    }

    // ============================================================================================//
    //                                         CONSTRUCTOR                                          //
    // ============================================================================================//

    constructor() {
        executor = msg.sender;
    }

    // ============================================================================================//
    //                                        VIEW FUNCTIONS                                        //
    // ============================================================================================//

    function isPolicyActive(Policy policy_) public view returns (bool) {
        return getPolicyIndex[policy_] != 0;
    }

    function getActivePolicy(uint256 index_) public view returns (Policy) {
        return activePolicies[index_];
    }

    function getActivePolicies() public view returns (Policy[] memory) {
        return activePolicies;
    }
}