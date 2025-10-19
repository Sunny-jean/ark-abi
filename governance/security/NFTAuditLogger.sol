// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INFTAuditLogger {
    function logAction(string calldata _action, address _by, uint256 _tokenId) external;
    function getActionLog(uint256 _logId) external view returns (string memory action, address by, uint256 tokenId, uint256 timestamp);

    event ActionLogged(uint256 indexed logId, string action, address indexed by, uint256 indexed tokenId, uint256 timestamp);

    error LogNotFound();
}