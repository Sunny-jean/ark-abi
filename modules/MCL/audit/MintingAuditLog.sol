// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IMintingAuditLog {
    event MintingLogged(address indexed minter, uint256 amount, uint256 timestamp, string indexed reason);

    function logMinting(address _minter, uint256 _amount, string calldata _reason) external;
    function getMintingLogCount() external view returns (uint256);
    function getMintingLogEntry(uint256 index) external view returns (address minter, uint256 amount, uint256 timestamp, string memory reason);
}

contract MintingAuditLog is IMintingAuditLog, Ownable {
    struct MintLogEntry {
        address minter;
        uint256 amount;
        uint256 timestamp;
        string reason;
    }

    MintLogEntry[] private s_mintingLogs;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function logMinting(address _minter, uint256 _amount, string calldata _reason) external onlyOwner {
        s_mintingLogs.push(MintLogEntry({
            minter: _minter,
            amount: _amount,
            timestamp: block.timestamp,
            reason: _reason
        }));
        emit MintingLogged(_minter, _amount, block.timestamp, _reason);
    }

    function getMintingLogCount() external view returns (uint256) {
        return s_mintingLogs.length;
    }

    function getMintingLogEntry(uint256 index) external view returns (address minter, uint256 amount, uint256 timestamp, string memory reason) {
        require(index < s_mintingLogs.length, "Invalid log index");
        MintLogEntry storage entry = s_mintingLogs[index];
        return (entry.minter, entry.amount, entry.timestamp, entry.reason);
    }
}