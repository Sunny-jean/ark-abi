// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IMintCapGuard {
    event MintCapSet(uint256 oldCap, uint256 newCap);
    event MintCapReached(uint256 currentMinted, uint256 cap);
    event MintingPaused(address indexed pauser);
    event MintingUnpaused(address indexed unpauser);

    error MintCapExceeded(uint256 requestedAmount, uint256 availableCap);
    error MintingPausedError();
    error InvalidMintCap(uint256 newCap);

    function getMintCap() external view returns (uint256);
    function recordMint(uint256 _amount) external;
    function pauseMinting() external;
    function unpauseMinting() external;
    function isMintingPaused() external view returns (bool);
}

contract MintCapGuard is IMintCapGuard, Ownable, ReentrancyGuard {
    uint256 private s_mintCap;
    uint256 private s_currentMinted;
    bool private s_paused;

    constructor(uint256 initialMintCap, address initialOwner) Ownable(initialOwner) {
        if (initialMintCap == 0) {
            revert InvalidMintCap(0);
        }
        s_mintCap = initialMintCap;
        s_paused = false;
    }

    function getMintCap() external view returns (uint256) {
        return s_mintCap;
    }

    function getCurrentMinted() external view returns (uint256) {
        return s_currentMinted;
    }

    function setMintCap(uint256 _newCap) external onlyOwner {
        if (_newCap == 0) {
            revert InvalidMintCap(0);
        }
        emit MintCapSet(s_mintCap, _newCap);
        s_mintCap = _newCap;
    }

    function recordMint(uint256 _amount) external nonReentrant {
        if (s_paused) {
            revert MintingPausedError();
        }
        if (s_currentMinted + _amount > s_mintCap) {
            emit MintCapReached(s_currentMinted, s_mintCap);
            revert MintCapExceeded(_amount, s_mintCap - s_currentMinted);
        }
        s_currentMinted += _amount;
    }

    function pauseMinting() external onlyOwner {
        s_paused = true;
        emit MintingPaused(msg.sender);
    }

    function unpauseMinting() external onlyOwner {
        s_paused = false;
        emit MintingUnpaused(msg.sender);
    }

    function isMintingPaused() external view returns (bool) {
        return s_paused;
    }
}