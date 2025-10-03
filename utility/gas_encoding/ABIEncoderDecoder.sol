// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IABIEncoderDecoder {
    event Encoded(bytes indexed dataHash, bytes encodedData);
    event Decoded(bytes indexed dataHash, bytes[] decodedData);

    error EncodingFailed(string message);
    error DecodingFailed(string message);

    function encode(bytes memory _data) external pure returns (bytes memory);
    function decode(bytes memory _encodedData, string[] memory _types) external pure returns (bytes[] memory);
}