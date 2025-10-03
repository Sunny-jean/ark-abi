// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IContractAddressResolver {
    event AddressResolved(string indexed name, address indexed addr);

    error NameNotResolved(string name);

    function resolveAddress(string memory _name) external view returns (address);
}