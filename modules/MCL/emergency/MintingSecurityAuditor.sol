// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IMintingSecurityAuditor {
    event AuditPerformed(address indexed auditor, bool indexed compliant, string message);

    error AuditFailed(string reason);

    function performAudit(address _mintingContract) external;
    function setAuditRules(string calldata _rules) external;
    function getAuditRules() external view returns (string memory);
}

contract MintingSecurityAuditor is IMintingSecurityAuditor, Ownable {
    string private s_auditRules;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function performAudit(address _mintingContract) external onlyOwner {

        // In a real scenario, this would interact with the _mintingContract
        // to check its state, events, and adherence to predefined rules.
        bool compliant = true; // Assume compliant for now
        string memory message = "Audit completed successfully.";

        if (_mintingContract == address(0)) {
            compliant = false;
            message = "Minting contract address is zero.";
        }

        emit AuditPerformed(msg.sender, compliant, message);
    }

    function setAuditRules(string calldata _rules) external onlyOwner {
        s_auditRules = _rules;
    }

    function getAuditRules() external view returns (string memory) {
        return s_auditRules;
    }
}