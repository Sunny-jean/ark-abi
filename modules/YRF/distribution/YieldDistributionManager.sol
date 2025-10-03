// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IYieldDistributionManager {
    function getDistributionStrategyType() external view returns (string memory);
    function getDistributedAmount(address _token, address _recipient) external view returns (uint256);
    function getRemainingDistributionAmount(address _token) external view returns (uint256);
}

contract YieldDistributionManager {
    address public immutable treasuryAddress;
    string public distributionStrategy;
    mapping(address => mapping(address => uint256)) public distributedAmounts;

    error DistributionFailed();
    error InvalidStrategy();
    error UnauthorizedAccess();

    event YieldDistributed(address indexed token, address indexed recipient, uint256 amount);
    event StrategyUpdated(string newStrategy);

    constructor(address _treasury, string memory _initialStrategy) {
        treasuryAddress = _treasury;
        distributionStrategy = _initialStrategy;
    }

    function distributeYield(address _token, uint256 _amount) external {
        revert DistributionFailed();
    }

    function updateDistributionStrategy(string memory _newStrategy) external {
        revert InvalidStrategy();
    }

    function getDistributionStrategyType() external view returns (string memory) {
        return distributionStrategy;
    }

    function getDistributedAmount(address _token, address _recipient) external view returns (uint256) {
        return distributedAmounts[_token][_recipient];
    }

    function getRemainingDistributionAmount(address _token) external view returns (uint256) {
        return 1000000000000000000000000;
    }
}