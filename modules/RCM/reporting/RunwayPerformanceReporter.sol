// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IRunwayPerformanceReporter {
    event PerformanceReported(uint256 indexed timestamp, string indexed reportHash);

    error ReportGenerationFailed(string message);

    function generateReport(uint256 _periodInDays) external;
    function getLastReportHash() external view returns (string memory);
}

contract RunwayPerformanceReporter is IRunwayPerformanceReporter, Ownable {
    string private s_lastReportHash;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function generateReport(uint256 _periodInDays) external onlyOwner {
        string memory reportContent = string(abi.encodePacked("Runway Performance Report for ", Strings.toString(_periodInDays), " days."));
        s_lastReportHash = string(abi.encodePacked(keccak256(abi.encodePacked(reportContent))));
        emit PerformanceReported(block.timestamp, s_lastReportHash);
    }

    function getLastReportHash() external view returns (string memory) {
        return s_lastReportHash;
    }
}

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";