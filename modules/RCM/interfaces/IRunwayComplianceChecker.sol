// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRunwayComplianceChecker {
    event ComplianceChecked(bool indexed isCompliant, uint256 timestamp);

    error ComplianceViolation(string message);

    function checkCompliance() external view returns (bool);
    function getComplianceRules() external view returns (string[] memory);
}