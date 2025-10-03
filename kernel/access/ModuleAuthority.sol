// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Module Authority
/// @notice Controls access and permissions for modules in the system
contract ModuleAuthority {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event PermissionGranted(bytes32 indexed moduleId, address indexed account, bytes4 indexed functionSelector);
    event PermissionRevoked(bytes32 indexed moduleId, address indexed account, bytes4 indexed functionSelector);
    event RoleAssigned(bytes32 indexed role, address indexed account);
    event RoleRemoved(bytes32 indexed role, address indexed account);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error ModuleAuthority_Unauthorized(address caller_, bytes32 moduleId_, bytes4 selector_);
    error ModuleAuthority_InvalidRole(bytes32 role_);
    error ModuleAuthority_OnlyAdmin(address caller_);
    error ModuleAuthority_ZeroAddress();

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    mapping(bytes32 => mapping(address => mapping(bytes4 => bool))) public hasPermission;
    mapping(bytes32 => mapping(address => bool)) public hasRole;
    mapping(bytes32 => bool) public roleExists;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert ModuleAuthority_OnlyAdmin(msg.sender);
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, bytes32[] memory initialRoles_) {
        if (admin_ == address(0)) revert ModuleAuthority_ZeroAddress();
        admin = admin_;
        
        for (uint256 i = 0; i < initialRoles_.length; i++) {
            roleExists[initialRoles_[i]] = true;
        }
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Check if an account has permission to call a function on a module
    /// @param moduleId_ The module identifier
    /// @param account_ The account to check
    /// @param selector_ The function selector
    /// @return Whether the account has permission
    function checkPermission(bytes32 moduleId_, address account_, bytes4 selector_) external view returns (bool) {
        return hasPermission[moduleId_][account_][selector_];
    }

    /// @notice Grant permission to an account for a specific function on a module
    /// @param moduleId_ The module identifier
    /// @param account_ The account to grant permission to
    /// @param selector_ The function selector
    function grantPermission(bytes32 moduleId_, address account_, bytes4 selector_) external onlyAdmin {
        hasPermission[moduleId_][account_][selector_] = true;
        emit PermissionGranted(moduleId_, account_, selector_);
    }

    /// @notice Revoke permission from an account for a specific function on a module
    /// @param moduleId_ The module identifier
    /// @param account_ The account to revoke permission from
    /// @param selector_ The function selector
    function revokePermission(bytes32 moduleId_, address account_, bytes4 selector_) external onlyAdmin {
        hasPermission[moduleId_][account_][selector_] = false;
        emit PermissionRevoked(moduleId_, account_, selector_);
    }

    /// @notice Assign a role to an account
    /// @param role_ The role to assign
    /// @param account_ The account to assign the role to
    function assignRole(bytes32 role_, address account_) external onlyAdmin {
        if (!roleExists[role_]) revert ModuleAuthority_InvalidRole(role_);
        hasRole[role_][account_] = true;
        emit RoleAssigned(role_, account_);
    }

    /// @notice Remove a role from an account
    /// @param role_ The role to remove
    /// @param account_ The account to remove the role from
    function removeRole(bytes32 role_, address account_) external onlyAdmin {
        if (!roleExists[role_]) revert ModuleAuthority_InvalidRole(role_);
        hasRole[role_][account_] = false;
        emit RoleRemoved(role_, account_);
    }

    /// @notice Get all roles for an account
    /// @param account_ The account to get roles for
    /// @param roles_ The roles to check
    /// @return result An array of booleans indicating whether the account has each role
    function getRoles(address account_, bytes32[] calldata roles_) external view returns (bool[] memory) {
        bool[] memory result = new bool[](roles_.length);
        for (uint256 i = 0; i < roles_.length; i++) {
            result[i] = hasRole[roles_[i]][account_];
        }
        return result;
    }
}