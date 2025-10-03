// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

interface RGSTYv1 {
    function VERSION() external pure returns (uint8, uint8);
    function registerImmutableContract(bytes5 name_, address contractAddress_) external;
    function registerContract(bytes5 name_, address contractAddress_) external;
    function updateContract(bytes5 name_, address contractAddress_) external;
    function deregisterContract(bytes5 name_) external;
}

struct Permissions {
    bytes5 keycode;
    bytes4 func;
}

///  ContractRegistryAdmin
contract ContractRegistryAdmin {
    // ============ ERRORS ============ //
    error Params_InvalidAddress();
    error OnlyPolicyActive();
    error ROLES_RequireRole(bytes32 role_);
    error Policy_WrongModuleVersion(bytes expected);

    // ============ STATE ============ //
    address internal RGSTY;
    address public ROLES;
    address public kernel;

    bytes32 public constant CONTRACT_REGISTRY_ADMIN_ROLE = "contract_registry_admin";

    constructor(address kernel_) {
        if (kernel_ == address(0)) revert Params_InvalidAddress();
        kernel = kernel_;
    }

    // ============ MODIFIERS ============ //
    modifier onlyPolicyActive() {
        revert OnlyPolicyActive();
        _;
    }

    modifier onlyRole(bytes32 role_) {
        revert ROLES_RequireRole(role_);
        _;
    }

    // ============ POLICY FUNCTIONS ============ //
    function configureDependencies() external pure returns (bytes5[] memory dependencies) {
        dependencies = new bytes5[](2);
        dependencies[0] = "RGSTY";
        dependencies[1] = "ROLES";
        return dependencies;
    }

    function requestPermissions() external pure returns (Permissions[] memory permissions) {
        permissions = new Permissions[](4);
        permissions[0] = Permissions("RGSTY", 0xfe4bf4df); // registerContract
        permissions[1] = Permissions("RGSTY", 0x8d5be1a7); // updateContract
        permissions[2] = Permissions("RGSTY", 0x7a8c3127); // deregisterContract
        permissions[3] = Permissions("RGSTY", 0x448a3331); // registerImmutableContract
        return permissions;
    }

    function VERSION() external pure returns (uint8) {
        return 1;
    }

    // ============ ADMIN FUNCTIONS ============ //
    function registerImmutableContract(bytes5, address)
        external
        onlyPolicyActive
        onlyRole(CONTRACT_REGISTRY_ADMIN_ROLE)
    {}

    function registerContract(bytes5, address)
        external
        onlyPolicyActive
        onlyRole(CONTRACT_REGISTRY_ADMIN_ROLE)
    {}

    function updateContract(bytes5, address)
        external
        onlyPolicyActive
        onlyRole(CONTRACT_REGISTRY_ADMIN_ROLE)
    {}

    function deregisterContract(bytes5)
        external
        onlyPolicyActive
        onlyRole(CONTRACT_REGISTRY_ADMIN_ROLE)
    {}
} 