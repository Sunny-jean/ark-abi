// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ILendingSecurityPolicy {
    // 借貸風險總體策略
    function enforcePolicy(address _user, address _asset, uint256 _amount) external view returns (bool);
    function setPolicyParameter(uint256 _paramId, uint256 _value) external;
    function getPolicyParameter(uint256 _paramId) external view returns (uint256);

    event PolicyParameterSet(uint256 indexed paramId, uint256 value);

    error PolicyViolation();
}