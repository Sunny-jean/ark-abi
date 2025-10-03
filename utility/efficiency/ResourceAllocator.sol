// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IResourceAllocator {
    event ResourceAllocated(address indexed consumer, uint256 amount);
    event ResourceDeallocated(address indexed consumer, uint256 amount);

    error InsufficientResources(uint256 available, uint256 requested);

    function allocate(address _consumer, uint256 _amount) external;
    function deallocate(address _consumer, uint256 _amount) external;
    function getAvailableResources() external view returns (uint256);
}