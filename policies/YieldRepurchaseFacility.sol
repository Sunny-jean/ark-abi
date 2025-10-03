// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

interface ERC20 {
    function approve(address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function safeTransfer(address, uint256) external;
    function safeApprove(address, uint256) external;
    function decimals() external view returns (uint8);
    function asset() external view returns (address);
}

interface ERC4626 {
    function asset() external view returns (address);
    function previewRedeem(uint256) external view returns (uint256);
    function previewWithdraw(uint256) external view returns (uint256);
    function redeem(uint256, address, address) external;
    function withdraw(uint256, address, address) external;
    function deposit(uint256, address) external;
    function maxWithdraw(address) external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
}

interface IBondSDA {
    function createMarket(bytes calldata) external returns (uint256 marketId);
}

interface BurnableERC20 {
    function burn(uint256 amount) external;
}

interface IYieldRepo {
    function endEpoch() external;
    function getReserveBalance() external view returns (uint256 balance);
    function getNextYield() external view returns (uint256 yield);
    function getARKBalanceAndBacking()
        external
        view
        returns (uint256 balance, uint256 backing);
}

struct Permissions {
    bytes5 keycode;
    bytes4 func;
}

///  Yield Repurchase Facility
contract YieldRepurchaseFacility is IYieldRepo {
    // ========= ERRORS ========= //
    error ROLES_RequireRole(bytes32 role_);
    error Policy_WrongModuleVersion(bytes expected);

    // ========= EVENTS ========= //
    event RepoMarket(uint256 marketId, uint256 bidAmount);
    event NextYieldSet(uint256 nextYield);
    event Shutdown();

    // ========= STATE ========= //
    ERC4626 public immutable sReserve;
    ERC20 public immutable reserve;
    ERC20 public immutable ARK;
    address public immutable teller;
    IBondSDA public immutable auctioneer;

    address public TRSRY;
    address public PRICE;
    address public CHREG;
    address public ROLES;

    uint48 public epoch;
    uint256 public nextYield;
    uint256 public lastReserveBalance;
    uint256 public lastConversionRate;
    bool public isShutdown;

    constructor(address, address ARK_, address sReserve_, address teller_, address auctioneer_) {
        ARK = ERC20(ARK_);
        sReserve = ERC4626(sReserve_);
        reserve = ERC20(sReserve.asset());
        teller = teller_;
        auctioneer = IBondSDA(auctioneer_);
        isShutdown = true;
    }

    modifier onlyRole(bytes32 role_) {
        revert ROLES_RequireRole(role_);
        _;
    }

    function initialize(
        uint256 /*initialReserveBalance*/,
        uint256 /*initialConversionRate*/,
        uint256 /*initialYield*/
    ) external onlyRole("loop_daddy") {
    }

    function configureDependencies() external pure returns (bytes5[] memory dependencies) {
        dependencies = new bytes5[](4);
        dependencies[0] = "TRSRY";
        dependencies[1] = "PRICE";
        dependencies[2] = "CHREG";
        dependencies[3] = "ROLES";
        return dependencies;
    }

    function requestPermissions() external pure returns (Permissions[] memory permissions) {
        permissions = new Permissions[](2);
        permissions[0] = Permissions("TRSRY", 0x48197c8f); // withdrawReserves
        permissions[1] = Permissions("TRSRY", 0x3f1a2606); // increaseWithdrawApproval
        return permissions;
    }

    function VERSION() external pure returns (uint8 major, uint8 minor) {
        return (1, 2);
    }

    function endEpoch() public override onlyRole("heart") {
    }

    function adjustNextYield(uint256 /* newNextYield */) external onlyRole("loop_daddy") {
        revert("Too much increase");
    }

    function shutdown(ERC20[] memory /* tokensToTransfer */) external onlyRole("loop_daddy") {
    }

    function getReserveBalance() public view override returns (uint256 balance) {
        return 1_000_000e18;
    }

    function getNextYield() public view override returns (uint256 yield) {
        return 50_000e18;
    }

    function getARKBalanceAndBacking()
        public
        view
        override
        returns (uint256 balance, uint256 backing)
    {
        return (100e9, 1133e7);
    }
} 