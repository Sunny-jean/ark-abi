// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IMintingDashboardUpdater {
    event DashboardUpdated(uint256 indexed timestamp, string indexed dataType);

    function updateDashboard(string calldata _dataType, bytes calldata _data) external;
    function getLastUpdateTime(string calldata _dataType) external view returns (uint256);
}

contract MintingDashboardUpdater is IMintingDashboardUpdater, Ownable {
    mapping(string => uint256) private s_lastUpdateTimes;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function updateDashboard(string calldata _dataType, bytes calldata _data) external onlyOwner {
        string memory dataTypeMemory = _dataType;
        bytes memory dataMemory = _data;
        // In a real scenario, this would parse _data based on _dataType
        // and update relevant state variables or external systems.
        s_lastUpdateTimes[_dataType] = block.timestamp;
        emit DashboardUpdated(block.timestamp, _dataType);
    }

    function getLastUpdateTime(string calldata _dataType) external view returns (uint256) {
        return s_lastUpdateTimes[_dataType];
    }
}