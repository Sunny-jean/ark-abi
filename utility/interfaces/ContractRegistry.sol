// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IContractRegistry {
    event ContractRegistered(string indexed contractName, address indexed contractAddress);
    event ContractUpdated(string indexed contractName, address indexed oldAddress, address indexed newAddress);

    error ContractNotFound(string contractName);
    error ContractAlreadyRegistered(string contractName);

    function registerContract(string memory _contractName, address _contractAddress) external;
    function updateContract(string memory _contractName, address _newAddress) external;
    function getContractAddress(string memory _contractName) external view returns (address);
}