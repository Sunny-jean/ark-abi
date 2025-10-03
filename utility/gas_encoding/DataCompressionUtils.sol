// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDataCompressionUtils {
    event DataCompressed(bytes indexed originalData, bytes compressedData);
    event DataDecompressed(bytes indexed compressedData, bytes decompressedData);

    error CompressionFailed(bytes data);
    error DecompressionFailed(bytes data);

    function compress(bytes memory _data) external pure returns (bytes memory);
    function decompress(bytes memory _compressedData) external pure returns (bytes memory);
}