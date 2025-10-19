// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IFinancialReporting {
    function generateReport(uint256 _reportId) external view returns (string memory);
    function setReportingPeriod(uint256 _period) external;
    function getReportingPeriod() external view returns (uint256);

    event ReportGenerated(uint256 indexed reportId);
    event ReportingPeriodSet(uint256 period);

    error ReportNotFound();
}