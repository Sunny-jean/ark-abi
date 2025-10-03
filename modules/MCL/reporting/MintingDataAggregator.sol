// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IMintingDataAggregator {
    event DataAggregated(uint256 totalMinted, uint256 currentSupply, uint256 timestamp);

    function aggregateData(uint256 _totalMinted, uint256 _currentSupply) external;
    function getTotalMinted() external view returns (uint256);
    function getCurrentSupply() external view returns (uint256);
}

contract MintingDataAggregator is IMintingDataAggregator, Ownable {
    uint256 private s_totalMinted;
    uint256 private s_currentSupply;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function aggregateData(uint256 _totalMinted, uint256 _currentSupply) external onlyOwner {
        s_totalMinted = _totalMinted;
        s_currentSupply = _currentSupply;
        emit DataAggregated(s_totalMinted, s_currentSupply, block.timestamp);
    }

    function getTotalMinted() external view returns (uint256) {
        return s_totalMinted;
    }

    function getCurrentSupply() external view returns (uint256) {
        return s_currentSupply;
    }
}