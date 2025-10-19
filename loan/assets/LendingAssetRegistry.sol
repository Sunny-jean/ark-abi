// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ILendingAssetRegistry {
    function addSupportedAsset(address _asset) external;
    function removeSupportedAsset(address _asset) external;
    function isSupportedAsset(address _asset) external view returns (bool);

    event AssetAdded(address indexed asset);
    event AssetRemoved(address indexed asset);

    error AssetNotSupported();
}