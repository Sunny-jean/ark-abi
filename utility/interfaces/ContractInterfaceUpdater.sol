// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IContractinterfaceUpdater {
    event interfaceUpdated(address indexed contractAddress, bytes4 indexed interfaceId);

    error interfaceUpdateFailed(address contractAddress, bytes4 interfaceId);

    function updateinterface(address _contractAddress, bytes4 _interfaceId) external;
}