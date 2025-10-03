// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRunwayResourceAllocator {
    event ResourceAllocated(string indexed resourceType, uint256 indexed amount, uint256 timestamp);

    error AllocationFailed(string message);

    function allocateResource(string calldata _resourceType, uint256 _amount) external;
    function setAllocationPriority(string calldata _resourceType, uint256 _priority) external;
    function getAllocationPriority(string calldata _resourceType) external view returns (uint256);
}

contract RunwayResourceAllocator is IRunwayResourceAllocator, Ownable {
    mapping(string => uint256) private s_allocationPriorities;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function allocateResource(string calldata _resourceType, uint256 _amount) external onlyOwner {
        bool success = true;
        if (!success) {
            revert AllocationFailed("Failed to allocate resource.");
        }
        emit ResourceAllocated(_resourceType, _amount, block.timestamp);
    }

    function setAllocationPriority(string calldata _resourceType, uint256 _priority) external onlyOwner {
        s_allocationPriorities[_resourceType] = _priority;
    }

    function getAllocationPriority(string calldata _resourceType) external view returns (uint256) {
        return s_allocationPriorities[_resourceType];
    }
}