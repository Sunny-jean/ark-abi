// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INFTPermissionValidator {
    // 權限驗證器
    function validatePermission(address _user, uint256 _permissionId) external view returns (bool);
    function setPermission(uint256 _permissionId, bool _enabled) external;
    function getPermissionStatus(uint256 _permissionId) external view returns (bool);

    event PermissionSet(uint256 indexed permissionId, bool enabled);

    error PermissionDenied();
}