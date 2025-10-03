// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface AccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as `role`'s admin role, as well
     * as when `role` is first defined by assigning the first member.
     * Can be used by clients to track role grants/revokes/renames.
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     * `sender` is the account that originated the grant.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     * `sender` is the account that originated the revoke.
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    // Errors

    /**
     * @dev Thrown when an address does not have the required role.
     */
    error AccessControlUnauthorizedAccount(address account, bytes32 role);

    /**
     * @dev Thrown when a role is not found.
     */
    error RoleNotFound(bytes32 role);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Grants `role` to `account`.
     * If `account` had not been already granted `role`, emits a {RoleGranted} event.
     * Requirements:
     * - the caller must have `role`'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     * Requirements:
     * - the caller must have `role`'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     * Roles are often managed via {grantRole} and {revokeRole}: this function's purpose is to provide a mechanism for accounts to lose their privileges if they are compromised (for example, by revoking a role from their own account).
     * Requirements:
     * - the caller must have `role`.
     */
    function renounceRole(bytes32 role, address account) external;

    /**
     * @dev Returns the admin role that controls `role`.
     * See {grantRole} and {revokeRole}.
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
}