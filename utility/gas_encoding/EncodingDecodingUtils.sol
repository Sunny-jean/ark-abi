// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEncodingDecodingUtils {
    event Encoded(bytes indexed originalData, bytes encodedData);
    event Decoded(bytes indexed encodedData, bytes decodedData);

    error EncodingFailed(bytes data);
    error DecodingFailed(bytes data);

    function encode(bytes memory _data) external pure returns (bytes memory);
    function decode(bytes memory _encodedData) external pure returns (bytes memory);
}