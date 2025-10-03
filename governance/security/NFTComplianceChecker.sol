// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INFTComplianceChecker {
    // 合規驗證模組
    function checkCompliance(uint256 _tokenId) external view returns (bool);
    function setComplianceRule(uint256 _ruleId, bool _enabled) external;

    event ComplianceRuleSet(uint256 indexed ruleId, bool enabled);

    error NonCompliant();
}