// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INFTSecurityProtocol {
    function enforceSecurityPolicy(uint256 _tokenId) external;
    function setSecurityPolicy(address _policy) external;

    event SecurityPolicyEnforced(uint256 indexed tokenId);
    event SecurityPolicySet(address indexed policy);

    error SecurityPolicyViolation();
}