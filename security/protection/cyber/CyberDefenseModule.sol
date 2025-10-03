// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICyberDefenseModule {
    event DefenseActivated(string indexed defenseType);
    event DefenseDeactivated(string indexed defenseType);

    error UnauthorizedAccess(address caller);
    error InvalidDefenseType(string defenseType);

    function activateDefense(string memory _defenseType) external;
    function deactivateDefense(string memory _defenseType) external;
    function isDefenseActive(string memory _defenseType) external view returns (bool);
}