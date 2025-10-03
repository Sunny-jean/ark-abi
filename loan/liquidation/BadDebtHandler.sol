// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IBadDebtHandler {
    // 壞帳管理
    function handleBadDebt(address _user, address _asset, uint256 _amount) external;
    function getBadDebtAmount(address _user, address _asset) external view returns (uint256);
    function setBadDebtThreshold(uint256 _threshold) external;

    event BadDebtHandled(address indexed user, address indexed asset, uint256 amount);
    event BadDebtThresholdSet(uint256 threshold);

    error NoBadDebtToHandle();
}