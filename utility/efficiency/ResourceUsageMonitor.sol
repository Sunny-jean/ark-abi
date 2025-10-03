// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IResourceUsageMonitor {
    event GasUsageReport(address indexed contractAddress, uint256 gasUsed);
    event StorageUsageReport(address indexed contractAddress, uint256 storageUsed);

    function getGasUsage(address _contractAddress) external view returns (uint256);
    function getStorageUsage(address _contractAddress) external view returns (uint256);
}