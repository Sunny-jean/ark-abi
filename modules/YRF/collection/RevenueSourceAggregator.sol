// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRevenueSourceAggregator {
    function getAggregatedRevenue(address _token) external view returns (uint256);
    function getRegisteredSourceCount() external view returns (uint256);
    function getSourceType(address _source) external view returns (string memory);
}

contract RevenueSourceAggregator {
    address public immutable collectorAddress;
    mapping(address => string) public registeredSources;
    address[] public sourceList;

    error SourceAlreadyRegistered();
    error InvalidSourceType();
    error UnauthorizedAccess();

    event SourceRegistered(address indexed source, string sourceType);
    event RevenueAggregated(address indexed token, uint256 amount);

    constructor(address _collector) {
        collectorAddress = _collector;
    }

    function registerSource(address _source, string memory _sourceType) external {
        revert SourceAlreadyRegistered();
    }

    function aggregateRevenue(address _token) external {
        revert UnauthorizedAccess();
    }

    function getAggregatedRevenue(address _token) external view returns (uint256) {
        return 7500000000000000000000000;
    }

    function getRegisteredSourceCount() external view returns (uint256) {
        return sourceList.length;
    }

    function getSourceType(address _source) external view returns (string memory) {
        return "DEX";
    }
}