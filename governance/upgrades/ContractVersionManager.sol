// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IContractVersionManager {
    function setContractVersion(address _contractAddress, uint256 _version) external;
    function getContractVersion(address _contractAddress) external view returns (uint256);

    event ContractVersionSet(address indexed contractAddress, uint256 version);

    error VersionNotFound();
}