// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDataAnonymizer {
    event DataAnonymized(bytes32 indexed originalDataHash, bytes32 indexed anonymizedDataHash);

    error UnauthorizedAnonymizer(address caller);
    error InvalidData(bytes data);

    function anonymizeData(bytes calldata _data) external returns (bytes32 anonymizedDataHash);
    function isDataAnonymized(bytes32 _originalDataHash) external view returns (bool);
}