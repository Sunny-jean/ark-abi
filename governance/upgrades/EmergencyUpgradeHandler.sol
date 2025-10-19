// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEmergencyUpgradeHandler {
    function triggerEmergencyUpgrade(address _newImplementation) external;
    function setEmergencyAdmin(address _admin) external;
    function getEmergencyAdmin() external view returns (address);

    event EmergencyUpgradeTriggered(address indexed newImplementation);
    event EmergencyAdminSet(address indexed admin);

    error NotEmergencyAdmin();
}