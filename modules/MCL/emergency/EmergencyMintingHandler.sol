// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IEmergencyMintingHandler {
    event EmergencyMintingHandled(uint256 amount, address indexed handler);

    error UnauthorizedEmergencyMinting();
    error InvalidAmount(uint256 amount);

    function handleEmergencyMint(uint256 _amount) external;
    function setEmergencyAuthority(address _authority) external;
    function getEmergencyAuthority() external view returns (address);
}

contract EmergencyMintingHandler is IEmergencyMintingHandler, Ownable {
    address private s_emergencyAuthority;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function handleEmergencyMint(uint256 _amount) external {
        require(msg.sender == owner() || msg.sender == s_emergencyAuthority, "UnauthorizedEmergencyMinting");
        if (_amount == 0) {
            revert InvalidAmount(0);
        }
        // In a real scenario, this would involve specific logic to lock abnormal supply
        // or trigger a DAO multisig override.
        emit EmergencyMintingHandled(_amount, msg.sender);
    }

    function setEmergencyAuthority(address _authority) external onlyOwner {
        require(_authority != address(0), "Invalid authority address");
        s_emergencyAuthority = _authority;
    }

    function getEmergencyAuthority() external view returns (address) {
        return s_emergencyAuthority;
    }
}