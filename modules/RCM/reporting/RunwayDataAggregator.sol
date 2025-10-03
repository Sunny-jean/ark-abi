// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRunwayDataAggregator {
    event DataAggregated(uint256 indexed timestamp, uint256 indexed tvl, uint256 indexed roi, uint256 emissionRate);

    error AggregationFailed(string message);

    function aggregateData(uint256 _tvl, uint256 _roi, uint256 _emissionRate) external;
    function getLastAggregatedData() external view returns (uint256 tvl, uint256 roi, uint256 emissionRate);
}

contract RunwayDataAggregator is IRunwayDataAggregator, Ownable {
    uint256 private s_lastTVL;
    uint256 private s_lastROI;
    uint256 private s_lastEmissionRate;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function aggregateData(uint256 _tvl, uint256 _roi, uint256 _emissionRate) external onlyOwner {
        require(_tvl > 0 && _roi > 0 && _emissionRate > 0, "Input data cannot be zero.");
        s_lastTVL = _tvl;
        s_lastROI = _roi;
        s_lastEmissionRate = _emissionRate;
        emit DataAggregated(block.timestamp, _tvl, _roi, _emissionRate);
    }

    function getLastAggregatedData() external view returns (uint256 tvl, uint256 roi, uint256 emissionRate) {
        return (s_lastTVL, s_lastROI, s_lastEmissionRate);
    }
}