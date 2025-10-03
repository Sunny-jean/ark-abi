// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRunwayComplianceChecker {
    event ComplianceChecked(bool indexed compliant, string indexed message, uint256 timestamp);

    error ComplianceError(string message);

    function checkCompliance(uint256 _currentRunwayDays) external;
    function setComplianceThreshold(uint256 _threshold) external;
}

contract RunwayComplianceChecker is IRunwayComplianceChecker, Ownable {
    uint256 private s_complianceThreshold;

    constructor(address initialOwner, uint256 initialThreshold) Ownable(initialOwner) {
        s_complianceThreshold = initialThreshold;
    }

    function checkCompliance(uint256 _currentRunwayDays) external onlyOwner {
        if (_currentRunwayDays < s_complianceThreshold) {
            emit ComplianceChecked(false, "Runway below compliance threshold.", block.timestamp);
            revert ComplianceError("Runway below compliance threshold.");
        } else {
            emit ComplianceChecked(true, "Runway is compliant.", block.timestamp);
        }
    }

    function setComplianceThreshold(uint256 _threshold) external onlyOwner {
        s_complianceThreshold = _threshold;
    }
}