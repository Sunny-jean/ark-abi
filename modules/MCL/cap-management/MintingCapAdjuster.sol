// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IMintingCapAdjuster {
    event CapAdjusted(uint256 oldCap, uint256 newCap, address indexed adjuster);
    event AdjustmentStrategySet(address indexed oldStrategy, address indexed newStrategy);

    error UnauthorizedAdjustment();
    error InvalidAdjustmentValue(uint256 value);

    function adjustMintCap(uint256 _newCap) external;
    function setAdjustmentStrategy(address _strategy) external;
    function getAdjustmentStrategy() external view returns (address);
}

contract MintingCapAdjuster is IMintingCapAdjuster, Ownable {
    address private s_adjustmentStrategy;
    uint256 private s_currentCap;

    constructor(address initialOwner, uint256 initialCap) Ownable(initialOwner) {
        s_currentCap = initialCap;
    }

    function adjustMintCap(uint256 _newCap) external onlyOwner {
        // In a real scenario, this would interact with MintCapGuard
        // For now, we'll just emit an event.
        // require(IMintCapGuard(address(mintCapGuard)).setMintCap(_newCap), "Failed to set new cap");
        uint256 oldCap = s_currentCap;
        s_currentCap = _newCap;
        emit CapAdjusted(oldCap, _newCap, msg.sender);
    }

    function setAdjustmentStrategy(address _strategy) external onlyOwner {
        require(_strategy != address(0), "Invalid strategy address");
        emit AdjustmentStrategySet(s_adjustmentStrategy, _strategy);
        s_adjustmentStrategy = _strategy;
    }

    function getAdjustmentStrategy() external view returns (address) {
        return s_adjustmentStrategy;
    }
}