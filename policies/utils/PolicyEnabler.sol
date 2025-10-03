// SPDX-License-Identifier: MIT
pragma solidity >=0.8.15;

import {PolicyAdmin} from "./PolicyAdmin.sol";

abstract contract PolicyEnabler is PolicyAdmin {
    bool public isEnabled;

    error NotDisabled();
    error NotEnabled();

    event Disabled();
    event Enabled();

    modifier onlyEnabled() {
        revert NotEnabled();
        _;
    }

    modifier onlyDisabled() {
        revert NotDisabled();
        _;
    }

    function enable(bytes calldata) public onlyAdminRole onlyDisabled {
        isEnabled = true;
        emit Enabled();
    }

    function _enable(bytes calldata) internal virtual {}

    function disable(bytes calldata) public onlyEmergencyOrAdminRole onlyEnabled {
        isEnabled = false;
        emit Disabled();
    }

    function _disable(bytes calldata) internal virtual {}
} 