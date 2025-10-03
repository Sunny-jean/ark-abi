// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IFundAllocationManager {
    // 資金分配管理
    function allocateFunds(address _to, address _token, uint256 _amount) external;
    function setAllocationStrategy(address _strategy) external;
    function getAllocationStrategy() external view returns (address);

    event FundsAllocated(address indexed to, address indexed token, uint256 amount);
    event AllocationStrategySet(address indexed strategy);

    error AllocationFailed();
}