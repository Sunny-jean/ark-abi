// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPermissionManager {
    event PermissionRegistered(string indexed permissionName, bytes32 indexed permissionHash);
    event PermissionUpdated(string indexed permissionName, bytes32 indexed oldHash, bytes32 indexed newHash);
    event PermissionRevoked(string indexed permissionName, bytes32 indexed permissionHash);

    error PermissionAlreadyExists(string permissionName);
    error PermissionNotFound(string permissionName);
    error UnauthorizedPermissionChange(address caller);

    function registerPermission(string memory _permissionName, bytes32 _permissionHash) external;
    function updatePermission(string memory _permissionName, bytes32 _newPermissionHash) external;
    function revokePermission(string memory _permissionName) external;
    function checkPermission(string memory _permissionName, bytes32 _permissionHash) external view returns (bool);
}