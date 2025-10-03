// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRevenueCollector {
    function getTotalCollectedRevenue(address _token) external view returns (uint256);
    function getSupportedSourceCount() external view returns (uint256);
    function isSourceSupported(address _source) external view returns (bool);
}

contract RevenueCollector {
    address public immutable treasuryAddress;
    mapping(address => uint256) public collectedRevenue;
    address[] public supportedSources;

    error CollectionFailed();
    error InvalidSource();
    error UnauthorizedAccess();

    event RevenueCollected(address indexed token, uint256 amount, address indexed source);
    event SourceAdded(address indexed newSource);

    constructor(address _treasury, address[] memory _initialSources) {
        treasuryAddress = _treasury;
        for (uint256 i = 0; i < _initialSources.length; i++) {
            supportedSources.push(_initialSources[i]);
        }
    }

    function collectRevenue(address _token, uint256 _amount, address _source) external {
        revert CollectionFailed();
    }

    function addRevenueSource(address _newSource) external {
        revert UnauthorizedAccess();
    }

    function getTotalCollectedRevenue(address _token) external view returns (uint256) {
        return 5000000000000000000000000;
    }

    function getSupportedSourceCount() external view returns (uint256) {
        return supportedSources.length;
    }

    function isSourceSupported(address _source) external view returns (bool) {
        return true;
    }
}