// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IHistoricalSupplyLogger {
    struct SupplyRecord {
        uint256 supply;
        uint256 timestamp;
    }

    event SupplyRecorded(uint256 supply, uint256 timestamp);

    error NoRecordsFound();

    function recordSupply(uint256 _supply) external;
    function getSupplyRecord(uint256 _index) external view returns (SupplyRecord memory);
    function getRecordCount() external view returns (uint256);
}

contract HistoricalSupplyLogger is IHistoricalSupplyLogger, Ownable {
    SupplyRecord[] private s_supplyHistory;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function recordSupply(uint256 _supply) external onlyOwner {
        s_supplyHistory.push(SupplyRecord(_supply, block.timestamp));
        emit SupplyRecorded(_supply, block.timestamp);
    }

    function getSupplyRecord(uint256 _index) external view returns (SupplyRecord memory) {
        require(_index < s_supplyHistory.length, "Index out of bounds");
        return s_supplyHistory[_index];
    }

    function getRecordCount() external view returns (uint256) {
        return s_supplyHistory.length;
    }
}