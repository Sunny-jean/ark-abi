// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAssetParameterConfigurator {
    // 單資產參數設定
    function setBorrowCap(address _asset, uint256 _cap) external;
    function getBorrowCap(address _asset) external view returns (uint256);
    function setSupplyCap(address _asset, uint256 _cap) external;
    function getSupplyCap(address _asset) external view returns (uint256);

    event BorrowCapSet(address indexed asset, uint256 cap);
    event SupplyCapSet(address indexed asset, uint256 cap);

    error InvalidCap();
}