// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITransactionMonitoringAI {
    event TransactionMonitored(address indexed transactionHash, bool isSuspicious, string analysisResult);

    error UnauthorizedAccess(address caller);
    error InvalidTransactionData(bytes data);

    function submitForMonitoring(bytes calldata _transactionData) external returns (bool isSuspicious, string memory analysisResult);
    function getMonitoringResult(bytes32 _transactionHash) external view returns (bool isSuspicious, string memory analysisResult);
}