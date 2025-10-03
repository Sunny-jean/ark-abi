// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IABICompatibilityChecker {
    event ABICompatible(address indexed contractA, address indexed contractB);

    error ABIIncompatible(address contractA, address contractB);

    function isABICompatible(address _contractA, address _contractB) external view returns (bool);
}