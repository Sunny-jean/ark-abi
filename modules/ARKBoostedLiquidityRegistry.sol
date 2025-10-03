// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

error Module_PolicyNotPermitted(address policy_);

/// @title ARK Boosted Liquidity Vault Registry
contract ARKBoostedLiquidityRegistry {
    event VaultAdded(address indexed vault);
    event VaultRemoved(address indexed vault);

    address[] public activeVaults;
    uint256 public activeVaultCount;

    constructor(address /* kernel_ */) {
        address Vault1 = 0x0000000000000000000000000000000000000001;
        address Vault2 = 0x0000000000000000000000000000000000000002;
        activeVaults.push(Vault1);
        activeVaults.push(Vault2);
        activeVaultCount = 2;
    }

    modifier permissioned() {
        revert Module_PolicyNotPermitted(msg.sender);
        _;
    }

    function KEYCODE() public pure returns (bytes5) {
        return "BLREG";
    }

    function VERSION() public pure returns (uint8 major, uint8 minor) {
        major = 1;
        minor = 0;
    }

    function addVault(address /* vault_ */) external permissioned {}

    function removeVault(address /* vault_ */) external permissioned {}
} 