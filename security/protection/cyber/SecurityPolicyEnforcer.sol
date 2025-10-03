// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISecurityPolicyEnforcer {
    event PolicyEnforced(bytes32 indexed policyId, bool success);

    error UnauthorizedEnforcer(address caller);
    error PolicyViolation(bytes32 policyId);

    function enforcePolicy(bytes32 _policyId, bytes calldata _data) external returns (bool);
    function isPolicyCompliant(bytes32 _policyId, bytes calldata _data) external view returns (bool);
}