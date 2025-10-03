// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IEpochROITracker {
    event EpochROIUpdated(uint256 indexed epoch, uint256 indexed roi, uint256 timestamp);

    error InvalidEpoch(uint256 epoch);

    function updateEpochROI(uint256 _epoch, uint256 _roi) external;
    function getEpochROI(uint256 _epoch) external view returns (uint256);
    function getTotalEpochs() external view returns (uint256);
}

contract EpochROITracker is IEpochROITracker, Ownable {
    mapping(uint256 => uint256) private s_epochROIs;
    uint256 private s_totalEpochs;

    constructor(address initialOwner) Ownable(initialOwner) {
        s_totalEpochs = 0;
    }

    function updateEpochROI(uint256 _epoch, uint256 _roi) external onlyOwner {
        s_epochROIs[_epoch] = _roi;
        if (_epoch > s_totalEpochs) {
            s_totalEpochs = _epoch;
        }
        emit EpochROIUpdated(_epoch, _roi, block.timestamp);
    }

    function getEpochROI(uint256 _epoch) external view returns (uint256) {
        require(_epoch > 0 && _epoch <= s_totalEpochs, "InvalidEpoch");
        return s_epochROIs[_epoch];
    }

    function getTotalEpochs() external view returns (uint256) {
        return s_totalEpochs;
    }
}