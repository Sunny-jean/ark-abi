// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IConsentManager {
    event ConsentGranted(address indexed user, string indexed dataType);
    event ConsentRevoked(address indexed user, string indexed dataType);

    error UnauthorizedManager(address caller);
    error ConsentAlreadyGranted(address user, string dataType);
    error ConsentNotGranted(address user, string dataType);

    function grantConsent(string memory _dataType) external;
    function revokeConsent(string memory _dataType) external;
    function hasConsent(address _user, string memory _dataType) external view returns (bool);
}