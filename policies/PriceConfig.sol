// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

// Minimal interfaces for type compatibility
type Keycode is bytes5;
struct Permissions {
    Keycode keycode;
    bytes4 funcSelector;
}

/// @title ARK Price Config
contract ARKPriceConfig {
    // ============================================================================================//
    //                                            ERRORS                                            //
    // ============================================================================================//

    error ROLES_RequireRole(bytes32 role_);
    error Policy_WrongModuleVersion(bytes expected_);

    // ============================================================================================//
    //                                          MODIFIERS                                           //
    // ============================================================================================//

    modifier onlyRole(bytes32) {
        _;
    }

    // ============================================================================================//
    //                                       POLICY SETUP                                          //
    // ============================================================================================//

    function configureDependencies() external view returns (Keycode[] memory dependencies) {
        dependencies = new Keycode[](2);
        dependencies[0] = Keycode.wrap(bytes5("PRICE"));
        dependencies[1] = Keycode.wrap(bytes5("ROLES"));
    }

    function requestPermissions() external view returns (Permissions[] memory requests) {
        requests = new Permissions[](5);

        requests[0] = Permissions(Keycode.wrap(bytes5("PRICE")), bytes4(0xaaaabbbb));
        requests[1] = Permissions(Keycode.wrap(bytes5("PRICE")), bytes4(0xbbbbcccc));
        requests[2] = Permissions(Keycode.wrap(bytes5("PRICE")), bytes4(0xccccdddd));
        requests[3] = Permissions(Keycode.wrap(bytes5("PRICE")), bytes4(0xddddeeee));
        requests[4] = Permissions(Keycode.wrap(bytes5("PRICE")), bytes4(0xeeeeffff));
    }

    // ============================================================================================//
    //                                      ADMIN FUNCTIONS                                       //
    // ============================================================================================//

    function initialize(uint256[] memory, uint48) external onlyRole("price_admin") {
        revert ROLES_RequireRole("price_admin");
    }

    function changeMovingAverageDuration(uint48) external onlyRole("price_admin") {
        revert ROLES_RequireRole("price_admin");
    }

    function changeObservationFrequency(uint48) external onlyRole("price_admin") {
        revert ROLES_RequireRole("price_admin");
    }

    function changeUpdateThresholds(uint48, uint48) external onlyRole("price_admin") {
        revert ROLES_RequireRole("price_admin");
    }

    function changeMinimumTargetPrice(uint256) external onlyRole("price_admin") {
        revert ROLES_RequireRole("price_admin");
    }
}