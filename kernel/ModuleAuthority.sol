// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Module Authority
/// @notice Manages authorization for module access and permissions
contract ModuleAuthority {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    event AuthorityTransferred(address indexed from, address indexed to);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error ModuleAuthority_OnlyAdmin(address caller_);
    error ModuleAuthority_RoleRequired(bytes32 role_);
    error ModuleAuthority_InvalidRole(bytes32 role_);

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    mapping(bytes32 => mapping(address => bool)) public hasRole;
    mapping(bytes32 => bool) public roleExists;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert ModuleAuthority_OnlyAdmin(msg.sender);
        _;
    }

    modifier onlyRole(bytes32 role_) {
        if (!hasRole[role_][msg.sender]) revert ModuleAuthority_RoleRequired(role_);
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, bytes32[] memory initialRoles_) {
        admin = admin_;
        
        // Register initial roles
        for (uint256 i = 0; i < initialRoles_.length; i++) {
            roleExists[initialRoles_[i]] = true;
        }
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function createRole(bytes32 role_) external onlyAdmin {
        roleExists[role_] = true;
    }

    function grantRole(bytes32 role_, address account_) external onlyAdmin {
        if (!roleExists[role_]) revert ModuleAuthority_InvalidRole(role_);
        
        hasRole[role_][account_] = true;
        emit RoleGranted(role_, account_, msg.sender);
    }

    function revokeRole(bytes32 role_, address account_) external onlyAdmin {
        if (!roleExists[role_]) revert ModuleAuthority_InvalidRole(role_);
        
        hasRole[role_][account_] = false;
        emit RoleRevoked(role_, account_, msg.sender);
    }

    function transferAuthority(address newAdmin_) external onlyAdmin {
        admin = newAdmin_;
        emit AuthorityTransferred(msg.sender, newAdmin_);
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function checkRole(bytes32 role_, address account_) external view returns (bool) {
        return hasRole[role_][account_];
    }
}