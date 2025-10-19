// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INFTAccessControl {
    function hasAccess(address _user, uint256 _permissionId) external view returns (bool);
    function grantAccess(address _user, uint256 _permissionId) external;
    function revokeAccess(address _user, uint256 _permissionId) external;

    event AccessGranted(address indexed user, uint256 indexed permissionId);
    event AccessRevoked(address indexed user, uint256 indexed permissionId);

    error Unauthorized();
}