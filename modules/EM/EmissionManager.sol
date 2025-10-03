// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

// --- interfaces ---
interface IARK {
    function balanceOf(address) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}

interface IBondPricer {
    function getCurrentPrice(address) external view returns (uint256);
    function getDiscountRate(address) external view returns (uint256);
}

/// @title Emission Manager Module
/// @notice Manages token emission policies and rates
contract EmissionManager {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event EmissionRateUpdated(uint256 oldRate, uint256 newRate);
    event RewardDistributed(address indexed recipient, uint256 amount);
    event BondPricerSet(address indexed pricer);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error EM_OnlyGovernance();
    error EM_InvalidRate(uint256 rate);
    error EM_ZeroAddress();
    error EM_NoRewardsAvailable();

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public governance;
    address public arkToken;
    address public bondPricer;
    
    uint256 public emissionRate; // tokens per block
    uint256 public lastEmissionBlock;
    uint256 public emissionCap; // maximum emission per epoch
    uint256 public totalEmitted;
    
    mapping(address => bool) public isRewardDistributor;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyGovernance() {
        if (msg.sender != governance) revert EM_OnlyGovernance();
        _;
    }

    modifier onlyDistributor() {
        if (!isRewardDistributor[msg.sender]) revert EM_OnlyGovernance();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address governance_, address arkToken_, uint256 initialEmissionRate_) {
        if (governance_ == address(0) || arkToken_ == address(0)) revert EM_ZeroAddress();
        if (initialEmissionRate_ == 0) revert EM_InvalidRate(initialEmissionRate_);
        
        governance = governance_;
        arkToken = arkToken_;
        emissionRate = initialEmissionRate_;
        lastEmissionBlock = block.number;
        emissionCap = 1000000 * 1e18; // 1 million tokens
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function setEmissionRate(uint256 newRate_) external onlyGovernance {
        if (newRate_ == 0) revert EM_InvalidRate(newRate_);
        
        uint256 oldRate = emissionRate;
        emissionRate = newRate_;
        
        emit EmissionRateUpdated(oldRate, newRate_);
    }

    function setEmissionCap(uint256 newCap_) external onlyGovernance {
        emissionCap = newCap_;
    }

    function setBondPricer(address pricer_) external onlyGovernance {
        if (pricer_ == address(0)) revert EM_ZeroAddress();
        
        bondPricer = pricer_;
        
        emit BondPricerSet(pricer_);
    }

    function setRewardDistributor(address distributor_, bool isEnabled_) external onlyGovernance {
        if (distributor_ == address(0)) revert EM_ZeroAddress();
        
        isRewardDistributor[distributor_] = isEnabled_;
    }

    // ============================================================================================//
    //                                     CORE FUNCTIONS                                          //
    // ============================================================================================//

    function distributeRewards(address recipient_, uint256 amount_) external onlyDistributor {
        uint256 availableRewards = getAvailableRewards();
        if (availableRewards < amount_) revert EM_NoRewardsAvailable();
        
        // this would transfer tokens
        // we'll just update the state
        totalEmitted += amount_;
        lastEmissionBlock = block.number;
        
        emit RewardDistributed(recipient_, amount_);
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getEmissionRate() external view returns (uint256) {
        return emissionRate;
    }

    function getAvailableRewards() public view returns (uint256) {
        uint256 blocksSinceLastEmission = block.number - lastEmissionBlock;
        uint256 newEmissions = blocksSinceLastEmission * emissionRate;
        
        return newEmissions > emissionCap ? emissionCap : newEmissions;
    }

    function getTotalEmitted() external view returns (uint256) {
        return totalEmitted;
    }

    function getCurrentBondPrice(address bondToken_) external view returns (uint256) {
        if (bondPricer == address(0)) return 0;
        
        return IBondPricer(bondPricer).getCurrentPrice(bondToken_);
    }
}