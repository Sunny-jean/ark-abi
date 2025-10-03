// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Bond Issuance Manager interface
/// @notice interface for the bond issuance manager contract
interface IBondIssuanceManager {
    function getBondDetails(uint256 bondId) external view returns (address token, uint256 amount, uint256 price, uint256 maturity, address owner, bool active);
    function isTokenSupported(address token) external view returns (bool);
}

/// @title Bond Collateral Manager interface
/// @notice interface for the bond collateral manager contract
interface IBondCollateralManager {
    function depositCollateral(address token, uint256 amount) external returns (uint256 collateralId);
    function withdrawCollateral(uint256 collateralId, uint256 amount) external returns (uint256 withdrawn);
    function getCollateralDetails(uint256 collateralId) external view returns (address token, uint256 amount, address owner);
    function getUserCollateral(address user) external view returns (uint256[] memory collateralIds);
    function getTotalCollateral(address token) external view returns (uint256);
}

/// @title Bond Collateral Manager
/// @notice Manages collateral for bond issuance
contract BondCollateralManager {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event CollateralDeposited(uint256 indexed collateralId, address indexed token, address indexed owner, uint256 amount);
    event CollateralWithdrawn(uint256 indexed collateralId, address indexed token, address indexed owner, uint256 amount);
    event CollateralLocked(uint256 indexed collateralId, uint256 indexed bondId, uint256 amount);
    event CollateralReleased(uint256 indexed collateralId, uint256 indexed bondId, uint256 amount);
    event TokenAdded(address indexed token, uint256 collateralRatio);
    event TokenRemoved(address indexed token);
    event CollateralRatioUpdated(address indexed token, uint256 oldRatio, uint256 newRatio);
    event BondIssuanceManagerUpdated(address indexed oldManager, address indexed newManager);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error BCM_OnlyAdmin();
    error BCM_ZeroAddress();
    error BCM_TokenNotSupported();
    error BCM_TokenAlreadyAdded();
    error BCM_InvalidParameter();
    error BCM_CollateralNotFound();
    error BCM_NotCollateralOwner();
    error BCM_InsufficientCollateral();
    error BCM_CollateralLocked();
    error BCM_TransferFailed();
    error BCM_BondNotFound();
    error BCM_NotBondOwner();
    error BCM_BondNotActive();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct Collateral {
        address token;        // Token used as collateral
        uint256 amount;       // Total amount deposited
        uint256 locked;       // Amount locked for bonds
        address owner;        // Owner of the collateral
        bool active;          // Whether the collateral is active
    }

    struct TokenConfig {
        bool supported;        // Whether the token is supported
        uint256 collateralRatio; // Required collateral ratio (in basis points)
        uint256 totalDeposited;  // Total amount deposited
        uint256 totalLocked;     // Total amount locked
    }

    struct BondCollateral {
        uint256 collateralId;  // ID of the collateral
        uint256 bondId;        // ID of the bond
        uint256 amount;        // Amount locked for this bond
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public bondIssuanceManager;
    
    // Collateral tracking
    mapping(uint256 => Collateral) public collaterals;
    uint256 public nextCollateralId = 1;
    
    // Token configurations
    mapping(address => TokenConfig) public tokenConfigs;
    address[] public supportedTokens;
    
    // User collaterals
    mapping(address => uint256[]) public userCollaterals;
    
    // Bond collaterals
    mapping(uint256 => BondCollateral[]) public bondCollaterals;
    mapping(uint256 => uint256) public collateralLocks;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert BCM_OnlyAdmin();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address bondIssuanceManager_) {
        if (admin_ == address(0) || bondIssuanceManager_ == address(0)) revert BCM_ZeroAddress();
        
        admin = admin_;
        bondIssuanceManager = bondIssuanceManager_;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function addToken(address token_, uint256 collateralRatio_) external onlyAdmin {
        if (token_ == address(0)) revert BCM_ZeroAddress();
        if (tokenConfigs[token_].supported) revert BCM_TokenAlreadyAdded();
        if (collateralRatio_ < 10000 || collateralRatio_ > 30000) revert BCM_InvalidParameter(); // 100% to 300%
        
        // Check if token is supported by bond issuance manager
        if (!IBondIssuanceManager(bondIssuanceManager).isTokenSupported(token_)) {
            revert BCM_TokenNotSupported();
        }
        
        tokenConfigs[token_] = TokenConfig({
            supported: true,
            collateralRatio: collateralRatio_,
            totalDeposited: 0,
            totalLocked: 0
        });
        
        supportedTokens.push(token_);
        
        emit TokenAdded(token_, collateralRatio_);
    }

    function removeToken(address token_) external onlyAdmin {
        if (!tokenConfigs[token_].supported) revert BCM_TokenNotSupported();
        if (tokenConfigs[token_].totalLocked > 0) revert BCM_CollateralLocked();
        
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

    function setCollateralRatio(address token_, uint256 collateralRatio_) external onlyAdmin {
        if (!tokenConfigs[token_].supported) revert BCM_TokenNotSupported();
        if (collateralRatio_ < 10000 || collateralRatio_ > 30000) revert BCM_InvalidParameter(); // 100% to 300%
        
        uint256 oldRatio = tokenConfigs[token_].collateralRatio;
        tokenConfigs[token_].collateralRatio = collateralRatio_;
        
        emit CollateralRatioUpdated(token_, oldRatio, collateralRatio_);
    }

    function setBondIssuanceManager(address manager_) external onlyAdmin {
        if (manager_ == address(0)) revert BCM_ZeroAddress();
        
        address oldManager = bondIssuanceManager;
        bondIssuanceManager = manager_;
        
        emit BondIssuanceManagerUpdated(oldManager, manager_);
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function depositCollateral(address token_, uint256 amount_) external returns (uint256) {
        if (!tokenConfigs[token_].supported) revert BCM_TokenNotSupported();
        if (amount_ == 0) revert BCM_InvalidParameter();
        
        // Create new collateral entry
        uint256 collateralId = nextCollateralId++;
        collaterals[collateralId] = Collateral({
            token: token_,
            amount: amount_,
            locked: 0,
            owner: msg.sender,
            active: true
        });
        
        // Update user collaterals
        userCollaterals[msg.sender].push(collateralId);
        
        // Update token statistics
        tokenConfigs[token_].totalDeposited += amount_;
        
        // this would transfer tokens from the user
        // require(IERC20(token_).transferFrom(msg.sender, address(this), amount_), "Transfer failed");
        
        emit CollateralDeposited(collateralId, token_, msg.sender, amount_);
        
        return collateralId;
    }

    function withdrawCollateral(uint256 collateralId_, uint256 amount_) external returns (uint256) {
        Collateral storage collateral = collaterals[collateralId_];
        
        if (!collateral.active) revert BCM_CollateralNotFound();
        if (collateral.owner != msg.sender) revert BCM_NotCollateralOwner();
        if (amount_ == 0 || amount_ > collateral.amount - collateral.locked) revert BCM_InvalidParameter();
        
        // Update collateral
        collateral.amount -= amount_;
        
        // Update token statistics
        tokenConfigs[collateral.token].totalDeposited -= amount_;
        
        // this would transfer tokens to the user
        // require(IERC20(collateral.token).transfer(msg.sender, amount_), "Transfer failed");
        
        emit CollateralWithdrawn(collateralId_, collateral.token, msg.sender, amount_);
        
        return amount_;
    }

    function lockCollateral(uint256 collateralId_, uint256 bondId_, uint256 amount_) external {
        // this would be called by the bond issuance manager
        if (msg.sender != admin && msg.sender != bondIssuanceManager) revert BCM_OnlyAdmin();
        
        Collateral storage collateral = collaterals[collateralId_];
        
        if (!collateral.active) revert BCM_CollateralNotFound();
        if (amount_ == 0 || amount_ > collateral.amount - collateral.locked) revert BCM_InsufficientCollateral();
        
        // Get bond details to verify
        (address token, , , , address owner, bool active) = IBondIssuanceManager(bondIssuanceManager).getBondDetails(bondId_);
        
        if (!active) revert BCM_BondNotActive();
        if (token != collateral.token) revert BCM_TokenNotSupported();
        if (owner != collateral.owner) revert BCM_NotBondOwner();
        
        // Update collateral
        collateral.locked += amount_;
        
        // Update token statistics
        tokenConfigs[collateral.token].totalLocked += amount_;
        
        // Record bond collateral
        bondCollaterals[bondId_].push(BondCollateral({
            collateralId: collateralId_,
            bondId: bondId_,
            amount: amount_
        }));
        
        // Update collateral locks
        collateralLocks[collateralId_] += 1;
        
        emit CollateralLocked(collateralId_, bondId_, amount_);
    }

    function releaseCollateral(uint256 bondId_) external {
        // this would be called by the bond settlement engine
        if (msg.sender != admin && msg.sender != bondIssuanceManager) revert BCM_OnlyAdmin();
        
        BondCollateral[] storage bondCollateral = bondCollaterals[bondId_];
        
        if (bondCollateral.length == 0) revert BCM_BondNotFound();
        
        // Get bond details to verify
        (, , , , , bool active) = IBondIssuanceManager(bondIssuanceManager).getBondDetails(bondId_);
        
        if (active) revert BCM_BondNotActive(); // Bond must be settled or cancelled
        
        for (uint256 i = 0; i < bondCollateral.length; i++) {
            uint256 collateralId = bondCollateral[i].collateralId;
            uint256 amount = bondCollateral[i].amount;
            
            Collateral storage collateral = collaterals[collateralId];
            
            if (collateral.active) {
                // Update collateral
                collateral.locked -= amount;
                
                // Update token statistics
                tokenConfigs[collateral.token].totalLocked -= amount;
                
                // Update collateral locks
                collateralLocks[collateralId] -= 1;
                
                emit CollateralReleased(collateralId, bondId_, amount);
            }
        }
        
        // Clear bond collateral
        delete bondCollaterals[bondId_];
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getCollateralDetails(uint256 collateralId_) external view returns (
        address token,
        uint256 amount,
        uint256 locked,
        address owner,
        bool active
    ) {
        Collateral memory collateral = collaterals[collateralId_];
        
        if (!collateral.active && collateral.amount == 0) revert BCM_CollateralNotFound();
        
        return (collateral.token, collateral.amount, collateral.locked, collateral.owner, collateral.active);
    }

    function getUserCollateral(address user_) external view returns (uint256[] memory) {
        return userCollaterals[user_];
    }

    function getTotalCollateral(address token_) external view returns (uint256 total, uint256 locked) {
        if (!tokenConfigs[token_].supported) revert BCM_TokenNotSupported();
        
        return (tokenConfigs[token_].totalDeposited, tokenConfigs[token_].totalLocked);
    }

    function getSupportedTokens() external view returns (address[] memory) {
        return supportedTokens;
    }

    function isTokenSupported(address token_) external view returns (bool) {
        return tokenConfigs[token_].supported;
    }

    function getTokenConfig(address token_) external view returns (
        bool supported,
        uint256 collateralRatio,
        uint256 totalDeposited,
        uint256 totalLocked
    ) {
        TokenConfig memory config = tokenConfigs[token_];
        return (config.supported, config.collateralRatio, config.totalDeposited, config.totalLocked);
    }

    function getBondCollateral(uint256 bondId_) external view returns (
        uint256[] memory collateralIds,
        uint256[] memory amounts
    ) {
        BondCollateral[] memory bondCollateral = bondCollaterals[bondId_];
        
        collateralIds = new uint256[](bondCollateral.length);
        amounts = new uint256[](bondCollateral.length);
        
        for (uint256 i = 0; i < bondCollateral.length; i++) {
            collateralIds[i] = bondCollateral[i].collateralId;
            amounts[i] = bondCollateral[i].amount;
        }
        
        return (collateralIds, amounts);
    }

    function isCollateralLocked(uint256 collateralId_) external view returns (bool) {
        return collateralLocks[collateralId_] > 0;
    }

    function getAvailableCollateral(uint256 collateralId_) external view returns (uint256) {
        Collateral memory collateral = collaterals[collateralId_];
        
        if (!collateral.active) revert BCM_CollateralNotFound();
        
        return collateral.amount - collateral.locked;
    }

    function getUserCollateralByToken(address user_, address token_) external view returns (
        uint256[] memory collateralIds,
        uint256[] memory amounts,
        uint256[] memory locked
    ) {
        uint256[] memory userCollateralIds = userCollaterals[user_];
        uint256 count = 0;
        
        // Count collaterals of the specified token
        for (uint256 i = 0; i < userCollateralIds.length; i++) {
            Collateral memory collateral = collaterals[userCollateralIds[i]];
            if (collateral.active && collateral.token == token_) {
                count++;
            }
        }
        
        // Create arrays
        collateralIds = new uint256[](count);
        amounts = new uint256[](count);
        locked = new uint256[](count);
        
        // Fill arrays
        uint256 index = 0;
        for (uint256 i = 0; i < userCollateralIds.length; i++) {
            Collateral memory collateral = collaterals[userCollateralIds[i]];
            if (collateral.active && collateral.token == token_) {
                collateralIds[index] = userCollateralIds[i];
                amounts[index] = collateral.amount;
                locked[index] = collateral.locked;
                index++;
            }
        }
        
        return (collateralIds, amounts, locked);
    }
}