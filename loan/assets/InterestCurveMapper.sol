// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IInterestCurveMapper {
    function setInterestCurve(address _asset, address _curveAddress) external;
    function getInterestCurve(address _asset) external view returns (address);

    event InterestCurveSet(address indexed asset, address curveAddress);

    error InvalidCurveAddress();
}