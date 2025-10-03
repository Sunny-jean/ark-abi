// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAddressUtils {
    error InvalidAddress(address addr);

    function isValidAddress(address _addr) external pure returns (bool);
    function toChecksumAddress(address _addr) external pure returns (string memory);
    function compareAddresses(address _addr1, address _addr2) external pure returns (bool);
}