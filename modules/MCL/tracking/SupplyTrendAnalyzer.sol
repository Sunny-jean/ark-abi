// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface ISupplyTrendAnalyzer {
    event TrendAnalyzed(uint256 currentSupply, int256 trendValue);

    error InsufficientData();

    function analyzeSupplyTrend(uint256[] calldata _historicalSupplies) external returns (int256);
    function setHistoricalDataSource(address _source) external;
    function getHistoricalDataSource() external view returns (address);
}

contract SupplyTrendAnalyzer is ISupplyTrendAnalyzer, Ownable {
    address private s_historicalDataSource;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function analyzeSupplyTrend(uint256[] calldata _historicalSupplies) external returns (int256) {
        uint256[] memory historicalSupplies = new uint256[](_historicalSupplies.length);
        for (uint256 i = 0; i < _historicalSupplies.length; i++) {
            historicalSupplies[i] = _historicalSupplies[i];
        }
        require(_historicalSupplies.length >= 2, "InsufficientData");

        // Simple trend analysis: difference between last and first supply
        uint256 firstSupply = historicalSupplies[0];
        uint256 lastSupply = historicalSupplies[historicalSupplies.length - 1];

        int256 trend = int256(lastSupply) - int256(firstSupply);

        emit TrendAnalyzed(lastSupply, trend);
        return trend;
    }

    function setHistoricalDataSource(address _source) external onlyOwner {
        require(_source != address(0), "Invalid data source address");
        s_historicalDataSource = _source;
    }

    function getHistoricalDataSource() external view returns (address) {
        return s_historicalDataSource;
    }
}