// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IMintingIntegrityVerifier {
    event IntegrityVerified(bool indexed consistent, string message);

    error InconsistentData(string reason);

    function verifyMintingIntegrity(uint256 _actualSupply, uint256 _daoApprovedSupply) external returns (bool);
    function setDaoApprovalSource(address _source) external;
    function getDaoApprovalSource() external view returns (address);
}

contract MintingIntegrityVerifier is IMintingIntegrityVerifier, Ownable {
    address private s_daoApprovalSource;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function verifyMintingIntegrity(uint256 _actualSupply, uint256 _daoApprovedSupply) external returns (bool) {
        bool consistent = (_actualSupply == _daoApprovedSupply);
        string memory message = consistent ? "Actual supply matches DAO approved record." : "Actual supply does not match DAO approved record.";
        emit IntegrityVerified(consistent, message);
        if (!consistent) {
            revert InconsistentData(message);
        }
        return consistent;
    }

    function setDaoApprovalSource(address _source) external onlyOwner {
        require(_source != address(0), "Invalid source address");
        s_daoApprovalSource = _source;
    }

    function getDaoApprovalSource() external view returns (address) {
        return s_daoApprovalSource;
    }
}