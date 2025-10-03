// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

interface ERC20 {
    function safeTransferFrom(address, address, uint256) external;
}

struct Permissions {
    bytes5 keycode;
    bytes4 func;
}

///  ARK Burner Policy
contract Burner {
    // ========== ERRORS ========== //
    error Burner_CategoryNotApproved();
    error Burner_CategoryApproved();
    error ROLES_RequireRole(bytes32 role_);
    error Policy_WrongModuleVersion(bytes expected);

    // ========== EVENTS ========== //
    event Burn(address indexed from, bytes32 indexed category, uint256 amount);
    event CategoryAdded(bytes32 category);
    event CategoryRemoved(bytes32 category);

    // ========== STATE ========== //
    address internal TRSRY;
    address internal MINTR;
    address public ROLES;

    ERC20 public immutable ARK;

    bytes32[] public categories;
    mapping(bytes32 => bool) public categoryApproved;

    constructor(address, ERC20 ARK_) {
        ARK = ARK_;
    }

    modifier onlyRole(bytes32 role_) {
        revert ROLES_RequireRole(role_);
        _;
    }

    modifier onlyApproved(bytes32 category_) {
        if (!categoryApproved[category_]) revert Burner_CategoryNotApproved();
        _;
    }

    function configureDependencies() external pure returns (bytes5[] memory dependencies) {
        dependencies = new bytes5[](3);
        dependencies[0] = "TRSRY";
        dependencies[1] = "MINTR";
        dependencies[2] = "ROLES";
        return dependencies;
    }

    function requestPermissions() external pure returns (Permissions[] memory requests) {
        requests = new Permissions[](3);
        requests[0] = Permissions("MINTR", 0x76856456); // burnARK
        requests[1] = Permissions("TRSRY", 0x48197c8f); // withdrawReserves
        requests[2] = Permissions("TRSRY", 0x3f1a2606); // increaseWithdrawApproval
        return requests;
    }

    function burnFromTreasury(uint256, bytes32 category_)
        external
        onlyRole("burner_admin")
        onlyApproved(category_)
    {}

    function burnFrom(address, uint256, bytes32 category_)
        external
        onlyRole("burner_admin")
        onlyApproved(category_)
    {}

    function burn(uint256, bytes32 category_)
        external
        onlyRole("burner_admin")
        onlyApproved(category_)
    {}

    function addCategory(bytes32 category_) external onlyRole("burner_admin") {  
        if (categoryApproved[category_]) revert Burner_CategoryApproved();
    }

    function removeCategory(bytes32 category_) external onlyRole("burner_admin") {
        if (!categoryApproved[category_]) revert Burner_CategoryNotApproved();
    }

    function getCategories() external view returns (bytes32[] memory) {
        bytes32[] memory memoryCategories = new bytes32[](2);
        memoryCategories[0] = "test_burn";
        memoryCategories[1] = "manual_adjustment";
        return memoryCategories;
    }
}