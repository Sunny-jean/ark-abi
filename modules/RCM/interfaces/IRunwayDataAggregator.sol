// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRunwayDataAggregator {
    event DataAggregated(uint256 indexed timestamp, bytes dataHash);

    error AggregationFailed(string message);

    function aggregateData(bytes[] calldata _sourcesData) external returns (bytes32 dataHash);
    function getAggregatedDataHash(uint256 _timestamp) external view returns (bytes32);
}