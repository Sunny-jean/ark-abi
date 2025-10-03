// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRiskMonitoringAI {
    event DataMonitored(bytes32 indexed dataHash, bool isRisky, string analysisResult);

    error UnauthorizedAccess(address caller);
    error InvalidData(bytes data);

    function submitForMonitoring(bytes calldata _data) external returns (bool isRisky, string memory analysisResult);
    function getMonitoringResult(bytes32 _dataHash) external view returns (bool isRisky, string memory analysisResult);
}