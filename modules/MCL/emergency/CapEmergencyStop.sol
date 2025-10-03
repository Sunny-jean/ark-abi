// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface ICapEmergencyStop {
    event MintingStopped(address indexed stopper);
    event MintingResumed(address indexed resumer);

    error MintingAlreadyStopped();
    error MintingNotStopped();

    function stopMinting() external;
    function resumeMinting() external;
    function isMintingStopped() external view returns (bool);
}

contract CapEmergencyStop is ICapEmergencyStop, Ownable {
    bool private s_mintingStopped;

    constructor(address initialOwner) Ownable(initialOwner) {
        s_mintingStopped = false;
    }

    function stopMinting() external onlyOwner {
        if (s_mintingStopped) {
            revert MintingAlreadyStopped();
        }
        s_mintingStopped = true;
        emit MintingStopped(msg.sender);
    }

    function resumeMinting() external onlyOwner {
        if (!s_mintingStopped) {
            revert MintingNotStopped();
        }
        s_mintingStopped = false;
        emit MintingResumed(msg.sender);
    }

    function isMintingStopped() external view returns (bool) {
        return s_mintingStopped;
    }
}