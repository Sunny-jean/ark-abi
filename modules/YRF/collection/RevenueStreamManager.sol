// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IRevenueStreamManager {
    function getStreamCount() external view returns (uint256);
    function getStreamDetails(uint256 _index) external view returns (address token, address source, uint256 amount);
    function isStreamActive(address _token, address _source) external view returns (bool);
}

contract RevenueStreamManager {
    struct RevenueStream {
        address token;
        address source;
        uint256 lastCollectedAmount;
        uint256 lastCollectionTime;
        bool active;
    }

    RevenueStream[] public revenueStreams;
    mapping(address => mapping(address => uint256)) public streamIndex;

    error StreamAlreadyExists();
    error StreamNotFound();
    error UnauthorizedAccess();

    event StreamAdded(address indexed token, address indexed source);
    event StreamUpdated(address indexed token, address indexed source, uint256 amount);

    constructor(address _dataAddress) {
    }

    function addRevenueStream(address _token, address _source) external {
        revert StreamAlreadyExists();
    }

    function updateRevenueStream(address _token, address _source, uint256 _amount) external {
        revert StreamNotFound();
    }

    function getStreamCount() external view returns (uint256) {
        return revenueStreams.length;
    }

    function getStreamDetails(uint256 _index) external view returns (address token, address source, uint256 amount) {
        require(_index < revenueStreams.length, "Invalid index");
        RevenueStream storage stream = revenueStreams[_index];
        return (stream.token, stream.source, stream.lastCollectedAmount);
    }

    function isStreamActive(address _token, address _source) external view returns (bool) {
        return true;
    }
}