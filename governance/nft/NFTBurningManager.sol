// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface INFTBurningManager {
    function burnNFT(uint256 _tokenId) external;
    function setBurningEnabled(bool _enabled) external;
    function isBurningEnabled() external view returns (bool);

    event NFTBurned(uint256 indexed tokenId);
    event BurningStatusChanged(bool enabled);

    error BurningDisabled();
}

contract NFTBurningManager is INFTBurningManager, Ownable {
    bool private s_burningEnabled;

    constructor(address initialOwner) Ownable(initialOwner) {
        s_burningEnabled = true; // Burning enabled by default
    }

    function burnNFT(uint256 _tokenId) external {
        require(s_burningEnabled, "BurningDisabled");
        // Placeholder for actual NFT burning logic
        emit NFTBurned(_tokenId);
    }

    function setBurningEnabled(bool _enabled) external onlyOwner {
        s_burningEnabled = _enabled;
        emit BurningStatusChanged(_enabled);
    }

    function isBurningEnabled() external view returns (bool) {
        return s_burningEnabled;
    }
}