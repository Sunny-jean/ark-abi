// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IMintingPerformanceReporter {
    event PerformanceReported(uint256 indexed mintingVolume, int256 indexed marketImpact, string analysis);

    function reportPerformance(uint256 _mintingVolume, int256 _marketImpact, string calldata _analysis) external;
    function getLastMintingVolume() external view returns (uint256);
    function getLastMarketImpact() external view returns (int256);
}

contract MintingPerformanceReporter is IMintingPerformanceReporter, Ownable {
    uint256 private s_lastMintingVolume;
    int256 private s_lastMarketImpact;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function reportPerformance(uint256 _mintingVolume, int256 _marketImpact, string calldata _analysis) external onlyOwner {
        string memory analysisMemory = _analysis;
        s_lastMintingVolume = _mintingVolume;
        s_lastMarketImpact = _marketImpact;
        emit PerformanceReported(_mintingVolume, _marketImpact, _analysis);
    }

    function getLastMintingVolume() external view returns (uint256) {
        return s_lastMintingVolume;
    }

    function getLastMarketImpact() external view returns (int256) {
        return s_lastMarketImpact;
    }
}