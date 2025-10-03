// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IThreatIntelligenceFeed {
    event ThreatAdded(bytes32 indexed threatHash, string indexed threatType);
    event ThreatRemoved(bytes32 indexed threatHash);

    error UnauthorizedFeed(address caller);
    error ThreatNotFound(bytes32 threatHash);

    function addThreat(bytes32 _threatHash, string memory _threatType) external;
    function removeThreat(bytes32 _threatHash) external;
    function isThreatKnown(bytes32 _threatHash) external view returns (bool);
}