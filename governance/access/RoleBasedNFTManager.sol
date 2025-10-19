// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRoleBasedNFTManager {
    function assignRole(address _user, uint256 _roleId) external;
    function revokeRole(address _user, uint256 _roleId) external;
    function getRole(address _user) external view returns (uint256);

    event RoleAssigned(address indexed user, uint256 indexed roleId);
    event RoleRevoked(address indexed user, uint256 indexed roleId);

    error InvalidRole();
}