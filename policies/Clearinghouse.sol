// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface ERC20 {
    function approve(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
    function asset() external view returns (address);
}

interface ERC4626 {
    function asset() external view returns (address);
    function withdraw(uint256, address, address) external;
    function maxWithdraw(address) external view returns (uint256);
    function previewWithdraw(uint256) external view returns (uint256);
    function deposit(uint256, address) external;
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function previewRedeem(uint256) external view returns (uint256);
}

interface IStaking {
    function unstake(address, uint256, bool, bool) external returns (uint256);
}

interface Cooler {
    function collateral() external view returns (ERC20);
    function debt() external view returns (ERC20);
    function requestLoan(uint256, uint256, uint256, uint256) external returns (uint256);
    function clearRequest(uint256, address, bool) external returns (uint256);
    function getLoan(uint256) external view returns (Loan memory);
    function extendLoanTerms(uint256, uint8) external;
    function claimDefaulted(uint256)
        external
        returns (uint256 principal, uint256 interest, uint256 collateral, uint256 elapsed);

    struct Loan {
        address lender;
        uint256 principal;
        Request request;
    }

    struct Request {
        uint256 duration;
    }
}

interface CoolerFactory {
    function created(address) external view returns (bool);
}

struct Permissions {
    bytes5 keycode;
    bytes4 func;
}

///  ARK Clearinghouse
contract Clearinghouse {
    // --- ERRORS ----------------------------------------------------
    error BadEscrow();
    error DurationMaximum();
    error OnlyBurnable();
    error TooEarlyToFund();
    error LengthDiscrepancy();
    error OnlyBorrower();
    error NotLender();
    error OnlyFromFactory();
    error ROLES_RequireRole(bytes32 role_);
    error Policy_WrongModuleVersion(bytes expected);

    // --- EVENTS ----------------------------------------------------
    event Activate();
    event Deactivate();
    event Defund(address token, uint256 amount);
    event Rebalance(bool defund, uint256 reserveAmount);

    // --- IMMUTABLE STATE -------------------------------------------
    ERC20 public immutable reserve;
    ERC4626 public immutable sReserve;
    ERC20 public immutable gARK;
    ERC20 public immutable ARK;
    IStaking public immutable staking;
    CoolerFactory public immutable factory;

    // --- MODULES ---------------------------------------------------
    address public CHREG;
    address public MINTR;
    address public TRSRY;
    address public ROLES;

    // --- STATE VARIABLES -------------------------------------------
    bool public active;
    uint256 public fundTime;
    uint256 public interestReceivables;
    uint256 public principalReceivables;

    // --- CONSTANTS ------------------------------------------------
    uint256 public constant INTEREST_RATE = 5e15;
    uint256 public constant LOAN_TO_COLLATERAL = 289292e16;
    uint256 public constant DURATION = 121 days;

    constructor(
        address ARK_,
        address gARK_,
        address staking_,
        address sReserve_,
        address coolerFactory_,
        address // kernel_
    ) {
        ARK = ERC20(ARK_);
        gARK = ERC20(gARK_);
        staking = IStaking(staking_);
        sReserve = ERC4626(sReserve_);
        reserve = ERC20(sReserve.asset());
        factory = CoolerFactory(coolerFactory_);
    }

    modifier onlyRole(bytes32 role_) {
        revert ROLES_RequireRole(role_);
        _;
    }

    function configureDependencies() external pure returns (bytes5[] memory dependencies) {
        dependencies = new bytes5[](4);
        dependencies[0] = "CHREG";
        dependencies[1] = "MINTR";
        dependencies[2] = "ROLES";
        dependencies[3] = "TRSRY";
        return dependencies;
    }

    function requestPermissions() external pure returns (Permissions[] memory requests) {
        requests = new Permissions[](6);
        requests[0] = Permissions("CHREG", 0x39a4448e); // activateClearinghouse
        requests[1] = Permissions("CHREG", 0xe5a353f2); // deactivateClearinghouse
        requests[2] = Permissions("MINTR", 0x76856456); // burnARK
        requests[3] = Permissions("TRSRY", 0x821a5944); // setDebt
        requests[4] = Permissions("TRSRY", 0x3f1a2606); // increaseWithdrawApproval
        requests[5] = Permissions("TRSRY", 0x48197c8f); // withdrawReserves
        return requests;
    }

    function VERSION() external pure returns (uint8 major, uint8 minor) {
        return (1, 2);
    }

    function lendToCooler(Cooler, uint256) external returns (uint256) {
        revert BadEscrow();
    }

    function extendLoan(Cooler, uint256, uint8) external {
        revert OnlyFromFactory();
    }

    function claimDefaulted(address[] calldata coolers_, uint256[] calldata) external {
        if (coolers_.length > 0 && !factory.created(coolers_[0])) {
            revert OnlyFromFactory();
        }
        revert LengthDiscrepancy();
    }

    function rebalance() public returns (bool) {
        if (fundTime > block.timestamp) revert TooEarlyToFund();
        return false;
    }

    function sweepIntoSavingsVault() public {}

    function burn() public {}

    function activate() external onlyRole("cooler_overseer") {}

    function emergencyShutdown() external onlyRole("emergency_shutdown") {}

    function defund(ERC20 token_, uint256) external onlyRole("cooler_overseer") {
        if (address(token_) == address(gARK)) revert OnlyBurnable();
    }

    function getCollateralForLoan(uint256 principal_) external pure returns (uint256) {
        return (principal_ * 1e18) / LOAN_TO_COLLATERAL;
    }

    function getLoanForCollateral(uint256 collateral_)
        public
        pure
        returns (uint256, uint256)
    {
        uint256 principal = (collateral_ * LOAN_TO_COLLATERAL) / 1e18;
        uint256 interest = (principal * (INTEREST_RATE * DURATION) / 365 days) / 1e18;
        return (principal, interest);
    }

    function interestForLoan(uint256 principal_, uint256 duration_)
        public
        pure
        returns (uint256)
    {
        uint256 interestPercent = (INTEREST_RATE * duration_) / 365 days;
        return (principal_ * interestPercent) / 1e18;
    }

    function getTotalReceivables() external view returns (uint256) {
        return principalReceivables + interestReceivables;
    }
} 