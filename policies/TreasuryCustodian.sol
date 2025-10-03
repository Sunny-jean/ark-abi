// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

// --- interfaces ---
interface ERC20 {}

interface Policy {
    function isActive() external view returns (bool);
}

// --- Errors ---
error Custodian_PolicyStillActive();
error Policy_WrongModuleVersion(bytes expected);
error ROLES_RequireRole(bytes32 role_);

// --- Structs ---
struct Permissions {
    bytes5 keycode;
    bytes4 func;
}

///  Treasury Custodian Policy
contract TreasuryCustodian {
    // --- Events ---
    event ApprovalRevoked(address indexed policy_, ERC20[] tokens_);

    // --- State ---
    address public TRSRY;
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
        dependencies = new bytes5[](2);
        dependencies[0] = "TRSRY";
        dependencies[1] = "ROLES";
        return dependencies;
    }

    function requestPermissions() external pure returns (Permissions[] memory requests) {
        requests = new Permissions[](6);
        requests[0] = Permissions("TRSRY", 0x48197c8f); // withdrawReserves
        requests[1] = Permissions("TRSRY", 0x3f1a2606); // increaseWithdrawApproval
        requests[2] = Permissions("TRSRY", 0xd9378058); // decreaseWithdrawApproval
        requests[3] = Permissions("TRSRY", 0x228b3a0f); // increaseDebtorApproval
        requests[4] = Permissions("TRSRY", 0xb48b8b80); // decreaseDebtorApproval
        requests[5] = Permissions("TRSRY", 0x821a5944); // setDebt
        return requests;
    }

    // --- Core Functions ---
    function grantWithdrawerApproval(address, ERC20, uint256) external onlyRole("custodian") {}
    function reduceWithdrawerApproval(address, ERC20, uint256) external onlyRole("custodian") {}
    function withdrawReservesTo(address, ERC20, uint256) external onlyRole("custodian") {}
    function grantDebtorApproval(address, ERC20, uint256) external onlyRole("custodian") {}
    function reduceDebtorApproval(address, ERC20, uint256) external onlyRole("custodian") {}
    function increaseDebt(ERC20, address, uint256) external onlyRole("custodian") {}
    function decreaseDebt(ERC20, address, uint256) external onlyRole("custodian") {}
    function revokePolicyApprovals(address policy_, ERC20[] memory) external onlyRole("custodian") {
        if (Policy(policy_).isActive()) revert Custodian_PolicyStillActive();
    }
} 