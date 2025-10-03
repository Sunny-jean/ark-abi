// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Registry
/// @notice Manages contract registrations and dependencies
contract Registry {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event ContractRegistered(bytes32 indexed id, address indexed implementation);
    event ContractUpgraded(bytes32 indexed id, address indexed oldImplementation, address indexed newImplementation);
    event DependencyRegistered(bytes32 indexed id, bytes32 indexed dependency);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error Registry_OnlyAdmin();
    error Registry_ContractAlreadyRegistered(bytes32 id_);
    error Registry_ContractNotRegistered(bytes32 id_);
    error Registry_ZeroAddress();

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    mapping(bytes32 => address) public getContractAddress;
    mapping(bytes32 => bytes32[]) public getDependencies;
    mapping(address => bytes32) public getContractID;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert Registry_OnlyAdmin();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_) {
        if (admin_ == address(0)) revert Registry_ZeroAddress();
        admin = admin_;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function registerContract(bytes32 id_, address implementation_) external onlyAdmin {
        if (getContractAddress[id_] != address(0)) revert Registry_ContractAlreadyRegistered(id_);
        if (implementation_ == address(0)) revert Registry_ZeroAddress();
        
        getContractAddress[id_] = implementation_;
        getContractID[implementation_] = id_;
        
        emit ContractRegistered(id_, implementation_);
    }

    function upgradeContract(bytes32 id_, address newImplementation_) external onlyAdmin {
        address oldImplementation = getContractAddress[id_];
        if (oldImplementation == address(0)) revert Registry_ContractNotRegistered(id_);
        if (newImplementation_ == address(0)) revert Registry_ZeroAddress();
        
        getContractAddress[id_] = newImplementation_;
        getContractID[newImplementation_] = id_;
        delete getContractID[oldImplementation];
        
        emit ContractUpgraded(id_, oldImplementation, newImplementation_);
    }

    function registerDependency(bytes32 id_, bytes32 dependencyId_) external onlyAdmin {
        if (getContractAddress[id_] == address(0)) revert Registry_ContractNotRegistered(id_);
        if (getContractAddress[dependencyId_] == address(0)) revert Registry_ContractNotRegistered(dependencyId_);
        
        getDependencies[id_].push(dependencyId_);
        
        emit DependencyRegistered(id_, dependencyId_);
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getImplementation(bytes32 id_) external view returns (address) {
        return getContractAddress[id_];
    }

    function getAllDependencies(bytes32 id_) external view returns (bytes32[] memory) {
        return getDependencies[id_];
    }
}