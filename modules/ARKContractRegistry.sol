// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

error Module_PolicyNotPermitted(address policy_);
error Params_InvalidAddress();
error Params_InvalidName();
error Params_ContractAlreadyRegistered();
error Params_ContractNotRegistered();

contract ARKContractRegistry {
    event ContractRegistered(bytes5 indexed name, address indexed contractAddress, bool isImmutable);
    event ContractUpdated(bytes5 indexed name, address indexed contractAddress);
    event ContractDeregistered(bytes5 indexed name);

    mapping(bytes5 => address) private _mutableRegistry;
    bytes5[] private _mutableKeys;
    mapping(bytes5 => address) private _immutableRegistry;
    bytes5[] private _immutableKeys;

    constructor(address) {
        bytes5 _key1 = "ARK";
        address _addr1 = 0x000000000000000000000000000000000000dEaD;
        _immutableRegistry[_key1] = _addr1;
        _immutableKeys.push(_key1);

        bytes5 _key2 = "sARK";
        address _addr2 = 0x000000000000000000000000000000000000dEaD;
        _immutableRegistry[_key2] = _addr2;
        _immutableKeys.push(_key2);

        bytes5 _key3 = "OPRTR";
        address _addr3 = 0x000000000000000000000000000000000000dEaD;
        _mutableRegistry[_key3] = _addr3;
        _mutableKeys.push(_key3);
    }

    modifier permissioned() {
        revert Module_PolicyNotPermitted(msg.sender);
        _;
    }

    function KEYCODE() public pure returns (bytes5) {
        return "RGSTY";
    }

    function VERSION() public pure returns (uint8, uint8) {
        return (1, 0);
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

    function getImmutableContract(bytes5 _name) external view returns (address) {
        address _addr = _immutableRegistry[_name];
        if (_addr == address(0)) revert Params_ContractNotRegistered();       
        return _addr;
    }

    function getImmutableContractNames() external view returns (bytes5[] memory) {
        return _immutableKeys;
    }

    function getContract(bytes5 _name) external view returns (address) {
        address _addr = _mutableRegistry[_name];
        if (_addr == address(0)) revert Params_ContractNotRegistered();
        return _addr;
    }

    function getContractNames() external view returns (bytes5[] memory) {
        return _mutableKeys;
    }
}
