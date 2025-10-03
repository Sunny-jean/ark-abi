// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRunwayTrendAnalyzer {
    event TrendAnalyzed(string indexed trend, string message);

    error AnalysisFailed(string message);

    function analyzeTrend(uint256[] calldata _historicalRunways) external;
    function getCurrentTrend() external view returns (string memory);
}

contract RunwayTrendAnalyzer is IRunwayTrendAnalyzer, Ownable {
    string private s_currentTrend;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function analyzeTrend(uint256[] calldata _historicalRunways) external onlyOwner {
        if (_historicalRunways.length < 2) {
            revert AnalysisFailed("Not enough data to analyze trend.");
        }


        // This would compare recent runway data points to determine a trend.
        string memory trend = "Stable";
        if (_historicalRunways[_historicalRunways.length - 1] > _historicalRunways[_historicalRunways.length - 2]) {
            trend = "Increasing";
        } else if (_historicalRunways[_historicalRunways.length - 1] < _historicalRunways[_historicalRunways.length - 2]) {
            trend = "Decreasing";
        }
        s_currentTrend = trend;
        emit TrendAnalyzed(trend, "Runway trend analysis completed.");
    }

    function getCurrentTrend() external view returns (string memory) {
        return s_currentTrend;
    }
}