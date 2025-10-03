// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGasEstimator {
    event GasEstimated(string indexed functionName, uint256 gasCost);

    function estimateGas(address _target, bytes memory _callData) external returns (uint256);
}