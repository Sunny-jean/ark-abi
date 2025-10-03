// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IContractUpgradeHelper {
    event UpgradeScheduled(address indexed oldContract, address indexed newContract, uint256 indexed upgradeTime);
    event UpgradeCompleted(address indexed oldContract, address indexed newContract);

    error UpgradeAlreadyScheduled(address oldContract);
    error NoUpgradeScheduled(address oldContract);
    error UpgradeNotReady(address oldContract);

    function scheduleUpgrade(address _oldContract, address _newContract, uint256 _upgradeTime) external;
    function completeUpgrade(address _oldContract) external;
    function getScheduledUpgrade(address _oldContract) external view returns (address newContract, uint256 upgradeTime);
}