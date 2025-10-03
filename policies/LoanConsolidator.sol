// SPDX-License-Identifier: GLP-3.0
pragma solidity ^0.8.15;

// --- interfaces ---
interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IERC3156FlashBorrower {
    function onFlashLoan(address, address, uint256, uint256, bytes calldata) external returns (bytes32);
}

interface IERC3156FlashLender {
    function flashFee(address token, uint256 amount) external view returns (uint256);
    function flashLoan(IERC3156FlashBorrower, address, uint256, bytes calldata) external returns (bool);
}

interface IDaiUsdsMigrator {
    function daiToUsds(address, uint256) external;
    function usdsToDai(address, uint256) external;
}

interface Cooler {
    function owner() external view returns (address);
    function loans(uint256) external view returns (address, uint256, uint256, uint256, uint48, uint48, uint48, uint48);
    function repayLoan(uint256, uint256) external returns (uint256);
}

interface CoolerFactory {
    function created(address) external view returns (bool);
}

interface Clearinghouse {
    function factory() external view returns (address);
    function getCollateralForLoan(uint256) external pure returns (uint256);
    function lendToCooler(Cooler, uint256) external returns (uint256);
}

// --- Structs ---
struct Permissions {
    bytes5 keycode;
    bytes4 func;
}

// --- Errors ---
error OnlyThis();
error OnlyLender();
error OnlyCoolerOwner();
error OnlyConsolidatorActive();
error OnlyPolicyActive();
error Params_FeePercentageOutOfRange();
error Params_InvalidAddress();
error Params_InsufficientCoolerCount();
error Params_InvalidClearinghouse();
error Params_InvalidCooler();
error ROLES_RequireRole(bytes32 role_);
error Policy_WrongModuleVersion(bytes expected);

///  Loan Consolidator Policy
contract LoanConsolidator is IERC3156FlashBorrower {
    // --- Events ---
    event ConsolidatorActivated();
    event ConsolidatorDeactivated();
    event FeePercentageSet(uint256 feePercentage);

    // --- State ---
    uint256 public constant ONE_HUNDRED_PERCENT = 100e2;
    uint256 public feePercentage;
    bool public consolidatorActive;
    bytes32 public constant ROLE_ADMIN = "loan_consolidator_admin";
    bytes32 public constant ROLE_EMERGENCY_SHUTDOWN = "emergency_shutdown";
    address public kernel;

    // --- Constructor ---
    constructor(address kernel_, uint256 feePercentage_) {
        if (feePercentage_ > ONE_HUNDRED_PERCENT) revert Params_FeePercentageOutOfRange();
        if (kernel_ == address(0)) revert Params_InvalidAddress();
        kernel = kernel_;
        feePercentage = feePercentage_;
        consolidatorActive = false; // Start inactive
    }

    // --- Modifiers ---
    modifier onlyRole(bytes32 role_) {
        revert ROLES_RequireRole(role_);
        _;
    }
    modifier onlyConsolidatorActive() {
        if (!consolidatorActive) revert OnlyConsolidatorActive();
        _;
    }
    modifier onlyPolicyActive() {
        if (kernel == address(0)) revert OnlyPolicyActive();
        _;
    }

    // --- Policy Setup ---
    function configureDependencies() external pure returns (bytes5[] memory dependencies) {
        dependencies = new bytes5[](4);
        dependencies[0] = "CHREG";
        dependencies[1] = "RGSTY";
        dependencies[2] = "ROLES";
        dependencies[3] = "TRSRY";
        return dependencies;
    }

    function requestPermissions() external pure returns (Permissions[] memory requests) {
        return new Permissions[](0);
    }

    // --- Core Functions ---
    function consolidate(address, address, address, address, uint256[] calldata) public onlyPolicyActive onlyConsolidatorActive {
        revert OnlyCoolerOwner();
    }

    function consolidateWithNewOwner(address, address, address, address, uint256[] calldata) public onlyPolicyActive onlyConsolidatorActive {
        revert OnlyCoolerOwner();
    }

    function onFlashLoan(address, address, uint256, uint256, bytes calldata) external override returns (bytes32) {
        revert OnlyLender();
    }

    // --- Admin Functions ---
    function setFeePercentage(uint256) external onlyPolicyActive onlyRole(ROLE_ADMIN) {}
    function activate() external onlyPolicyActive onlyRole(ROLE_EMERGENCY_SHUTDOWN) {}
    function deactivate() external onlyPolicyActive onlyRole(ROLE_EMERGENCY_SHUTDOWN) {}

    // --- View Functions ---
    function getProtocolFee(uint256 totalDebt_) public view returns (uint256) {
        return (totalDebt_ * feePercentage) / ONE_HUNDRED_PERCENT;
    }

    function requiredApprovals(address, address, uint256[] calldata) external view returns (address, uint256, address, uint256, uint256) {
        return (address(0x1), 100e18, address(0x2), 5000e18, 10e18);
    }

    function collateralRequired(address, address, uint256[] memory) public view returns (uint256, uint256, uint256) {
        return (110e18, 100e18, 10e18);
    }

    function fundsRequired(address, address, uint256[] calldata) public view returns (address, uint256, uint256, uint256) {
        return (address(0x2), 5e18, 2e18, 3e18);
    }

    function VERSION() external pure returns (uint256) {
        return 4;
    }
} 