// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface ISupplyTracker {
    event SupplyUpdated(uint256 newSupply);

    error InvalidSupplyValue(uint256 value);

    function getCurrentSupply() external view returns (uint256);
    function updateSupply(uint256 _newSupply) external;
}

contract SupplyTracker is ISupplyTracker, Ownable {
    uint256 private s_currentSupply;

    constructor(address initialOwner, uint256 initialSupply) Ownable(initialOwner) {
        s_currentSupply = initialSupply;
    }

    function getCurrentSupply() external view returns (uint256) {
        return s_currentSupply;
    }

    function updateSupply(uint256 _newSupply) external onlyOwner {
        if (_newSupply == 0) {
            revert InvalidSupplyValue(0);
        }
        s_currentSupply = _newSupply;
        emit SupplyUpdated(_newSupply);
    }
}