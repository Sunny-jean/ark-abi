// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

// --- interfaces ---
interface ERC20 {
    function safeTransfer(address, uint256) external;
    function safeApprove(address, uint256) external;
    function balanceOf(address) external view returns (uint256);
    function asset() external view returns (address);
}

interface ERC4626 {
    function asset() external view returns (address);
    function redeem(uint256, address, address) external;
    function deposit(uint256, address) external;
    function balanceOf(address) external view returns (uint256);
}

interface IDaiUsds {
    function daiToUsds(address usr, uint256 wad) external;
}

interface IReserveMigrator {
    function migrate() external;
    event MigratedReserves(address from, address to, uint256 amount);
    event Activated();
    event Deactivated();
}

// --- Structs ---
struct Permissions {
    bytes5 keycode;
    bytes4 func;
}

// --- Errors ---
error ReserveMigrator_InvalidParams();
error ReserveMigrator_BadMigration();
error Policy_WrongModuleVersion(bytes expected);
error ROLES_RequireRole(bytes32 role_);

///  Reserve Migrator Policy
contract ReserveMigrator is IReserveMigrator {
    // --- State ---
    address public TRSRY;
    address public ROLES;
    address public immutable sFrom;
    address public immutable sTo;
    address public migrator;
    bool public locallyActive;

    // --- Constructor ---
    constructor(address, address sFrom_, address sTo_, address migrator_) {
        if (sFrom_ == address(0) || sTo_ == address(0) || migrator_ == address(0)) {
            revert ReserveMigrator_InvalidParams();
        }
        sFrom = sFrom_;
        sTo = sTo_;
        migrator = migrator_;
        locallyActive = true;
    }

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

    function requestPermissions() external pure returns (Permissions[] memory permissions) {
        permissions = new Permissions[](2);
        permissions[0] = Permissions("TRSRY", 0x48197c8f); // withdrawReserves
        permissions[1] = Permissions("TRSRY", 0x3f1a2606); // increaseWithdrawApproval
        return permissions;
    }

    // --- Core Functions ---
    function migrate() external override onlyRole("heart") {}

    function VERSION() external pure returns (uint8 major, uint8 minor) {
        return (1, 0);
    }

    // --- Admin Functions ---
    function activate() external onlyRole("reserve_migrator_admin") {
        locallyActive = true;
        emit Activated();
    }
    function deactivate() external onlyRole("reserve_migrator_admin") {
        locallyActive = false;
        emit Deactivated();
    }
    function rescue(address) external onlyRole("reserve_migrator_admin") {}
} 