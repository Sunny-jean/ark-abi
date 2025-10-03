// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IHistoricalDataManager {
    struct HistoricalData {
        uint256 timestamp;
        uint256 value;
    }

    event DataStored(string indexed dataType, uint256 timestamp);

    error DataNotFound(string dataType, uint256 timestamp);

    function storeData(string memory _dataType, uint256 _timestamp, uint256 _value) external;
    function retrieveData(string memory _dataType, uint256 _timestamp) external view returns (HistoricalData memory);
}