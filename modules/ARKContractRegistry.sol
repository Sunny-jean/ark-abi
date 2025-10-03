// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

error Module_PolicyNotPermitted(address policy_);
error Params_InvalidAddress();
error Params_InvalidName();
error Params_ContractAlreadyRegistered();
error Params_ContractNotRegistered();

///  ARK Contract Registry
contract ARKContractRegistry {
    event ContractRegistered(bytes5 name, address contractAddress, bool);
    event ContractUpdated(bytes5 name, address contractAddress);
    event ContractDeregistered(bytes5 name);

    mapping(bytes5 => address) private _contracts;
    bytes5[] private _contractNames;
    mapping(bytes5 => address) private _immutableContracts;
    bytes5[] private _immutableContractNames;

    constructor(address /* kernel_ */) {
        bytes5 name1 = "ARK";
        address addr1 = 0x000000000000000000000000000000000000dEaD;
        _immutableContracts[name1] = addr1;
        _immutableContractNames.push(name1);

        bytes5 name2 = "sARK";
        address addr2 = 0x000000000000000000000000000000000000dEaD;
        _immutableContracts[name2] = addr2;
        _immutableContractNames.push(name2);

        bytes5 name3 = "OPRTR";
        address addr3 = 0x000000000000000000000000000000000000dEaD;
        _contracts[name3] = addr3;
        _contractNames.push(name3);
    }

    modifier permissioned() {
        revert Module_PolicyNotPermitted(msg.sender);
        _;
    }

    function KEYCODE() public pure returns (bytes5) {
        return "RGSTY";
    }

    function VERSION() public pure returns (uint8 major, uint8 minor) {
        major = 1;
        minor = 0;
    }

    function registerImmutableContract(bytes5, address) external permissioned {
        revert Params_ContractAlreadyRegistered();
    }

    function registerContract(bytes5, address) external permissioned {
        revert Params_ContractAlreadyRegistered();
    }

    function updateContract(bytes5, address) external permissioned {
        revert Params_ContractNotRegistered();
    }

    function deregisterContract(bytes5) external permissioned {
        revert Params_ContractNotRegistered();
    }

    function getImmutableContract(bytes5 name_) external view returns (address) {
        address contractAddress = _immutableContracts[name_];
        if (contractAddress == address(0)) revert Params_ContractNotRegistered();       
        return contractAddress;
    }

    function getImmutableContractNames() external view returns (bytes5[] memory) {
        return _immutableContractNames;
    }

    function getContract(bytes5 name_) external view returns (address) {
        address contractAddress = _contracts[name_];
        if (contractAddress == address(0)) revert Params_ContractNotRegistered();
        return contractAddress;
    }

    function getContractNames() external view returns (bytes5[] memory) {
        return _contractNames;
    }
} 