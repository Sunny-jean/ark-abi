// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IParameterHistory {
    // 參數歷史記錄
    function getParameterHistory(string calldata _parameterName) external view returns (bytes[] memory values, uint256[] memory timestamps);
    function recordParameterChange(string calldata _parameterName, bytes calldata _newValue) external;

    event ParameterChangeRecorded(string parameterName, bytes newValue, uint256 timestamp);

    error NoHistoryFound();
}