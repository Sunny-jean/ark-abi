// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IRunwayExtensionStrategy {
    event StrategyExecuted(string indexed strategyName, uint256 indexed extendedDays, uint256 timestamp);

    error StrategyFailed(string message);

    function executeStrategy(string calldata _strategyName, uint256 _currentRunwayDays) external;
    function setStrategyParameters(string calldata _strategyName, bytes calldata _parameters) external;
}

contract RunwayExtensionStrategy is IRunwayExtensionStrategy, Ownable {
    mapping(string => bytes) private s_strategyParameters;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function executeStrategy(string calldata _strategyName, uint256 _currentRunwayDays) external onlyOwner {
        require(s_strategyParameters[_strategyName].length > 0, "Strategy parameters not set.");


        // This would involve decoding _parameters and performing actions.
        uint256 extendedDays = 0; // Example extension
        if (keccak256(abi.encodePacked(_strategyName)) == keccak256(abi.encodePacked("CostReduction"))) {
            extendedDays = 30; // Simulate 30 days extension from cost reduction
        } else if (keccak256(abi.encodePacked(_strategyName)) == keccak256(abi.encodePacked("RevenueIncrease"))) {
            extendedDays = 60; // Simulate 60 days extension from revenue increase
        } else {
            revert StrategyFailed("Unknown strategy name.");
        }

        emit StrategyExecuted(_strategyName, extendedDays, block.timestamp);
    }

    function setStrategyParameters(string calldata _strategyName, bytes calldata _parameters) external onlyOwner {
        s_strategyParameters[_strategyName] = _parameters;
    }
}