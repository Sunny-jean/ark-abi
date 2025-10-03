// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface ICapComplianceChecker {
    event ComplianceChecked(uint256 currentSupply, uint256 cap, bool compliant, string message);

    error CapExceeded(uint256 currentSupply, uint256 cap);

    function checkCompliance(uint256 _currentSupply, uint256 _cap) external returns (bool);
    function setCapStrategy(string calldata _strategy) external;
    function getCapStrategy() external view returns (string memory);
}

contract CapComplianceChecker is ICapComplianceChecker, Ownable {
    string private s_capStrategy;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function checkCompliance(uint256 _currentSupply, uint256 _cap) external returns (bool) {
        bool compliant = _currentSupply <= _cap;
        string memory message = compliant ? "Current supply is within the cap." : "Current supply exceeds the cap.";
        emit ComplianceChecked(_currentSupply, _cap, compliant, message);
        if (!compliant) {
            revert CapExceeded(_currentSupply, _cap);
        }
        return compliant;
    }

    function setCapStrategy(string calldata _strategy) external onlyOwner {
        s_capStrategy = _strategy;
    }

    function getCapStrategy() external view returns (string memory) {
        return s_capStrategy;
    }
}