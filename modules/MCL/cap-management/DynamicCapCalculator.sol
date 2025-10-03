// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IDynamicCapCalculator {
    event CapCalculated(uint256 calculatedCap, string indexed parameters);
    event ParameterSourceSet(address indexed oldSource, address indexed newSource);

    error InvalidParameterSource(address source);
    error CalculationFailed();

    function calculateMaxMintCap() external returns (uint256);
    function setParameterSource(address _source) external;
    function getParameterSource() external view returns (address);
}

contract DynamicCapCalculator is IDynamicCapCalculator, Ownable {
    address private s_parameterSource;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function calculateMaxMintCap() external returns (uint256) {

        // from s_parameterSource (e.g., TVL, premium data) and apply a formula.
        // For demonstration, we return a fixed value or a simple calculation.
        if (s_parameterSource == address(0)) {
            revert CalculationFailed();
        }
        uint256 calculatedCap = 1000000 * 10 ** 18; // Example: 1 million tokens
        emit CapCalculated(calculatedCap, "Simple Calculation");
        return calculatedCap;
    }

    function setParameterSource(address _source) external onlyOwner {
        require(_source != address(0), "Invalid parameter source address");
        emit ParameterSourceSet(s_parameterSource, _source);
        s_parameterSource = _source;
    }

    function getParameterSource() external view returns (address) {
        return s_parameterSource;
    }
}