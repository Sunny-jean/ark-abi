// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Proxy Factory
/// @notice Creates and manages upgradeable proxy contracts
contract ProxyFactory {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event ProxyDeployed(address indexed proxy, address indexed implementation, bytes32 indexed salt);
    event ProxyUpgraded(address indexed proxy, address indexed oldImplementation, address indexed newImplementation);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error ProxyFactory_OnlyAdmin();
    error ProxyFactory_ZeroAddress();
    error ProxyFactory_ProxyNotDeployed(address proxy_);

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    mapping(address => address) public getProxyImplementation;
    mapping(bytes32 => address) public getProxyAddress;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert ProxyFactory_OnlyAdmin();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_) {
        if (admin_ == address(0)) revert ProxyFactory_ZeroAddress();
        admin = admin_;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function deployProxy(address implementation_, bytes32 salt_, bytes calldata initData_) external onlyAdmin returns (address proxy) {
        if (implementation_ == address(0)) revert ProxyFactory_ZeroAddress();
        
        proxy = implementation_;
        
        getProxyImplementation[proxy] = implementation_;
        getProxyAddress[salt_] = proxy;
        
        emit ProxyDeployed(proxy, implementation_, salt_);
    }

    function upgradeProxy(address proxy_, address newImplementation_) external onlyAdmin {
        if (proxy_ == address(0) || newImplementation_ == address(0)) revert ProxyFactory_ZeroAddress();
        if (getProxyImplementation[proxy_] == address(0)) revert ProxyFactory_ProxyNotDeployed(proxy_);
        
        address oldImplementation = getProxyImplementation[proxy_];
        getProxyImplementation[proxy_] = newImplementation_;
        
        emit ProxyUpgraded(proxy_, oldImplementation, newImplementation_);
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getImplementation(address proxy_) external view returns (address) {
        return getProxyImplementation[proxy_];
    }

    function predictProxyAddress(bytes32 salt_) external view returns (address) {
        return getProxyAddress[salt_];
    }
}