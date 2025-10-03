// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface AccessControlManager {
    /**
     * @dev Emitted when a role is granted to an address.
     * @param role The role that was granted.
     * @param account The address to which the role was granted.
     * @param granter The address that granted the role.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed granter);

    /**
     * @dev Emitted when a role is revoked from an address.
     * @param role The role that was revoked.
     * @param account The address from which the role was revoked.
     * @param revoker The address that revoked the role.
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed revoker);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a required parameter is missing or invalid.
     */
    error InvalidParameter(string parameterName, string description);

    /**
     * @dev Thrown when an account already has the specified role.
     */
    error RoleAlreadyGranted(bytes32 role, address account);

    /**
     * @dev Thrown when an account does not have the specified role.
     */
    error RoleNotGranted(bytes32 role, address account);

    /**
     * @dev Grants a role to a specific address.
     * @param role The role to grant (e.g., keccak256("ADMIN_ROLE")).
     * @param account The address to grant the role to.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes a role from a specific address.
     * @param role The role to revoke.
     * @param account The address to revoke the role from.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Checks if an address has a specific role.
     * @param role The role to check.
     * @param account The address to check.
     * @return hasRole True if the account has the role, false otherwise.
     */
    function hasRole(bytes32 role, address account) external view returns (bool hasRole);

    /**
     * @dev Renounces a role by the caller.
     * @param role The role to renounce.
     */
    function renounceRole(bytes32 role) external;
}