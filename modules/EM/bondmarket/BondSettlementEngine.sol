// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Bond Issuance Manager interface
/// @notice interface for the bond issuance manager contract
interface IBondIssuanceManager {
    function getBondDetails(uint256 bondId) external view returns (address token, uint256 amount, uint256 price, uint256 maturity, address owner, bool active);
    function getActiveBonds(address owner) external view returns (uint256[] memory);
    function settleBond(uint256 bondId) external;
}

/// @title Bond Settlement Engine interface
/// @notice interface for the bond settlement engine contract
interface IBondSettlementEngine {
    function settleBond(uint256 bondId) external returns (uint256 payout);
    function batchSettleBonds(uint256[] calldata bondIds) external returns (uint256 totalPayout);
    function getSettlementDetails(uint256 bondId) external view returns (uint256 payout, bool canSettle);
    function getSettlementHistory(address user) external view returns (uint256[] memory bondIds, uint256[] memory payouts, uint256[] memory timestamps);
}

/// @title Bond Settlement Engine
/// @notice Handles the settlement of matured bonds
contract BondSettlementEngine {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event BondSettled(uint256 indexed bondId, address indexed owner, uint256 payout, uint256 fee);
    event BatchSettlement(address indexed owner, uint256 bondCount, uint256 totalPayout, uint256 totalFee);
    event SettlementFeeUpdated(uint256 oldFee, uint256 newFee);
    event FeeRecipientUpdated(address indexed oldRecipient, address indexed newRecipient);
    event BondIssuanceManagerUpdated(address indexed oldManager, address indexed newManager);
    event SettlementPaused(address indexed pauser);
    event SettlementResumed(address indexed resumer);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error BSE_OnlyAdmin();
    error BSE_ZeroAddress();
    error BSE_BondNotFound();
    error BSE_BondNotActive();
    error BSE_BondNotMatured();
    error BSE_NotBondOwner();
    error BSE_SettlementPaused();
    error BSE_InvalidParameter();
    error BSE_SettlementFailed();
    error BSE_BatchTooLarge();
    error BSE_TransferFailed();

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    struct SettlementRecord {
        uint256 bondId;
        uint256 payout;
        uint256 fee;
        uint256 timestamp;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public bondIssuanceManager;
    address public feeRecipient;
    
    // Settlement configuration
    uint256 public settlementFee = 50; // 0.5% in basis points
    bool public settlementPaused;
    uint256 public maxBatchSize = 50;
    
    // Settlement records
    mapping(address => SettlementRecord[]) public userSettlements;
    mapping(uint256 => bool) public settledBonds;
    
    // Settlement statistics
    uint256 public totalSettledBonds;
    uint256 public totalSettlementValue;
    uint256 public totalFeesCollected;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert BSE_OnlyAdmin();
        _;
    }

    modifier whenNotPaused() {
        if (settlementPaused) revert BSE_SettlementPaused();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address bondIssuanceManager_, address feeRecipient_) {
        if (admin_ == address(0) || bondIssuanceManager_ == address(0) || feeRecipient_ == address(0)) {
            revert BSE_ZeroAddress();
        }
        
        admin = admin_;
        bondIssuanceManager = bondIssuanceManager_;
        feeRecipient = feeRecipient_;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function setSettlementFee(uint256 fee_) external onlyAdmin {
        if (fee_ > 500) revert BSE_InvalidParameter(); // Max 5%
        
        uint256 oldFee = settlementFee;
        settlementFee = fee_;
        
        emit SettlementFeeUpdated(oldFee, fee_);
    }

    function setFeeRecipient(address recipient_) external onlyAdmin {
        if (recipient_ == address(0)) revert BSE_ZeroAddress();
        
        address oldRecipient = feeRecipient;
        feeRecipient = recipient_;
        
        emit FeeRecipientUpdated(oldRecipient, recipient_);
    }

    function setBondIssuanceManager(address manager_) external onlyAdmin {
        if (manager_ == address(0)) revert BSE_ZeroAddress();
        
        address oldManager = bondIssuanceManager;
        bondIssuanceManager = manager_;
        
        emit BondIssuanceManagerUpdated(oldManager, manager_);
    }

    function setMaxBatchSize(uint256 size_) external onlyAdmin {
        if (size_ < 10 || size_ > 200) revert BSE_InvalidParameter();
        
        maxBatchSize = size_;
    }

    function pauseSettlement() external onlyAdmin {
        settlementPaused = true;
        
        emit SettlementPaused(msg.sender);
    }

    function resumeSettlement() external onlyAdmin {
        settlementPaused = false;
        
        emit SettlementResumed(msg.sender);
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    function settleBond(uint256 bondId_) external whenNotPaused returns (uint256) {
        // Get bond details
        (address token, uint256 amount, , uint256 maturity, address owner, bool active) = 
            IBondIssuanceManager(bondIssuanceManager).getBondDetails(bondId_);
        
        // Validate bond
        if (!active) revert BSE_BondNotActive();
        if (owner != msg.sender) revert BSE_NotBondOwner();
        if (block.timestamp < maturity) revert BSE_BondNotMatured();
        if (settledBonds[bondId_]) revert BSE_SettlementFailed();
        
        // Calculate payout and fee
        uint256 fee = (amount * settlementFee) / 10000;
        uint256 payout = amount - fee;
        
        // Mark bond as settled
        settledBonds[bondId_] = true;
        
        // Settle bond in issuance manager
        IBondIssuanceManager(bondIssuanceManager).settleBond(bondId_);
        
        // Record settlement
        SettlementRecord memory record = SettlementRecord({
            bondId: bondId_,
            payout: payout,
            fee: fee,
            timestamp: block.timestamp
        });
        
        userSettlements[owner].push(record);
        
        // Update statistics
        totalSettledBonds++;
        totalSettlementValue += payout;
        totalFeesCollected += fee;
        
        emit BondSettled(bondId_, owner, payout, fee);
        
        return payout;
    }

    function batchSettleBonds(uint256[] calldata bondIds_) external whenNotPaused returns (uint256) {
        if (bondIds_.length == 0) revert BSE_InvalidParameter();
        if (bondIds_.length > maxBatchSize) revert BSE_BatchTooLarge();
        
        uint256 totalPayout = 0;
        uint256 totalFee = 0;
        uint256 settledCount = 0;
        
        for (uint256 i = 0; i < bondIds_.length; i++) {
            uint256 bondId = bondIds_[i];
            
            // Get bond details
            (address token, uint256 amount, , uint256 maturity, address owner, bool active) = 
                IBondIssuanceManager(bondIssuanceManager).getBondDetails(bondId);
            
            // Skip invalid bonds
            if (!active || owner != msg.sender || block.timestamp < maturity || settledBonds[bondId]) {
                continue;
            }
            
            // Calculate payout and fee
            uint256 fee = (amount * settlementFee) / 10000;
            uint256 payout = amount - fee;
            
            // Mark bond as settled
            settledBonds[bondId] = true;
            
            // Settle bond in issuance manager
            IBondIssuanceManager(bondIssuanceManager).settleBond(bondId);
            
            // Record settlement
            SettlementRecord memory record = SettlementRecord({
                bondId: bondId,
                payout: payout,
                fee: fee,
                timestamp: block.timestamp
            });
            
            userSettlements[owner].push(record);
            
            // Update batch totals
            totalPayout += payout;
            totalFee += fee;
            settledCount++;
            
            emit BondSettled(bondId, owner, payout, fee);
        }
        
        // Update statistics
        totalSettledBonds += settledCount;
        totalSettlementValue += totalPayout;
        totalFeesCollected += totalFee;
        
        if (settledCount == 0) revert BSE_SettlementFailed();
        
        emit BatchSettlement(msg.sender, settledCount, totalPayout, totalFee);
        
        return totalPayout;
    }

    function settleAllMaturedBonds() external whenNotPaused returns (uint256) {
        // Get all active bonds for the user
        uint256[] memory activeBonds = IBondIssuanceManager(bondIssuanceManager).getActiveBonds(msg.sender);
        
        if (activeBonds.length == 0) revert BSE_InvalidParameter();
        if (activeBonds.length > maxBatchSize) revert BSE_BatchTooLarge();
        
        uint256 totalPayout = 0;
        uint256 totalFee = 0;
        uint256 settledCount = 0;
        
        for (uint256 i = 0; i < activeBonds.length; i++) {
            uint256 bondId = activeBonds[i];
            
            // Get bond details
            (address token, uint256 amount, , uint256 maturity, address owner, bool active) = 
                IBondIssuanceManager(bondIssuanceManager).getBondDetails(bondId);
            
            // Skip invalid or not matured bonds
            if (!active || owner != msg.sender || block.timestamp < maturity || settledBonds[bondId]) {
                continue;
            }
            
            // Calculate payout and fee
            uint256 fee = (amount * settlementFee) / 10000;
            uint256 payout = amount - fee;
            
            // Mark bond as settled
            settledBonds[bondId] = true;
            
            // Settle bond in issuance manager
            IBondIssuanceManager(bondIssuanceManager).settleBond(bondId);
            
            // Record settlement
            SettlementRecord memory record = SettlementRecord({
                bondId: bondId,
                payout: payout,
                fee: fee,
                timestamp: block.timestamp
            });
            
            userSettlements[owner].push(record);
            
            // Update batch totals
            totalPayout += payout;
            totalFee += fee;
            settledCount++;
            
            emit BondSettled(bondId, owner, payout, fee);
        }
        
        // Update statistics
        totalSettledBonds += settledCount;
        totalSettlementValue += totalPayout;
        totalFeesCollected += totalFee;
        
        if (settledCount == 0) revert BSE_SettlementFailed();
        
        emit BatchSettlement(msg.sender, settledCount, totalPayout, totalFee);
        
        return totalPayout;
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getSettlementDetails(uint256 bondId_) external view returns (uint256 payout, bool canSettle) {
        // Get bond details
        (address token, uint256 amount, , uint256 maturity, address owner, bool active) = 
            IBondIssuanceManager(bondIssuanceManager).getBondDetails(bondId_);
        
        // Calculate potential payout
        uint256 fee = (amount * settlementFee) / 10000;
        payout = amount - fee;
        
        // Check if bond can be settled
        canSettle = active && block.timestamp >= maturity && !settledBonds[bondId_] && !settlementPaused;
        
        return (payout, canSettle);
    }

    function getSettlementHistory(address user_) external view returns (
        uint256[] memory bondIds,
        uint256[] memory payouts,
        uint256[] memory timestamps
    ) {
        SettlementRecord[] memory records = userSettlements[user_];
        
        bondIds = new uint256[](records.length);
        payouts = new uint256[](records.length);
        timestamps = new uint256[](records.length);
        
        for (uint256 i = 0; i < records.length; i++) {
            bondIds[i] = records[i].bondId;
            payouts[i] = records[i].payout;
            timestamps[i] = records[i].timestamp;
        }
        
        return (bondIds, payouts, timestamps);
    }

    function getUserSettlementCount(address user_) external view returns (uint256) {
        return userSettlements[user_].length;
    }

    function getSettlementRecord(address user_, uint256 index_) external view returns (
        uint256 bondId,
        uint256 payout,
        uint256 fee,
        uint256 timestamp
    ) {
        if (index_ >= userSettlements[user_].length) revert BSE_InvalidParameter();
        
        SettlementRecord memory record = userSettlements[user_][index_];
        return (record.bondId, record.payout, record.fee, record.timestamp);
    }

    function isBondSettled(uint256 bondId_) external view returns (bool) {
        return settledBonds[bondId_];
    }

    function getSettlementStatistics() external view returns (
        uint256 totalBonds,
        uint256 totalValue,
        uint256 totalFees
    ) {
        return (totalSettledBonds, totalSettlementValue, totalFeesCollected);
    }
}