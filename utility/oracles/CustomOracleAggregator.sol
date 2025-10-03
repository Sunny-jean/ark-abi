// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICustomOracleAggregator {
    event OracleAdded(address indexed oracleAddress, string indexed oracleType);
    event OracleRemoved(address indexed oracleAddress);
    event AggregatedPriceUpdated(string indexed symbol, uint256 aggregatedPrice, uint256 timestamp);

    error UnauthorizedAggregator(address caller);
    error OracleAlreadyExists(address oracleAddress);
    error OracleNotFound(address oracleAddress);

    function addOracle(address _oracleAddress, string memory _oracleType) external;
    function removeOracle(address _oracleAddress) external;
    function getAggregatedPrice(string memory _symbol) external view returns (uint256);
}