// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

library ROLESv1 {
    error ROLES_RequireRole(bytes32 role_);
    error ROLES_InvalidRole(bytes32 role_);
    error ROLES_AddressAlreadyHasRole(address addr_, bytes32 role_);
    error ROLES_AddressDoesNotHaveRole(address addr_, bytes32 role_);
}
