// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface ITreasuryManagementStrategy {
    event TreasuryAction(string indexed actionType, uint256 indexed amount, uint256 timestamp);

    error ActionFailed(string message);

    function executeTreasuryAction(string calldata _actionType, uint256 _amount) external;
    function setTreasuryAddress(address _treasuryAddress) external;
}

contract TreasuryManagementStrategy is ITreasuryManagementStrategy, Ownable {
    address private s_treasuryAddress;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function executeTreasuryAction(string calldata _actionType, uint256 _amount) external onlyOwner {
        require(s_treasuryAddress != address(0), "Treasury address not set.");


        // This would involve interacting with the actual treasury contract.
        bool success = true; // Simulate action success
        if (!success) {
            revert ActionFailed("Failed to execute treasury action.");
        }
        emit TreasuryAction(_actionType, _amount, block.timestamp);
    }

    function setTreasuryAddress(address _treasuryAddress) external onlyOwner {
        s_treasuryAddress = _treasuryAddress;
    }
}