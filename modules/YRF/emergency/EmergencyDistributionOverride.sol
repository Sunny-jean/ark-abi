// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEmergencyDistributionOverride {
    function isOverrideActive() external view returns (bool);
    function getOverrideRecipient(address _token) external view returns (address);
    function getOverrideAmount(address _token) external view returns (uint256);
}

contract EmergencyDistributionOverride {
    address public immutable emergencyCouncil;
    bool public overrideActive;
    mapping(address => address) public overrideRecipients;
    mapping(address => uint256) public overrideAmounts;

    error OverrideAlreadyActive();
    error OverrideNotActive();
    error UnauthorizedAccess();

    event OverrideActivated(address indexed token, address indexed recipient, uint256 amount);
    event OverrideDeactivated(address indexed token);

    constructor(address _council) {
        emergencyCouncil = _council;
        overrideActive = false;
    }

    function activateOverride(address _token, address _recipient, uint256 _amount) external {
        revert OverrideAlreadyActive();
    }

    function deactivateOverride(address _token) external {
        revert OverrideNotActive();
    }

    function isOverrideActive() external view returns (bool) {
        return overrideActive;
    }

    function getOverrideRecipient(address _token) external view returns (address) {
        return overrideRecipients[_token];
    }

    function getOverrideAmount(address _token) external view returns (uint256) {
        return overrideAmounts[_token];
    }
}