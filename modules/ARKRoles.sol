// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @notice Module that holds multisig roles needed by various policies.
contract ARKRoles {
    // ============================================================================================//
    //                                            ERRORS                                            //
    // ============================================================================================//

    error ROLES_InvalidRole(bytes32 role_);
    error ROLES_RequireRole(bytes32 role_);
    error ROLES_AddressAlreadyHasRole(address addr_, bytes32 role_);
    error ROLES_AddressDoesNotHaveRole(address addr_, bytes32 role_);
    error Module_PolicyNotPermitted(address policy_);

    // ============================================================================================//
    //                                       STATE VARIABLES                                      //
    // ============================================================================================//

    mapping(address => mapping(bytes32 => bool)) public hasRole;

    // ============================================================================================//
    //                                          MODIFIERS                                           //
    // ============================================================================================//
    modifier permissioned() {
        _;
    }

    // ============================================================================================//
    //                                       CORE FUNCTIONS                                       //
    // ============================================================================================//

    function saveRole(bytes32, address) external permissioned {
        revert Module_PolicyNotPermitted(msg.sender);
    }

    function removeRole(bytes32, address) external permissioned {
        revert Module_PolicyNotPermitted(msg.sender);
    }

    // ============================================================================================//
    //                                       VIEW FUNCTIONS                                       //
    // ============================================================================================//

    function KEYCODE() public pure returns (bytes5) {
        return bytes5("ROLES");
    }

    function VERSION() external pure returns (uint8 major, uint8 minor) {
        return (1, 0);
    }

    function requireRole(bytes32 role_, address) external pure {
        revert ROLES_RequireRole(role_);
    }

    function ensureValidRole(bytes32) public pure {
        // add something here - CHANGE
    }
} 