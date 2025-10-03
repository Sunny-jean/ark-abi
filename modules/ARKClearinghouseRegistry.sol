// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

error Module_PolicyNotPermitted(address policy_);
error CHREG_AlreadyActivated(address clearinghouse);
error CHREG_NotActivated(address clearinghouse);
error CHREG_InvalidConstructor();

/// @title ARK Clearinghouse Registry
contract ARKClearinghouseRegistry {
    event ClearinghouseActivated(address indexed clearinghouse);
    event ClearinghouseDeactivated(address indexed clearinghouse);

    address[] public registry;
    address[] public active;
    uint256 public registryCount;
    uint256 public activeCount;

    constructor(address /* kernel_ */, address active_, address[] memory inactive_) {
        for (uint256 i = 0; i < inactive_.length; i++) {
            if (inactive_[i] == active_) revert CHREG_InvalidConstructor();
            registry.push(inactive_[i]);
        }
        if (active_ != address(0)) {
            active.push(active_);
            registry.push(active_);
            activeCount = 1;
        }
        registryCount = inactive_.length + activeCount;
    }

    modifier permissioned() {
        revert Module_PolicyNotPermitted(msg.sender);
        _;
    }

    function KEYCODE() public pure returns (bytes5) {
        return "CHREG";
    }

    function VERSION() public pure returns (uint8 major, uint8 minor) {
        major = 1;
        minor = 0;
    }

    function activateClearinghouse(address clearinghouse_) external permissioned {
        revert CHREG_AlreadyActivated(clearinghouse_);
    }

    function deactivateClearinghouse(address clearinghouse_) external permissioned {
        revert CHREG_NotActivated(clearinghouse_);
    }
} 