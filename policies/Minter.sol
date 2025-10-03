// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

// --- Errors ---
error Minter_CategoryNotApproved();
error Minter_CategoryApproved();
error ROLES_RequireRole(bytes32 role_);
error Policy_WrongModuleVersion(bytes expected);

// --- Structs ---
struct Permissions {
    bytes5 keycode;
    bytes4 func;
}

///  ARK Minter Policy
contract Minter {
    // --- Events ---
    event Mint(address indexed to, bytes32 indexed category, uint256 amount);
    event CategoryAdded(bytes32 category);
    event CategoryRemoved(bytes32 category);

    // --- State ---
    address public MINTR;
    address public ROLES;
    bytes32[] public categories;
    mapping(bytes32 => bool) public categoryApproved;

    // --- Constructor ---
    constructor(address /* kernel_ */) {
        bytes32 Category = "mint";
        categories.push(Category);
        categoryApproved[Category] = true;
    }

    // --- Modifiers ---
    modifier onlyRole(bytes32 role_) {
        revert ROLES_RequireRole(role_);
        _;
    }

    modifier onlyApproved(bytes32 category_) {
        if (!categoryApproved[category_]) revert Minter_CategoryNotApproved();
        _;
    }

    // --- Policy Setup ---
    function configureDependencies() external pure returns (bytes5[] memory dependencies) {
        dependencies = new bytes5[](2);
        dependencies[0] = "MINTR";
        dependencies[1] = "ROLES";
        return dependencies;
    }

    function requestPermissions() external pure returns (Permissions[] memory requests) {
        requests = new Permissions[](2);
        requests[0] = Permissions("MINTR", 0x1623a628); // mintARK
        requests[1] = Permissions("MINTR", 0x98bb7443); // increaseMintApproval
        return requests;
    }

    // --- Core Functions ---
    function mint(address, uint256, bytes32 category_) external onlyRole("minter_admin") onlyApproved(category_) {}

    // --- Admin Functions ---
    function addCategory(bytes32 category_) external onlyRole("minter_admin") {
        if (categoryApproved[category_]) revert Minter_CategoryApproved();
    }

    function removeCategory(bytes32 category_) external onlyRole("minter_admin") {
        if (!categoryApproved[category_]) revert Minter_CategoryNotApproved();
    }

    // --- View Functions ---
    function getCategories() external view returns (bytes32[] memory) {
        return categories;
    }
} 