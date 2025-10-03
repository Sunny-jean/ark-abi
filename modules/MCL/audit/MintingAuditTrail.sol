// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IMintingAuditTrail {
    event MintingEventRecorded(uint256 indexed eventId, address indexed minter, uint256 amount, uint256 timestamp, string description);

    function recordMintingEvent(address _minter, uint256 _amount, string calldata _description) external;
    function getMintingEventCount() external view returns (uint256);
    function getMintingEvent(uint256 _index) external view returns (uint256 eventId, address minter, uint256 amount, uint256 timestamp, string memory description);
}

contract MintingAuditTrail is IMintingAuditTrail, Ownable {
    struct MintingEvent {
        uint256 eventId;
        address minter;
        uint256 amount;
        uint256 timestamp;
        string description;
    }

    MintingEvent[] private s_mintingEvents;
    uint256 private s_nextEventId;

    constructor(address initialOwner) Ownable(initialOwner) {
        s_nextEventId = 1;
    }

    function recordMintingEvent(address _minter, uint256 _amount, string calldata _description) external onlyOwner {
        s_mintingEvents.push(MintingEvent({
            eventId: s_nextEventId,
            minter: _minter,
            amount: _amount,
            timestamp: block.timestamp,
            description: _description
        }));
        emit MintingEventRecorded(s_nextEventId, _minter, _amount, block.timestamp, _description);
        s_nextEventId++;
    }

    function getMintingEventCount() external view returns (uint256) {
        return s_mintingEvents.length;
    }

    function getMintingEvent(uint256 _index) external view returns (uint256 eventId, address minter, uint256 amount, uint256 timestamp, string memory description) {
        require(_index < s_mintingEvents.length, "Invalid event index");
        MintingEvent storage eventEntry = s_mintingEvents[_index];
        return (eventEntry.eventId, eventEntry.minter, eventEntry.amount, eventEntry.timestamp, eventEntry.description);
    }
}