// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IProxyUpgradeManager {
    // 代理合約升級
    function upgradeProxy(address _proxyAddress, address _newImplementation) external;
    function setUpgradeabilityStatus(address _proxyAddress, bool _upgradable) external;
    function getUpgradeabilityStatus(address _proxyAddress) external view returns (bool);

    event ProxyUpgraded(address indexed proxyAddress, address indexed newImplementation);
    event UpgradeabilityStatusSet(address indexed proxyAddress, bool upgradable);

    error UpgradeFailed();
}