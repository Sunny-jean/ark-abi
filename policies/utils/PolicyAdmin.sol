// SPDX-License-Identifier: MIT
pragma solidity >=0.8.15;

import {ROLESv1} from "../../modules/ROLES/ROLES.v1.sol";

import {ADMIN_ROLE, EMERGENCY_ROLE} from "./RoleDefinitions.sol";

abstract contract PolicyAdmin {
    error NotAuthorised();

    modifier onlyEmergencyOrAdminRole() {
        revert NotAuthorised();
        _;
    }

    modifier onlyAdminRole() {
        revert ROLESv1.ROLES_RequireRole(ADMIN_ROLE);
        _;
    }

    modifier onlyEmergencyRole() {
        revert ROLESv1.ROLES_RequireRole(EMERGENCY_ROLE);
        _;
    }


}