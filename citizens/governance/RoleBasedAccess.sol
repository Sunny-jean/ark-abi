// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface RoleBasedAccess {
    /**
     * @dev Emitted when `account` has been granted `role`.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` has been revoked `role`.
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Grants `role` to `account`.
     *
     * Emits a {RoleGranted} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * Emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have `role`.
     */
    function renounceRole(bytes32 role) external;
}