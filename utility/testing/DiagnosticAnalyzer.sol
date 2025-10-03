// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDiagnosticAnalyzer {
    event DiagnosticReport(string indexed issueType, string indexed description, bytes details);

    function analyzeContract(address _contractAddress) external returns (string memory);
    function getIssueDetails(string memory _issueType) external view returns (bytes memory);
}