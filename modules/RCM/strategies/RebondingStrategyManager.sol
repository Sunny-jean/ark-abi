// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRebondingStrategyManager {
    event StrategySet(string indexed strategyName, uint256 indexed bondAmount, uint256 indexed duration);

    error InvalidStrategy(string message);

    function setRebondingStrategy(string calldata _strategyName, uint256 _bondAmount, uint256 _duration) external;
    function getRebondingStrategy(string calldata _strategyName) external view returns (uint256 bondAmount, uint256 duration);
}

contract RebondingStrategyManager is IRebondingStrategyManager, Ownable {
    struct RebondingStrategy {
        uint256 bondAmount;
        uint256 duration;
    }

    mapping(string => RebondingStrategy) private s_strategies;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function setRebondingStrategy(string calldata _strategyName, uint256 _bondAmount, uint256 _duration) external onlyOwner {
        require(_bondAmount > 0 && _duration > 0, "Bond amount and duration must be greater than zero.");
        s_strategies[_strategyName] = RebondingStrategy({
            bondAmount: _bondAmount,
            duration: _duration
        });
        emit StrategySet(_strategyName, _bondAmount, _duration);
    }

    function getRebondingStrategy(string calldata _strategyName) external view returns (uint256 bondAmount, uint256 duration) {
        RebondingStrategy storage strategy = s_strategies[_strategyName];
        return (strategy.bondAmount, strategy.duration);
    }
}