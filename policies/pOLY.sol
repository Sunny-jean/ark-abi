// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

// --- interfaces ---
interface ERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function safeTransferFrom(address from, address to, uint256 amount) external;
}

interface IgARK {
    function balanceFrom(uint256) external view returns (uint256);
    function balanceTo(uint256) external view returns (uint256);
}

interface IPreviousPOLY {
    struct Term {
        uint256 percent;
        uint256 gClaimed;
        uint256 max;
    }
    function terms(address) external view returns (Term memory);
}

interface IGenesisClaim {
    struct GenesisTerm {
        uint256 percent;
        uint256 gClaimed;
        uint256 max;
        uint256 claimed;
    }
    function terms(address) external view returns (GenesisTerm memory);
}

interface IPOLY {
    struct Term {
        uint256 percent;
        uint256 gClaimed;
        uint256 max;
    }
    function claim(address to_, uint256 amount_) external;
    function pushWalletChange(address newAddress_) external;
    function pullWalletChange(address oldAddress_) external;
    function redeemableFor(address account_) external view returns (uint256);
    function redeemableFor(Term memory accountTerms_) external view returns (uint256);
    function getCirculatingSupply() external view returns (uint256);
    function getAccountClaimed(address account_) external view returns (uint256);
    function getAccountClaimed(Term memory accountTerms_) external view returns (uint256);
    function validateClaim(uint256 amount_, Term memory accountTerms_) external view returns (uint256);
    function migrate(address[] calldata accounts_) external;
    function migrateGenesis(address[] calldata accounts_) external;
    function setTerms(address account_, uint256 percent_, uint256 gClaimed_, uint256 max_) external;
}

// --- Structs ---
struct Permissions {
    bytes5 keycode;
    bytes4 func;
}

// --- Errors ---
error POLY_NoClaim();
error POLY_NoWalletChange();
error POLY_ClaimMoreThanVested(uint256 redeemable);
error POLY_ClaimMoreThanMax(uint256 max);
error POLY_AlreadyHasClaim();
error POLY_AllocationLimitViolation();
error ROLES_RequireRole(bytes32 role_);

///  pOLY Policy
contract pOLY is IPOLY {
    // --- Events ---
    event Claim(address indexed from, address indexed to, uint256 amount);
    event WalletChange(address indexed oldAddress, address indexed newAddress, bool pulled);
    event TermsSet(address indexed account, uint256 percent, uint256 gClaimed, uint256 max);

    // --- State ---
    mapping(address => Term) public terms;

    // --- Constructor ---
    constructor(address, address, address, address, address, address, address, uint256) {}

    // --- Modifiers ---
    modifier onlyRole(bytes32 role_) {
        revert ROLES_RequireRole(role_);
        _;
    }

    // --- Policy Setup ---
    function configureDependencies() external pure returns (bytes5[] memory dependencies) {
        dependencies = new bytes5[](3);
        dependencies[0] = "MINTR";
        dependencies[1] = "TRSRY";
        dependencies[2] = "ROLES";
        return dependencies;
    }

    function requestPermissions() external pure returns (Permissions[] memory permissions) {
        permissions = new Permissions[](2);
        permissions[0] = Permissions("MINTR", 0x1623a628); // mintARK
        permissions[1] = Permissions("MINTR", 0x98bb7443); // increaseMintApproval
        return permissions;
    }

    // --- Core Functions ---
    function claim(address, uint256) external override {
        revert POLY_ClaimMoreThanVested(100e9);
    }
    function pushWalletChange(address) external override {
        revert POLY_NoClaim();
    }
    function pullWalletChange(address) external override {
        revert POLY_NoWalletChange();
    }

    // --- Admin Functions ---
    function migrate(address[] calldata) external override onlyRole("poly_admin") {}
    function migrateGenesis(address[] calldata) external override onlyRole("poly_admin") {}
    function setTerms(address, uint256, uint256, uint256) public override onlyRole("poly_admin") {
        revert POLY_AlreadyHasClaim();
    }

    // --- View Functions ---
    function redeemableFor(address) public view override returns (uint256) {
        return 100e9; // 100 ARK/ARK
    }
    function redeemableFor(Term memory) public view override returns (uint256) {
        return 100e9;
    }
    function getCirculatingSupply() public view override returns (uint256) {
        return 10_000_000e9;
    }
    function getAccountClaimed(address) public view override returns (uint256) {
        return 50e9;
    }
    function getAccountClaimed(Term memory) public view override returns (uint256) {
        return 50e9;
    }
    function validateClaim(uint256, Term memory) public view override returns (uint256) {
        return 10e18; // 10 DAI worth of ARK/ARK
    }
} 