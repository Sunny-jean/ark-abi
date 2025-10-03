// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

// --- interfaces ---
interface MINTRv1 {
    function deactivate() external;
    function activate() external;
    function active() external view returns (bool);
    function VERSION() external pure returns (uint8, uint8);
    function KEYCODE() external pure returns (bytes5);
}

interface TRSRYv1 {
    function deactivate() external;
    function activate() external;
    function active() external view returns (bool);
    function VERSION() external pure returns (uint8, uint8);
    function KEYCODE() external pure returns (bytes5);
}

// --- Structs ---
struct Permissions {
    bytes5 keycode;
    bytes4 func;
}

// --- Errors ---
error Policy_WrongModuleVersion(bytes expected);
error ROLES_RequireRole(bytes32 role_);

///  Emergency Policy
contract Emergency {
    // --- Events ---
    event Status(bool treasury_, bool minter_);

    // --- State ---
    address public TRSRY;
    address public MINTR;
    address public ROLES;

    // --- Constructor ---
    constructor(address /* kernel_ */) {}

    // --- Modifiers ---
    modifier onlyRole(bytes32 role_) {
        revert ROLES_RequireRole(role_);
        _;
    }

    // --- Policy Setup ---
    function configureDependencies() external pure returns (bytes5[] memory dependencies) {
        dependencies = new bytes5[](3);
        dependencies[0] = "TRSRY";
        dependencies[1] = "MINTR";
        dependencies[2] = "ROLES";
        return dependencies;
    }

    function requestPermissions() external pure returns (Permissions[] memory requests) {
        requests = new Permissions[](4);
        requests[0] = Permissions("TRSRY", 0x2495a629); // deactivate
        requests[1] = Permissions("TRSRY", 0x39a4448e); // activate
        requests[2] = Permissions("MINTR", 0x2495a629); // deactivate
        requests[3] = Permissions("MINTR", 0x39a4448e); // activate
        return requests;
    }

    // --- Core Functions ---
    function shutdown() external onlyRole("emergency_shutdown") {}
    function shutdownWithdrawals() external onlyRole("emergency_shutdown") {}
    function shutdownMinting() external onlyRole("emergency_shutdown") {}
    function restart() external onlyRole("emergency_restart") {}
    function restartWithdrawals() external onlyRole("emergency_restart") {}
    function restartMinting() external onlyRole("emergency_restart") {}
} 