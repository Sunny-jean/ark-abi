// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISecurityAuditManager {
    // 安全審計管理
    function scheduleAudit(string calldata _auditScope, uint256 _dueDate) external returns (uint256);
    function completeAudit(uint256 _auditId, string calldata _results) external;
    function getAuditStatus(uint256 _auditId) external view returns (string memory scope, uint256 dueDate, string memory results, bool completed);

    event AuditScheduled(uint256 indexed auditId, string auditScope, uint256 dueDate);
    event AuditCompleted(uint256 indexed auditId, string results);

    error AuditNotFound();
    error AuditAlreadyCompleted();
}