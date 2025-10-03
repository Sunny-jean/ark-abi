// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Buyback Reserve Checker
/// @notice Verifies available treasury reserves for buyback operations
interface IBuybackReserveChecker {
    function getAvailableReserves() external view returns (uint256);
    function getMaxReservesPercentage() external view returns (uint256);
    function getMinReservesThreshold() external view returns (uint256);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface ITreasury {
    function getReserveBalance(address token) external view returns (uint256);
    function getProtectedReserves(address token) external view returns (uint256);
}

contract BuybackReserveChecker is Ownable {
    // ============================================================================================//
    //                                        EVENTS                                                 //
    // ============================================================================================//

    event MaxReservesPercentageUpdated(uint256 oldPercentage, uint256 newPercentage);
    event MinReservesThresholdUpdated(uint256 oldThreshold, uint256 newThreshold);
    event TreasuryUpdated(address oldTreasury, address newTreasury);
    event ReserveTokenUpdated(address oldToken, address newToken);

    // ============================================================================================//
    //                                        ERRORS                                                //
    // ============================================================================================//

    error BuybackReserveChecker_InvalidPercentage();
    error BuybackReserveChecker_InvalidThreshold();
    error BuybackReserveChecker_InvalidAddress();
    error BuybackReserveChecker_Unauthorized();

// ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    
    // Treasury contract
    ITreasury public treasury;
    
    // Reserve token (e.g., DAI, USDC)
    IERC20 public reserveToken;
    
    // Maximum percentage of reserves that can be used for buybacks (in basis points, e.g., 1000 = 10%)
    uint256 public maxReservesPercentage;
    
    // Minimum reserves threshold below which buybacks are not allowed
    uint256 public minReservesThreshold;
    
    // Maximum percentage limit (in basis points)
    uint256 public constant MAX_PERCENTAGE_LIMIT = 5000; // 50%
    
    // Owner of the contract

    
    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(
        address initialOwner,
        address _treasury,
        address _reserveToken,
        uint256 _maxReservesPercentage,
        uint256 _minReservesThreshold
    ) Ownable(initialOwner) {
        if (_treasury == address(0) || _reserveToken == address(0)) {
            revert BuybackReserveChecker_InvalidAddress();
        }
        
        if (_maxReservesPercentage == 0 || _maxReservesPercentage > MAX_PERCENTAGE_LIMIT) {
            revert BuybackReserveChecker_InvalidPercentage();
        }
        
        treasury = ITreasury(_treasury);
        reserveToken = IERC20(_reserveToken);
        maxReservesPercentage = _maxReservesPercentage;
        minReservesThreshold = _minReservesThreshold;

    }
    
    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyOwner() override {
        if (msg.sender != owner()) {
            revert BuybackReserveChecker_Unauthorized();
        }
        _;
    }
    
    // ============================================================================================//
    //                                       FUNCTIONS                                             //
    // ============================================================================================//

    /// @notice Get the amount of reserves available for buybacks
    /// @return The available reserves amount
    function getAvailableReserves() external view returns (uint256) {
        // Get total reserves from treasury
        uint256 totalReserves;
        
        try treasury.getReserveBalance(address(reserveToken)) returns (uint256 reserves) {
            totalReserves = reserves;
        } catch {
            // Fallback to direct balance check if treasury function fails
            totalReserves = reserveToken.balanceOf(address(treasury));
        }
        
        // Get protected reserves (if available)
        uint256 protectedReserves = 0;
        try treasury.getProtectedReserves(address(reserveToken)) returns (uint256 protected) {
            protectedReserves = protected;
        } catch {
            // If function doesn't exist, use minReservesThreshold as protected amount
            protectedReserves = minReservesThreshold;
        }
        
        // Calculate available reserves
        if (totalReserves <= protectedReserves) {
            return 0;
        }
        
        uint256 unprotectedReserves = totalReserves - protectedReserves;
        
        // Apply maximum percentage limit
        uint256 maxAvailable = (totalReserves * maxReservesPercentage) / 10000;
        
        // Return the smaller of unprotected reserves and max available
        return unprotectedReserves < maxAvailable ? unprotectedReserves : maxAvailable;
    }
    
    /// @notice Get the maximum percentage of reserves that can be used for buybacks
    /// @return The maximum reserves percentage in basis points
    function getMaxReservesPercentage() external view returns (uint256) {
        return maxReservesPercentage;
    }
    
    /// @notice Get the minimum reserves threshold
    /// @return The minimum reserves threshold
    function getMinReservesThreshold() external view returns (uint256) {
        return minReservesThreshold;
    }
    
    /// @notice Check if there are sufficient reserves for a buyback of the given amount
    /// @param amount The amount to check
    /// @return Whether there are sufficient reserves
    function hasSufficientReserves(uint256 amount) external view returns (bool) {
        uint256 availableReserves = this.getAvailableReserves();
        return amount <= availableReserves;
    }
    
    /// @notice Set the maximum reserves percentage
    /// @param _maxReservesPercentage The new maximum reserves percentage in basis points
    function setMaxReservesPercentage(uint256 _maxReservesPercentage) external onlyOwner {
        if (_maxReservesPercentage == 0 || _maxReservesPercentage > MAX_PERCENTAGE_LIMIT) {
            revert BuybackReserveChecker_InvalidPercentage();
        }
        
        uint256 oldPercentage = maxReservesPercentage;
        maxReservesPercentage = _maxReservesPercentage;
        
        emit MaxReservesPercentageUpdated(oldPercentage, _maxReservesPercentage);
    }
    
    /// @notice Set the minimum reserves threshold
    /// @param _minReservesThreshold The new minimum reserves threshold
    function setMinReservesThreshold(uint256 _minReservesThreshold) external onlyOwner {
        uint256 oldThreshold = minReservesThreshold;
        minReservesThreshold = _minReservesThreshold;
        
        emit MinReservesThresholdUpdated(oldThreshold, _minReservesThreshold);
    }
    
    /// @notice Set the treasury address
    /// @param _treasury The new treasury address
    function setTreasury(address _treasury) external onlyOwner {
        if (_treasury == address(0)) {
            revert BuybackReserveChecker_InvalidAddress();
        }
        
        address oldTreasury = address(treasury);
        treasury = ITreasury(_treasury);
        
        emit TreasuryUpdated(oldTreasury, _treasury);
    }
    
    /// @notice Set the reserve token address
    /// @param _reserveToken The new reserve token address
    function setReserveToken(address _reserveToken) external onlyOwner {
        if (_reserveToken == address(0)) {
            revert BuybackReserveChecker_InvalidAddress();
        }
        
        address oldToken = address(reserveToken);
        reserveToken = IERC20(_reserveToken);
        
        emit ReserveTokenUpdated(oldToken, _reserveToken);
    }

    /// @notice Transfer ownership of the contract


    /// @param newOwner The address of the new owner
    function transferOwnership(address newOwner) public override onlyOwner {
        super.transferOwnership(newOwner);
    }
}