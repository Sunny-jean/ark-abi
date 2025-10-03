// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRealTimeDataFetcher {
    event DataFetched(string indexed dataType, bytes data, uint256 timestamp);

    error DataFetchFailed(string dataType);

    function fetchData(string memory _dataType) external returns (bytes memory);
}