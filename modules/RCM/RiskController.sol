// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

// --- interfaces ---
interface IOracle {
    function getPrice(address) external view returns (uint256);
    function getVolatility(address) external view returns (uint256);
}

/// @title Risk Controller Module
/// @notice Manages risk parameters and exposure limits
contract RiskController {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event RiskParameterUpdated(address indexed asset, string parameter, uint256 oldValue, uint256 newValue);
    event AssetAdded(address indexed asset, uint256 maxExposure, uint256 volatilityThreshold);
    event AssetRemoved(address indexed asset);
    event ExposureChanged(address indexed asset, uint256 oldExposure, uint256 newExposure);
    event EmergencyShutdown(address indexed caller, string reason);
    event EmergencyRecovery(address indexed caller);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error RCM_OnlyGovernance();
    error RCM_OnlyRiskManager();
    error RCM_ZeroAddress();
    error RCM_AssetNotSupported(address asset);
    error RCM_AssetAlreadyAdded(address asset);
    error RCM_ExposureLimitExceeded(address asset, uint256 requested, uint256 maxAllowed);
    error RCM_VolatilityThresholdExceeded(address asset, uint256 current, uint256 threshold);
    error RCM_SystemInEmergencyState();
    error RCM_InvalidParameter(string parameter, uint256 value, uint256 min, uint256 max);
    error RCM_OracleFailure(address asset, string reason);

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public governance;
    address public riskManager;
    address public oracle;
    bool public emergencyShutdown;
    
    struct AssetRiskParams {
        bool isSupported;
        uint256 maxExposure; // Maximum allowed exposure in USD
        uint256 currentExposure; // Current exposure in USD
        uint256 volatilityThreshold; // Maximum allowed volatility (basis points)
        uint256 collateralFactor; // Percentage of asset value that can be borrowed against (basis points)
    }
    
    mapping(address => AssetRiskParams) public assetRiskParams;
    address[] public supportedAssets;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyGovernance() {
        if (msg.sender != governance) revert RCM_OnlyGovernance();
        _;
    }

    modifier onlyRiskManager() {
        if (msg.sender != riskManager && msg.sender != governance) revert RCM_OnlyRiskManager();
        _;
    }

    modifier notInEmergencyState() {
        if (emergencyShutdown) revert RCM_SystemInEmergencyState();
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address governance_, address riskManager_, address oracle_) {
        if (governance_ == address(0) || riskManager_ == address(0) || oracle_ == address(0)) 
            revert RCM_ZeroAddress();
        
        governance = governance_;
        riskManager = riskManager_;
        oracle = oracle_;
        emergencyShutdown = false;
    }

    // ============================================================================================//
    //                                     ADMIN FUNCTIONS                                         //
    // ============================================================================================//

    function addAsset(address asset_, uint256 maxExposure_, uint256 volatilityThreshold_, uint256 collateralFactor_) 
        external 
        onlyGovernance 
        notInEmergencyState 
    {
        if (asset_ == address(0)) revert RCM_ZeroAddress();
        if (assetRiskParams[asset_].isSupported) revert RCM_AssetAlreadyAdded(asset_);
        if (collateralFactor_ > 9000) revert RCM_InvalidParameter("collateralFactor", collateralFactor_, 0, 9000);
        
        assetRiskParams[asset_] = AssetRiskParams({
            isSupported: true,
            maxExposure: maxExposure_,
            currentExposure: 0,
            volatilityThreshold: volatilityThreshold_,
            collateralFactor: collateralFactor_
        });
        
        supportedAssets.push(asset_);
        
        emit AssetAdded(asset_, maxExposure_, volatilityThreshold_);
    }

    function removeAsset(address asset_) external onlyGovernance {
        if (!assetRiskParams[asset_].isSupported) revert RCM_AssetNotSupported(asset_);
        if (assetRiskParams[asset_].currentExposure > 0) 
            revert RCM_ExposureLimitExceeded(asset_, 0, assetRiskParams[asset_].currentExposure);
        
        assetRiskParams[asset_].isSupported = false;
        
        // Remove from array
        for (uint256 i = 0; i < supportedAssets.length; i++) {
            if (supportedAssets[i] == asset_) {
                supportedAssets[i] = supportedAssets[supportedAssets.length - 1];
                supportedAssets.pop();
                break;
            }
        }
        
        emit AssetRemoved(asset_);
    }

    function updateRiskParameter(
        address asset_, 
        string calldata parameter_, 
        uint256 newValue_
    ) external onlyRiskManager notInEmergencyState {
        if (!assetRiskParams[asset_].isSupported) revert RCM_AssetNotSupported(asset_);
        
        AssetRiskParams storage params = assetRiskParams[asset_];
        uint256 oldValue;
        
        // Update the specified parameter
        if (keccak256(bytes(parameter_)) == keccak256(bytes("maxExposure"))) {
            oldValue = params.maxExposure;
            params.maxExposure = newValue_;
        } else if (keccak256(bytes(parameter_)) == keccak256(bytes("volatilityThreshold"))) {
            oldValue = params.volatilityThreshold;
            params.volatilityThreshold = newValue_;
        } else if (keccak256(bytes(parameter_)) == keccak256(bytes("collateralFactor"))) {
            oldValue = params.collateralFactor;
            if (newValue_ > 9000) revert RCM_InvalidParameter("collateralFactor", newValue_, 0, 9000);
            params.collateralFactor = newValue_;
        } else {
            revert RCM_InvalidParameter(parameter_, 0, 0, 0);
        }
        
        emit RiskParameterUpdated(asset_, parameter_, oldValue, newValue_);
    }

    function triggerEmergencyShutdown(string calldata reason_) external onlyRiskManager {
        emergencyShutdown = true;
        emit EmergencyShutdown(msg.sender, reason_);
    }

    function recoverFromEmergency() external onlyGovernance {
        emergencyShutdown = false;
        emit EmergencyRecovery(msg.sender);
    }

    // ============================================================================================//
    //                                     CORE FUNCTIONS                                          //
    // ============================================================================================//

    function updateExposure(address asset_, uint256 newExposure_) external onlyRiskManager notInEmergencyState {
        if (!assetRiskParams[asset_].isSupported) revert RCM_AssetNotSupported(asset_);
        
        // Check if new exposure exceeds maximum
        if (newExposure_ > assetRiskParams[asset_].maxExposure) {
            revert RCM_ExposureLimitExceeded(
                asset_, 
                newExposure_, 
                assetRiskParams[asset_].maxExposure
            );
        }
        
        // Check volatility if increasing exposure
        if (newExposure_ > assetRiskParams[asset_].currentExposure) {
            try IOracle(oracle).getVolatility(asset_) returns (uint256 volatility) {
                if (volatility > assetRiskParams[asset_].volatilityThreshold) {
                    revert RCM_VolatilityThresholdExceeded(
                        asset_,
                        volatility,
                        assetRiskParams[asset_].volatilityThreshold
                    );
                }
            } catch Error(string memory reason) {
                revert RCM_OracleFailure(asset_, reason);
            } catch {
                revert RCM_OracleFailure(asset_, "Unknown error");
            }
        }
        
        uint256 oldExposure = assetRiskParams[asset_].currentExposure;
        assetRiskParams[asset_].currentExposure = newExposure_;
        
        emit ExposureChanged(asset_, oldExposure, newExposure_);
    }

    // ============================================================================================//
    //                                     VIEW FUNCTIONS                                          //
    // ============================================================================================//

    function getAssetRiskParams(address asset_) external view returns (
        bool isSupported,
        uint256 maxExposure,
        uint256 currentExposure,
        uint256 volatilityThreshold,
        uint256 collateralFactor
    ) {
        AssetRiskParams memory params = assetRiskParams[asset_];
        return (
            params.isSupported,
            params.maxExposure,
            params.currentExposure,
            params.volatilityThreshold,
            params.collateralFactor
        );
    }

    function getSupportedAssets() external view returns (address[] memory) {
        return supportedAssets;
    }

    function getAssetVolatility(address asset_) external view returns (uint256) {
        if (!assetRiskParams[asset_].isSupported) revert RCM_AssetNotSupported(asset_);
        
        try IOracle(oracle).getVolatility(asset_) returns (uint256 volatility) {
            return volatility;
        } catch {
            return 0;
        }
    }

    function getAssetPrice(address asset_) external view returns (uint256) {
        if (!assetRiskParams[asset_].isSupported) revert RCM_AssetNotSupported(asset_);
        
        try IOracle(oracle).getPrice(asset_) returns (uint256 price) {
            return price;
        } catch {
            return 0;
        }
    }

    function isExposureAllowed(address asset_, uint256 additionalExposure_) external view returns (bool) {
        if (!assetRiskParams[asset_].isSupported || emergencyShutdown) return false;
        
        uint256 newExposure = assetRiskParams[asset_].currentExposure + additionalExposure_;
        if (newExposure > assetRiskParams[asset_].maxExposure) return false;
        
        try IOracle(oracle).getVolatility(asset_) returns (uint256 volatility) {
            return volatility <= assetRiskParams[asset_].volatilityThreshold;
        } catch {
            return false;
        }
    }
}