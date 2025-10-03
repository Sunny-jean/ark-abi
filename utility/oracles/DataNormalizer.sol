// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDataNormalizer {
    event DataNormalized(string indexed dataType, bytes originalData, bytes normalizedData);

    error NormalizationFailed(string dataType);

    function normalizeData(string memory _dataType, bytes memory _data) external pure returns (bytes memory);
}