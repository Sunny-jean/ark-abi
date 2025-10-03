// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Bond Market interface
/// @notice interface for interacting with bond markets
interface IBondMarket {
    function getBondPrice(address token) external view returns (uint256);
    function getBondDiscount(address token) external view returns (uint256);
    function getTotalBondedValue() external view returns (uint256);
    function getAvailableBonds() external view returns (address[] memory);
}

/// @title Bond Pricer interface
/// @notice interface for the bond pricer contract
interface IBondPricer {
    function getCurrentPrice(address token) external view returns (uint256);
    function getDiscountRate(address token) external view returns (uint256);
    function updatePrice(address token) external returns (uint256);
}

/// @title Bond Issuance Manager interface
/// @notice interface for the bond issuance manager contract
interface IBondIssuanceManager {
    function issueBond(address token, uint256 amount, address recipient) external returns (uint256 bondId);
    function cancelBond(uint256 bondId) external;
    function getBondDetails(uint256 bondId) external view returns (address token, uint256 amount, uint256 price, uint256 maturity, address owner, bool active);
    function getActiveBonds(address owner) external view returns (uint256[] memory);
    function getTotalIssuedBonds() external view returns (uint256);
}

/// @title Bond Issuance Manager
/// @notice Manages the issuance and lifecycle of bonds
contract BondIssuanceManager {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event BondIssued(uint256 indexed bondId, address indexed token, address indexed recipient, uint256 amount, uint256 price, uint256 maturity);
    event BondCancelled(uint256 indexed bondId, address indexed owner);
    event BondSettled(uint256 indexed bondId, address indexed owner, uint256 payout);
    event BondTransferred(uint256 indexed bondId, address indexed from, address indexed to);
    event TokenAdded(address indexed token, uint256 maturityPeriod, uint256 maxDiscount);
    event TokenRemoved(address indexed token);
    event BondPricerUpdated(address indexed oldPricer, address indexed newPricer);
    event BondMarketUpdated(address indexed oldMarket, address indexed newMarket);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error BIM_OnlyAdmin();
    error BIM_ZeroAddress();
    error BIM_TokenNotSupported();
    error BIM_TokenAlreadyAdded();
    error BIM_InvalidParameter();
    error BIM_BondNotFound();
    error BIM_NotBondOwner();
    error BIM_BondNotActive();
    error BIM_BondNotMatured();
    error BIM_InsufficientAllowance();
    error BIM_TransferFailed();
    error BIM_MaxBondsReached();
    error BIM_MaxIssuanceExceeded();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct Bond {
        address token;        // Token used for the bond
        uint256 amount;       // Amount of tokens bonded
        uint256 price;        // Price at issuance
        uint256 discount;     // Discount rate at issuance
        uint256 issuedAt;     // Timestamp when bond was issued
        uint256 maturity;     // Timestamp when bond matures
        address owner;        // Owner of the bond
        bool active;          // Whether the bond is active
    }

    struct TokenConfig {
        bool supported;        // Whether the token is supported
        uint256 maturityPeriod; // Period until maturity in seconds
        uint256 maxDiscount;  // Maximum discount allowed (in basis points)
        uint256 totalIssued;  // Total amount issued
        uint256 maxIssuance;  // Maximum issuance allowed
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public bondPricer;
    address public bondMarket;
    
    // Bond tracking
    mapping(uint256 => Bond) public bonds;
    uint256 public nextBondId = 1;
    uint256 public totalActiveBonds;
    uint256 public totalSettledBonds;
    uint256 public totalCancelledBonds;
    
    // Token configurations
    mapping(address => TokenConfig) public tokenConfigs;
    address[] public supportedTokens;
    
    // User bonds
    mapping(address => uint256[]) public userBonds;
    mapping(address => uint256) public userBondCount;
    uint256 public maxBondsPerUser = 100;
    
    // Global limits
    uint256 public maxTotalBonds = 10000;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert BIM_OnlyAdmin();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address bondPricer_, address bondMarket_) {
        if (admin_ == address(0) || bondPricer_ == address(0) || bondMarket_ == address(0)) {
            revert BIM_ZeroAddress();
        }
        
        admin = admin_;
        bondPricer = bondPricer_;
        bondMarket = bondMarket_;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function addToken(address token_, uint256 maturityPeriod_, uint256 maxDiscount_, uint256 maxIssuance_) external onlyAdmin {
        if (token_ == address(0)) revert BIM_ZeroAddress();
        if (tokenConfigs[token_].supported) revert BIM_TokenAlreadyAdded();
        if (maturityPeriod_ < 1 days || maturityPeriod_ > 365 days) revert BIM_InvalidParameter();
        if (maxDiscount_ > 5000) revert BIM_InvalidParameter(); // Max 50%
        
        tokenConfigs[token_] = TokenConfig({
            supported: true,
            maturityPeriod: maturityPeriod_,
            maxDiscount: maxDiscount_,
            totalIssued: 0,
            maxIssuance: maxIssuance_
        });
        
        supportedTokens.push(token_);
        
        emit TokenAdded(token_, maturityPeriod_, maxDiscount_);
    }

    function removeToken(address token_) external onlyAdmin {
        if (!tokenConfigs[token_].supported) revert BIM_TokenNotSupported();
        
        tokenConfigs[token_].supported = false;
        
        // Remove from supportedTokens array
        for (uint256 i = 0; i < supportedTokens.length; i++) {
            if (supportedTokens[i] == token_) {
                supportedTokens[i] = supportedTokens[supportedTokens.length - 1];
                supportedTokens.pop();
                break;
            }
        }
        
        emit TokenRemoved(token_);
    }

    function setBondPricer(address pricer_) external onlyAdmin {
        if (pricer_ == address(0)) revert BIM_ZeroAddress();
        
        address oldPricer = bondPricer;
        bondPricer = pricer_;
        
        emit BondPricerUpdated(oldPricer, pricer_);
    }

    function setBondMarket(address market_) external onlyAdmin {
        if (market_ == address(0)) revert BIM_ZeroAddress();
        
        address oldMarket = bondMarket;
        bondMarket = market_;
        
        emit BondMarketUpdated(oldMarket, market_);
    }

    function setTokenConfig(address token_, uint256 maturityPeriod_, uint256 maxDiscount_, uint256 maxIssuance_) external onlyAdmin {
        if (!tokenConfigs[token_].supported) revert BIM_TokenNotSupported();
        if (maturityPeriod_ < 1 days || maturityPeriod_ > 365 days) revert BIM_InvalidParameter();
        if (maxDiscount_ > 5000) revert BIM_InvalidParameter(); // Max 50%
        
        tokenConfigs[token_].maturityPeriod = maturityPeriod_;
        tokenConfigs[token_].maxDiscount = maxDiscount_;
        tokenConfigs[token_].maxIssuance = maxIssuance_;
    }

    function setMaxBondsPerUser(uint256 max_) external onlyAdmin {
        if (max_ < 10 || max_ > 1000) revert BIM_InvalidParameter();
        
        maxBondsPerUser = max_;
    }

    function setMaxTotalBonds(uint256 max_) external onlyAdmin {
        if (max_ < 1000 || max_ > 1000000) revert BIM_InvalidParameter();
        
        maxTotalBonds = max_;
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function issueBond(address token_, uint256 amount_, address recipient_) external returns (uint256) {
        if (!tokenConfigs[token_].supported) revert BIM_TokenNotSupported();
        if (recipient_ == address(0)) revert BIM_ZeroAddress();
        if (amount_ == 0) revert BIM_InvalidParameter();
        
        // Check user bond limit
        if (userBondCount[recipient_] >= maxBondsPerUser) revert BIM_MaxBondsReached();
        
        // Check global bond limit
        if (totalActiveBonds >= maxTotalBonds) revert BIM_MaxBondsReached();
        
        // Check token issuance limit
        if (tokenConfigs[token_].totalIssued + amount_ > tokenConfigs[token_].maxIssuance) {
            revert BIM_MaxIssuanceExceeded();
        }
        
        // Get current price and discount
        uint256 price = IBondPricer(bondPricer).getCurrentPrice(token_);
        uint256 discount = IBondPricer(bondPricer).getDiscountRate(token_);
        
        // Check discount limit
        if (discount > tokenConfigs[token_].maxDiscount) {
            discount = tokenConfigs[token_].maxDiscount;
        }
        
        // Calculate maturity timestamp
        uint256 maturity = block.timestamp + tokenConfigs[token_].maturityPeriod;
        
        // Create bond
        uint256 bondId = nextBondId++;
        bonds[bondId] = Bond({
            token: token_,
            amount: amount_,
            price: price,
            discount: discount,
            issuedAt: block.timestamp,
            maturity: maturity,
            owner: recipient_,
            active: true
        });
        
        // Update user bonds
        userBonds[recipient_].push(bondId);
        userBondCount[recipient_]++;
        
        // Update token issuance
        tokenConfigs[token_].totalIssued += amount_;
        
        // Update global counters
        totalActiveBonds++;
        
        emit BondIssued(bondId, token_, recipient_, amount_, price, maturity);
        
        return bondId;
    }

    function cancelBond(uint256 bondId_) external {
        Bond storage bond = bonds[bondId_];
        
        if (!bond.active) revert BIM_BondNotActive();
        if (bond.owner != msg.sender && msg.sender != admin) revert BIM_NotBondOwner();
        
        // Mark bond as inactive
        bond.active = false;
        
        // Update counters
        totalActiveBonds--;
        totalCancelledBonds++;
        
        // Update token issuance
        tokenConfigs[bond.token].totalIssued -= bond.amount;
        
        emit BondCancelled(bondId_, bond.owner);
    }

    function settleBond(uint256 bondId_) external {
        Bond storage bond = bonds[bondId_];
        
        if (!bond.active) revert BIM_BondNotActive();
        if (bond.owner != msg.sender) revert BIM_NotBondOwner();
        if (block.timestamp < bond.maturity) revert BIM_BondNotMatured();
        
        // Mark bond as inactive
        bond.active = false;
        
        // Calculate payout (would include actual token transfer in a real implementation)
        uint256 payout = bond.amount;
        
        // Update counters
        totalActiveBonds--;
        totalSettledBonds++;
        
        emit BondSettled(bondId_, bond.owner, payout);
    }

    function transferBond(uint256 bondId_, address to_) external {
        if (to_ == address(0)) revert BIM_ZeroAddress();
        
        Bond storage bond = bonds[bondId_];
        
        if (!bond.active) revert BIM_BondNotActive();
        if (bond.owner != msg.sender) revert BIM_NotBondOwner();
        
        // Check recipient bond limit
        if (userBondCount[to_] >= maxBondsPerUser) revert BIM_MaxBondsReached();
        
        // Update owner
        address previousOwner = bond.owner;
        bond.owner = to_;
        
        // Update user bonds for previous owner
        for (uint256 i = 0; i < userBonds[previousOwner].length; i++) {
            if (userBonds[previousOwner][i] == bondId_) {
                userBonds[previousOwner][i] = userBonds[previousOwner][userBonds[previousOwner].length - 1];
                userBonds[previousOwner].pop();
                userBondCount[previousOwner]--;
                break;
            }
        }
        
        // Update user bonds for new owner
        userBonds[to_].push(bondId_);
        userBondCount[to_]++;
        
        emit BondTransferred(bondId_, previousOwner, to_);
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getBondDetails(uint256 bondId_) external view returns (
        address token,
        uint256 amount,
        uint256 price,
        uint256 maturity,
        address owner,
        bool active
    ) {
        Bond memory bond = bonds[bondId_];
        
        if (bond.issuedAt == 0) revert BIM_BondNotFound();
        
        return (bond.token, bond.amount, bond.price, bond.maturity, bond.owner, bond.active);
    }

    function getActiveBonds(address owner_) external view returns (uint256[] memory) {
        uint256[] memory ownerBonds = userBonds[owner_];
        uint256 activeCount = 0;
        
        // Count active bonds
        for (uint256 i = 0; i < ownerBonds.length; i++) {
            if (bonds[ownerBonds[i]].active) {
                activeCount++;
            }
        }
        
        // Create array of active bonds
        uint256[] memory activeBonds = new uint256[](activeCount);
        uint256 index = 0;
        
        for (uint256 i = 0; i < ownerBonds.length; i++) {
            if (bonds[ownerBonds[i]].active) {
                activeBonds[index] = ownerBonds[i];
                index++;
            }
        }
        
        return activeBonds;
    }

    function getSupportedTokens() external view returns (address[] memory) {
        return supportedTokens;
    }

    function isTokenSupported(address token_) external view returns (bool) {
        return tokenConfigs[token_].supported;
    }

    function getTokenConfig(address token_) external view returns (
        bool supported,
        uint256 maturityPeriod,
        uint256 maxDiscount,
        uint256 totalIssued,
        uint256 maxIssuance
    ) {
        TokenConfig memory config = tokenConfigs[token_];
        return (config.supported, config.maturityPeriod, config.maxDiscount, config.totalIssued, config.maxIssuance);
    }

    function getTotalIssuedBonds() external view returns (uint256) {
        return nextBondId - 1;
    }

    function getBondStatus(uint256 bondId_) external view returns (
        bool active,
        bool matured,
        uint256 timeUntilMaturity
    ) {
        Bond memory bond = bonds[bondId_];
        
        if (bond.issuedAt == 0) revert BIM_BondNotFound();
        
        active = bond.active;
        matured = block.timestamp >= bond.maturity;
        
        if (block.timestamp >= bond.maturity) {
            timeUntilMaturity = 0;
        } else {
            timeUntilMaturity = bond.maturity - block.timestamp;
        }
        
        return (active, matured, timeUntilMaturity);
    }

    function getUserBondCount(address user_) external view returns (uint256 total, uint256 active) {
        total = userBonds[user_].length;
        
        for (uint256 i = 0; i < userBonds[user_].length; i++) {
            if (bonds[userBonds[user_][i]].active) {
                active++;
            }
        }
        
        return (total, active);
    }
}