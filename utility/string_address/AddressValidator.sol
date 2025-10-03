// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAddressValidator {
    event AddressAddedToWhitelist(address indexed addr);
    event AddressRemovedFromWhitelist(address indexed addr);
    event AddressAddedToBlacklist(address indexed addr);
    event AddressRemovedFromBlacklist(address indexed addr);

    error AddressAlreadyWhitelisted(address addr);
    error AddressNotWhitelisted(address addr);
    error AddressAlreadyBlacklisted(address addr);
    error AddressNotBlacklisted(address addr);

    function addToWhitelist(address _addr) external;
    function removeFromWhitelist(address _addr) external;
    function addToBlacklist(address _addr) external;
    function removeFromBlacklist(address _addr) external;
    function isWhitelisted(address _addr) external view returns (bool);
    function isBlacklisted(address _addr) external view returns (bool);
}