// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IMintingResourceAllocator {
    event MintingShareAllocated(address indexed module, uint256 share);

    error InvalidShare(uint256 share);
    error ModuleAlreadyAllocated(address module);
    error ModuleNotAllocated(address module);

    function allocateMintingShare(address _module, uint256 _share) external;
    function updateMintingShare(address _module, uint256 _newShare) external;
    function getMintingShare(address _module) external view returns (uint256);
}

contract MintingResourceAllocator is IMintingResourceAllocator, Ownable {
    mapping(address => uint256) private s_moduleShares;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function allocateMintingShare(address _module, uint256 _share) external onlyOwner {
        require(_share > 0, "InvalidShare");
        if (s_moduleShares[_module] != 0) {
            revert ModuleAlreadyAllocated(_module);
        }
        s_moduleShares[_module] = _share;
        emit MintingShareAllocated(_module, _share);
    }

    function updateMintingShare(address _module, uint256 _newShare) external onlyOwner {
        if (s_moduleShares[_module] == 0) {
            revert ModuleNotAllocated(_module);
        }
        s_moduleShares[_module] = _newShare;
        emit MintingShareAllocated(_module, _newShare);
    }

    function getMintingShare(address _module) external view returns (uint256) {
        return s_moduleShares[_module];
    }
}