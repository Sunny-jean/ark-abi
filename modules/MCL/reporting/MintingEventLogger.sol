// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IMintingEventLogger {
    event CapChangeLogged(uint256 indexed oldCap, uint256 indexed newCap, uint256 timestamp, string indexed reason);

    function logCapChange(uint256 _oldCap, uint256 _newCap, string calldata _reason) external;
    function getCapChangeLogCount() external view returns (uint256);
    function getCapChangeLogEntry(uint256 index) external view returns (uint256 oldCap, uint256 newCap, uint256 timestamp, string memory reason);
}

contract MintingEventLogger is IMintingEventLogger, Ownable {
    struct CapChangeEvent {
        uint256 oldCap;
        uint256 newCap;
        uint256 timestamp;
        string reason;
    }

    CapChangeEvent[] private s_capChangeLogs;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function logCapChange(uint256 _oldCap, uint256 _newCap, string calldata _reason) external onlyOwner {
        string memory reasonMemory = _reason;
        s_capChangeLogs.push(CapChangeEvent({
            oldCap: _oldCap,
            newCap: _newCap,
            timestamp: block.timestamp,
            reason: _reason
        }));
        emit CapChangeLogged(_oldCap, _newCap, block.timestamp, _reason);
    }

    function getCapChangeLogCount() external view returns (uint256) {
        return s_capChangeLogs.length;
    }

    function getCapChangeLogEntry(uint256 index) external view returns (uint256 oldCap, uint256 newCap, uint256 timestamp, string memory reason) {
        require(index < s_capChangeLogs.length, "Invalid log index");
        CapChangeEvent storage entry = s_capChangeLogs[index];
        return (entry.oldCap, entry.newCap, entry.timestamp, entry.reason);
    }
}