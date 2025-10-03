// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IAIRegistry {
    function registerModel(address model, string memory name) external;
    function unregisterModel(address model) external;
    function isRegistered(address model) external view returns (bool);
    function getModelName(address model) external view returns (string memory);
}

