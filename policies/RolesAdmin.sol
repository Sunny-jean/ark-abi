// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

// --- interfaces ---
interface ROLESv1 {
    function saveRole(bytes32 role_, address wallet_) external;
    function removeRole(bytes32 role_, address wallet_) external;
    function VERSION() external pure returns (uint8, uint8);
}

// --- Structs ---
struct Permissions {
    bytes5 keycode;
    bytes4 func;
}

// --- Errors ---
error Roles_OnlyAdmin();
error Roles_OnlyNewAdmin();
error Policy_WrongModuleVersion(bytes expected);

///  RolesAdmin Policy
contract RolesAdmin {
    // --- Events ---
    event NewAdminPushed(address indexed newAdmin_);
    event NewAdminPulled(address indexed newAdmin_);

    // --- State ---
    address public admin;
    address public newAdmin;
    address public ROLES;

    // --- Constructor ---
    constructor(address /* _kernel */) {
        admin = msg.sender;
    }

    // --- Modifiers ---
    modifier onlyAdmin() {
        if (msg.sender != admin) revert Roles_OnlyAdmin();
        _;
    }

    // --- Policy Setup ---
    function configureDependencies() external pure returns (bytes5[] memory dependencies) {
        dependencies = new bytes5[](1);
        dependencies[0] = "ROLES";
        return dependencies;
    }

    function requestPermissions() external pure returns (Permissions[] memory requests) {
        requests = new Permissions[](2);
        requests[0] = Permissions("ROLES", 0x61a84f37); // saveRole
        requests[1] = Permissions("ROLES", 0x5a1d7870); // removeRole
        return requests;
    }

    // --- Core Functions ---
    function grantRole(bytes32, address) external onlyAdmin {}
    function revokeRole(bytes32, address) external onlyAdmin {}

    // --- Admin Functions ---
    function pushNewAdmin(address newAdmin_) external onlyAdmin {
        newAdmin = newAdmin_;
        emit NewAdminPushed(newAdmin_);
    }

    function pullNewAdmin() external {
        if (msg.sender != newAdmin || newAdmin == address(0)) revert Roles_OnlyNewAdmin();
        admin = newAdmin;
        newAdmin = address(0);
        emit NewAdminPulled(admin);
    }
} 