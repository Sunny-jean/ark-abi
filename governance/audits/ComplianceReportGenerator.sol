// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IComplianceReportGenerator {
    function generateComplianceReport(uint256 _reportId) external view returns (string memory);
    function setComplianceStandard(string calldata _standard) external;
    function getComplianceStandard() external view returns (string memory);

    event ComplianceReportGenerated(uint256 indexed reportId);
    event ComplianceStandardSet(string standard);

    error ReportGenerationFailed();
}