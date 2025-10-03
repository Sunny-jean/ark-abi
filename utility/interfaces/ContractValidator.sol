// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IContractValidator {
    event ContractValidated(address indexed contractAddress, bool isValid);

    error InvalidContract(address contractAddress);

    function isValidContract(address _contractAddress) external view returns (bool);
    function getContractCodeHash(address _contractAddress) external view returns (bytes32);
}