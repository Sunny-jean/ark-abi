// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRoleBasedAccessControl {
    event RoleAssigned(address indexed account, string indexed roleName);
    event RoleRemoved(address indexed account, string indexed roleName);

    error RoleDoesNotExist(string roleName);
    error AccountAlreadyHasRole(address account, string roleName);
    error AccountDoesNotHaveRole(address account, string roleName);

    function assignRole(address _account, string memory _roleName) external;
    function removeRole(address _account, string memory _roleName) external;
    function checkRole(address _account, string memory _roleName) external view returns (bool);
}