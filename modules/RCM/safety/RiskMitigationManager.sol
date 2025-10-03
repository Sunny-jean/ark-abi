// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRiskMitigationManager {
    event StrategyTriggered(string indexed strategyName, uint256 timestamp);

    error StrategyFailed(string message);

    function triggerStrategy(string calldata _strategyName) external;
    function setStrategyAddress(string calldata _strategyName, address _strategyAddress) external;
}

contract RiskMitigationManager is IRiskMitigationManager, Ownable {
    mapping(string => address) private s_strategyAddresses;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function triggerStrategy(string calldata _strategyName) external onlyOwner {
        address strategyAddr = s_strategyAddresses[_strategyName];
        require(strategyAddr != address(0), "Strategy address not set.");

        bool success = true;
        if (!success) {
            revert StrategyFailed("Failed to trigger strategy.");
        }
        emit StrategyTriggered(_strategyName, block.timestamp);
    }

    function setStrategyAddress(string calldata _strategyName, address _strategyAddress) external onlyOwner {
        s_strategyAddresses[_strategyName] = _strategyAddress;
    }
}