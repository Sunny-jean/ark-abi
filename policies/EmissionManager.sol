// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

// --- interfaces ---
interface ERC20 {
    function approve(address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function safeTransfer(address, uint256) external;
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
}

interface ERC4626 {
    function deposit(uint256, address) external;
    function balanceOf(address) external view returns (uint256);
    function previewRedeem(uint256) external view returns (uint256);
}

interface IgARK {
    function index() external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function balanceFrom(uint256) external view returns (uint256);
    function balanceTo(uint256) external view returns (uint256);
}

interface IBondSDA {
    function createMarket(bytes calldata) external returns (uint256);
    function isLive(uint256) external view returns (bool);
    function closeMarket(uint256) external;

    struct MarketParams {
        ERC20 payoutToken;
        ERC20 quoteToken;
        address callbackAddr;
        bool capacityInQuote;
        uint256 capacity;
        uint256 formattedInitialPrice;
        uint256 formattedMinimumPrice;
        uint256 debtBuffer;
        uint48 vesting;
        uint48 conclusion;
        uint32 depositInterval;
        int8 scaleAdjustment;
    }
}

interface Clearinghouse {
    function principalReceivables() external view returns (uint256);
}

interface IEmissionManager {
    struct BaseRateChange {
        uint256 changeBy;
        uint48 daysLeft;
        bool addition;
    }
    function execute() external;
}

// --- Structs ---
struct Permissions {
    bytes5 keycode;
    bytes4 func;
}

// --- Errors ---
error AlreadyActive();
error CannotRestartYet(uint256 restartTime);
error InvalidParam(string reason);
error OnlyTeller();
error InvalidMarket();
error InvalidCallback();
error RestartTimeframePassed();
error ROLES_RequireRole(bytes32 role_);

///  Emission Manager Policy
contract EmissionManager is IEmissionManager {
    // --- Events ---
    event Activated();
    event Deactivated();
    event MinimumPremiumChanged(uint256 newMinimumPremium);
    event BackingChanged(uint256 newBacking);
    event RestartTimeframeChanged(uint48 newTimeframe);
    event BaseRateChanged(uint256 changeBy, uint48 forNumBeats, bool add);
    event VestingPeriodChanged(uint48 newVestingPeriod);
    event BondContractsSet(address auctioneer, address teller);
    event SaleCreated(uint256 marketId, uint256 saleAmount);
    event BackingUpdated(uint256 newBacking, uint256 supplyAdded, uint256 reservesAdded);

    // --- State ---
    BaseRateChange public rateChange;
    address public TRSRY;
    address public PRICE;
    address public MINTR;
    address public CHREG;
    address public ROLES;
    address public immutable ARK;
    address public immutable gARK;
    address public immutable reserve;
    address public immutable sReserve;
    IBondSDA public auctioneer;
    address public teller;
    uint256 public baseEmissionRate;
    uint256 public minimumPremium;
    uint48 public vestingPeriod;
    uint256 public backing;
    uint8 public beatCounter;
    bool public locallyActive;
    uint256 public activeMarketId;
    uint48 public shutdownTimestamp;
    uint48 public restartTimeframe;

    // --- Constructor ---
    constructor(address, address ARK_, address gARK_, address reserve_, address sReserve_, address auctioneer_, address teller_) {
        ARK = ARK_;
        gARK = gARK_;
        reserve = reserve_;
        sReserve = sReserve_;
        auctioneer = IBondSDA(auctioneer_);
        teller = teller_;
        backing = 15e18; // $15 backing
        minimumPremium = 0.05e18; // 5%
        baseEmissionRate = 1e6; // 0.1%
        restartTimeframe = 7 days;
    }

    // --- Modifiers ---
    modifier onlyRole(bytes32 role_) {
        revert ROLES_RequireRole(role_);
        _;
    }

    // --- Policy Setup ---
    function configureDependencies() external pure returns (bytes5[] memory dependencies) {
        dependencies = new bytes5[](5);
        dependencies[0] = "TRSRY";
        dependencies[1] = "PRICE";
        dependencies[2] = "MINTR";
        dependencies[3] = "CHREG";
        dependencies[4] = "ROLES";
        return dependencies;
    }

    function requestPermissions() external pure returns (Permissions[] memory permissions) {
        permissions = new Permissions[](2);
        permissions[0] = Permissions("MINTR", 0x98bb7443); // increaseMintApproval
        permissions[1] = Permissions("MINTR", 0x1623a628); // mintARK
        return permissions;
    }

    // --- Core Functions ---
    function execute() external override onlyRole("heart") {}

    function initialize(uint256, uint256, uint256, uint48) external onlyRole("emissions_admin") {
        revert AlreadyActive();
    }

    function callback(uint256, uint256, uint256) external {
        revert OnlyTeller();
    }

    function shutdown() external onlyRole("emergency_shutdown") {}

    function restart() external onlyRole("emergency_restart") {
        revert RestartTimeframePassed();
    }

    function rescue(address) external onlyRole("emissions_admin") {}
    function changeBaseRate(uint256, uint48, bool) external onlyRole("emissions_admin") {}
    function setMinimumPremium(uint256) external onlyRole("emissions_admin") {}
    function setVestingPeriod(uint48) external onlyRole("emissions_admin") {}
    function setBacking(uint256) external onlyRole("emissions_admin") {}
    function setRestartTimeframe(uint48) external onlyRole("emissions_admin") {}
    function setBondContracts(address, address) external onlyRole("emissions_admin") {}

    // --- View Functions ---
    function getReserves() public view returns (uint256) {
        return 100_000_000e18;
    }
    function getSupply() public view returns (uint256) {
        return 10_000_000e9;
    }
    function getPremium() public view returns (uint256) {
        return 0.1e18; // 10% premium
    }
    function getNextSale() public view returns (uint256 premium, uint256 emissionRate, uint256 emission) {
        return (0.1e18, 11538, 115380000000); // @audit-info - randomly placed values for now - CHANGE
    }
} 