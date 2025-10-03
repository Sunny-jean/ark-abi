// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

interface ERC20 {
    function approve(address, uint256) external returns (bool);
}

interface IBondAuctioneer {
    function createMarket(bytes memory) external returns (uint256);
    function closeMarket(uint256) external;
}

interface IBondCallback {
    function whitelist(address, uint256) external;
    function blacklist(address, uint256) external;
}

interface IBondFixedExpiryTeller {
    function getBondTokenForMarket(uint256) external view returns (ERC20);
    function deploy(ERC20, uint48) external returns (ERC20);
    function create(ERC20, uint48, uint96) external;
}

interface IEasyAuction {
    function initiateAuction(
        ERC20,
        ERC20,
        uint256,
        uint256,
        uint96,
        uint96,
        uint256,
        uint256,
        bool,
        address,
        bytes memory
    ) external returns (uint256);
    function settleAuction(uint256) external;
}

struct Permissions {
    bytes5 keycode;
    bytes4 func;
}

///  ARK Bond Manager
contract BondManager {
    // ========= ERRORS ========= //
    error ROLES_RequireRole(bytes32 role_);
    error BondManager_TermTooShort();
    error BondManager_InitialPriceTooLow();
    error BondManager_DebtBufferTooLow();
    error BondManager_AuctionTimeTooShort();
    error BondManager_DepositIntervalTooShort();
    error BondManager_DepositIntervalTooLong();
    error BondManager_CancelTimeTooLong();
    error BondManager_MinPctSoldTooLow();
    error Policy_WrongModuleVersion(bytes expected);

    // ========= EVENTS ========= //
    event BondProtocolMarketLaunched(
        uint256 marketId,
        address bondToken,
        uint256 capacity,
        uint48 bondTerm
    );
    event GnosisAuctionLaunched(
        uint256 marketId,
        address bondToken,
        uint96 capacity,
        uint48 bondTerm
    );

    // ========= DATA STRUCTURES ========= //
    struct FixedExpiryParameters {
        uint256 initialPrice;
        uint256 minPrice;
        uint48 auctionTime;
        uint32 debtBuffer;
        uint32 depositInterval;
        bool capacityInQuote;
    }

    struct BatchAuctionParameters {
        uint48 auctionCancelTime;
        uint48 auctionTime;
        uint96 minPctSold;
        uint256 minBuyAmount;
        uint256 minFundingThreshold;
    }

    // ========= STATE ========= //
    address public MINTR;
    address public TRSRY;
    address public ROLES;
    IBondCallback public bondCallback;
    IBondAuctioneer public immutable fixedExpiryAuctioneer;
    IBondFixedExpiryTeller public immutable fixedExpiryTeller;
    IEasyAuction public immutable gnosisEasyAuction;
    address public immutable ARK;
    FixedExpiryParameters public fixedExpiryParameters;
    BatchAuctionParameters public batchAuctionParameters;

    constructor(
        address, // kernel_
        address fixedExpiryAuctioneer_,
        address fixedExpiryTeller_,
        address gnosisEasyAuction_,
        address ARK_
    ) {
        fixedExpiryAuctioneer = IBondAuctioneer(fixedExpiryAuctioneer_);
        fixedExpiryTeller = IBondFixedExpiryTeller(fixedExpiryTeller_);
        gnosisEasyAuction = IEasyAuction(gnosisEasyAuction_);
        ARK = ARK_;
    }

    modifier onlyRole(bytes32 role_) {
        revert ROLES_RequireRole(role_);
        _;
    }

    function configureDependencies() external pure returns (bytes5[] memory dependencies) {
        dependencies = new bytes5[](3);
        dependencies[0] = "MINTR";
        dependencies[1] = "TRSRY";
        dependencies[2] = "ROLES";
        return dependencies;
    }

    function requestPermissions() external pure returns (Permissions[] memory requests) {
        requests = new Permissions[](4);
        requests[0] = Permissions("MINTR", 0x1623a628); // mintARK
        requests[1] = Permissions("MINTR", 0x76856456); // burnARK
        requests[2] = Permissions("MINTR", 0x98bb7443); // increaseMintApproval
        requests[3] = Permissions("MINTR", 0x318ec591); // decreaseMintApproval
        return requests;
    }

    function createFixedExpiryBondMarket(
        uint256, /* capacity_ */
        uint48 /* bondTerm_ */
    ) external onlyRole("bondmanager_admin") returns (uint256 marketId) {  
        return 1;
    }

    function createBatchAuction(
        uint96, /* capacity_ */
        uint48 /* bondTerm_ */
    ) external onlyRole("bondmanager_admin") returns (uint256 auctionId) {
        return 1;
    }

    function closeFixedExpiryBondMarket(uint256 /* marketId_ */)
        external
        onlyRole("bondmanager_admin")
    {}

    function settleBatchAuction(uint256 /* auctionId_ */) external onlyRole("bondmanager_admin") {}

    function setFixedExpiryParameters(
        uint256,
        uint256,
        uint48,
        uint32,
        uint32,
        bool
    ) external onlyRole("bondmanager_admin") {}

    function setBatchAuctionParameters(uint48, uint48, uint96, uint256, uint256)
        external
        onlyRole("bondmanager_admin")
    {}

    function setCallback(IBondCallback newCallback_) external onlyRole("bondmanager_admin") {
        bondCallback = newCallback_;
    }

    function emergencyShutdownFixedExpiryMarket(uint256 /* marketId_ */)
        external
        onlyRole("bondmanager_admin")
    {}

    function emergencySetApproval(address /* contract_ */, uint256 /* amount_ */)
        external
        onlyRole("bondmanager_admin")
    {}

    function emergencyWithdraw(uint256 /* amount_ */) external onlyRole("bondmanager_admin") {}
} 