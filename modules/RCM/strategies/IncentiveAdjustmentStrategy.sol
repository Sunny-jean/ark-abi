// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface IIncentiveAdjustmentStrategy {
    event IncentiveAdjusted(string indexed incentiveType, uint256 indexed oldValue, uint256 indexed newValue, uint256 timestamp);

    error AdjustmentFailed(string message);

    function adjustIncentive(string calldata _incentiveType, uint256 _newValue) external;
    function getIncentiveValue(string calldata _incentiveType) external view returns (uint256);
}

contract IncentiveAdjustmentStrategy is IIncentiveAdjustmentStrategy, Ownable {
    mapping(string => uint256) private s_incentiveValues;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function adjustIncentive(string calldata _incentiveType, uint256 _newValue) external onlyOwner {
        uint256 oldValue = s_incentiveValues[_incentiveType];
        s_incentiveValues[_incentiveType] = _newValue;
        emit IncentiveAdjusted(_incentiveType, oldValue, _newValue, block.timestamp);
    }

    function getIncentiveValue(string calldata _incentiveType) external view returns (uint256) {
        return s_incentiveValues[_incentiveType];
    }
}