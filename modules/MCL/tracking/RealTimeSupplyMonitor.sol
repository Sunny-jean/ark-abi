// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRealTimeSupplyMonitor {
    event RealTimeSupplyUpdated(uint256 newSupply, uint256 timestamp);

    error InvalidSupplySource(address source);

    function getRealTimeSupply() external view returns (uint256);
    function updateRealTimeSupply(uint256 _newSupply) external;
    function setSupplySource(address _source) external;
    function getSupplySource() external view returns (address);
}

contract RealTimeSupplyMonitor is IRealTimeSupplyMonitor, Ownable {
    uint256 private s_realTimeSupply;
    address private s_supplySource;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function getRealTimeSupply() external view returns (uint256) {
        return s_realTimeSupply;
    }

    function updateRealTimeSupply(uint256 _newSupply) external {
        // In a real scenario, this would likely be called by an oracle or a trusted off-chain service
        // For simplicity, we'll allow the owner to update it.
        require(msg.sender == owner() || msg.sender == s_supplySource, "Unauthorized");
        s_realTimeSupply = _newSupply;
        emit RealTimeSupplyUpdated(_newSupply, block.timestamp);
    }

    function setSupplySource(address _source) external onlyOwner {
        require(_source != address(0), "InvalidSupplySource");
        s_supplySource = _source;
    }

    function getSupplySource() external view returns (address) {
        return s_supplySource;
    }
}