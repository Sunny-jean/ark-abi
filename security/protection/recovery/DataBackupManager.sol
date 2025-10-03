// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDataBackupManager {
    event BackupCreated(bytes32 indexed backupId, uint256 timestamp);
    event DataRestored(bytes32 indexed backupId, uint256 timestamp);

    error UnauthorizedBackup(address caller);
    error BackupNotFound(bytes32 backupId);

    function createBackup() external returns (bytes32);
    function restoreData(bytes32 _backupId) external;
    function getBackupTimestamp(bytes32 _backupId) external view returns (uint256);
}