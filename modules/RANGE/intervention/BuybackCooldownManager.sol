// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.15;

/// @title Buyback Cooldown Manager
/// @notice Manages cooldown periods between buyback operations to prevent excessive market activity

// ========= interfaceS ========= //

/// @notice interface for the Buyback Cooldown Manager
interface IBuybackCooldownManager {
    // ========= EVENTS ========= //

    /// @notice Emitted when a buyback is recorded
    /// @param timestamp The timestamp when the buyback was recorded
    event BuybackRecorded(uint256 timestamp);

    /// @notice Emitted when the cooldown period is updated
    /// @param oldCooldownPeriod The previous cooldown period
    /// @param newCooldownPeriod The new cooldown period
    event CooldownPeriodUpdated(uint256 oldCooldownPeriod, uint256 newCooldownPeriod);

    /// @notice Emitted when an authorized caller is added
    /// @param caller The address of the authorized caller
    event AuthorizedCallerAdded(address indexed caller);

    /// @notice Emitted when an authorized caller is removed
    /// @param caller The address of the removed caller
    event AuthorizedCallerRemoved(address indexed caller);

    /// @notice Emitted when ownership is transferred
    /// @param previousOwner The address of the previous owner
    /// @param newOwner The address of the new owner
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // ========= ERRORS ========= //

    /// @notice Error when a caller is not authorized
    error BuybackCooldownManager_NotAuthorized();

    /// @notice Error when a buyback is attempted during cooldown
    error BuybackCooldownManager_InCooldownPeriod();

    /// @notice Error when the cooldown period is set to zero
    error BuybackCooldownManager_InvalidCooldownPeriod();

    /// @notice Error when the caller is not the owner
    error BuybackCooldownManager_OnlyOwner();

    /// @notice Error when the caller is already authorized
    error BuybackCooldownManager_AlreadyAuthorized();

    /// @notice Error when the caller is not currently authorized
    error BuybackCooldownManager_NotCurrentlyAuthorized();

    // ========= FUNCTIONS ========= //

    /// @notice Checks if a buyback can be executed based on cooldown period
    /// @return Whether a buyback can be executed
    function canExecuteBuyback() external view returns (bool);

    /// @notice Records a buyback operation
    function recordBuyback() external;

    /// @notice Gets the timestamp of the last buyback
    /// @return The timestamp of the last buyback
    function getLastBuybackTimestamp() external view returns (uint256);

    /// @notice Gets the cooldown period
    /// @return The cooldown period in seconds
    function getCooldownPeriod() external view returns (uint256);

    /// @notice Gets the remaining cooldown time
    /// @return The remaining cooldown time in seconds
    function getRemainingCooldown() external view returns (uint256);

    /// @notice Sets the cooldown period
    /// @param newCooldownPeriod The new cooldown period in seconds
    function setCooldownPeriod(uint256 newCooldownPeriod) external;

    /// @notice Adds an authorized caller
    /// @param caller The address to authorize
    function addAuthorizedCaller(address caller) external;

    /// @notice Removes an authorized caller
    /// @param caller The address to remove authorization from
    function removeAuthorizedCaller(address caller) external;

    /// @notice Checks if an address is an authorized caller
    /// @param caller The address to check
    /// @return Whether the address is an authorized caller
    function isAuthorizedCaller(address caller) external view returns (bool);

    /// @notice Transfers ownership of the contract
    /// @param newOwner The address of the new owner
    function transferOwnership(address newOwner) external;
}

/// @title Buyback Cooldown Manager
/// @notice Manages cooldown periods between buyback operations to prevent excessive market activity
contract BuybackCooldownManager is IBuybackCooldownManager {
    // ========= STATE VARIABLES ========= //

    /// @notice The cooldown period in seconds
    uint256 public cooldownPeriod;

    /// @notice The timestamp of the last buyback
    uint256 public lastBuybackTimestamp;

    /// @notice The owner of the contract
    address public owner;

    /// @notice Mapping of authorized callers
    mapping(address => bool) public authorizedCallers;

    // ========= CONSTRUCTOR ========= //

    /// @notice Constructor
    /// @param initialCooldownPeriod The initial cooldown period in seconds
    constructor(uint256 initialCooldownPeriod) {
        if (initialCooldownPeriod == 0) revert BuybackCooldownManager_InvalidCooldownPeriod();
        
        cooldownPeriod = initialCooldownPeriod;
        owner = msg.sender;
        authorizedCallers[msg.sender] = true;
        
        emit CooldownPeriodUpdated(0, initialCooldownPeriod);
        emit AuthorizedCallerAdded(msg.sender);
        emit OwnershipTransferred(address(0), msg.sender);
    }

    // ========= MODIFIERS ========= //

    /// @notice Modifier to restrict function access to authorized callers
    modifier onlyAuthorized() {
        if (!authorizedCallers[msg.sender]) revert BuybackCooldownManager_NotAuthorized();
        _;
    }

    /// @notice Modifier to restrict function access to the owner
    modifier onlyOwner() {
        if (msg.sender != owner) revert BuybackCooldownManager_OnlyOwner();
        _;
    }

    // ========= EXTERNAL FUNCTIONS ========= //

    /// @inheritdoc IBuybackCooldownManager
    function canExecuteBuyback() external view returns (bool) {
        if (lastBuybackTimestamp == 0) return true;
        return block.timestamp >= lastBuybackTimestamp + cooldownPeriod;
    }

    /// @inheritdoc IBuybackCooldownManager
    function recordBuyback() external onlyAuthorized {
        if (lastBuybackTimestamp != 0 && block.timestamp < lastBuybackTimestamp + cooldownPeriod) {
            revert BuybackCooldownManager_InCooldownPeriod();
        }
        
        lastBuybackTimestamp = block.timestamp;
        emit BuybackRecorded(block.timestamp);
    }

    /// @inheritdoc IBuybackCooldownManager
    function getLastBuybackTimestamp() external view returns (uint256) {
        return lastBuybackTimestamp;
    }

    /// @inheritdoc IBuybackCooldownManager
    function getCooldownPeriod() external view returns (uint256) {
        return cooldownPeriod;
    }

    /// @inheritdoc IBuybackCooldownManager
    function getRemainingCooldown() external view returns (uint256) {
        if (lastBuybackTimestamp == 0) return 0;
        
        uint256 elapsedTime = block.timestamp - lastBuybackTimestamp;
        if (elapsedTime >= cooldownPeriod) return 0;
        
        return cooldownPeriod - elapsedTime;
    }

    /// @inheritdoc IBuybackCooldownManager
    function setCooldownPeriod(uint256 newCooldownPeriod) external onlyOwner {
        if (newCooldownPeriod == 0) revert BuybackCooldownManager_InvalidCooldownPeriod();
        
        uint256 oldCooldownPeriod = cooldownPeriod;
        cooldownPeriod = newCooldownPeriod;
        
        emit CooldownPeriodUpdated(oldCooldownPeriod, newCooldownPeriod);
    }

    /// @inheritdoc IBuybackCooldownManager
    function addAuthorizedCaller(address caller) external onlyOwner {
        if (authorizedCallers[caller]) revert BuybackCooldownManager_AlreadyAuthorized();
        
        authorizedCallers[caller] = true;
        emit AuthorizedCallerAdded(caller);
    }

    /// @inheritdoc IBuybackCooldownManager
    function removeAuthorizedCaller(address caller) external onlyOwner {
        if (!authorizedCallers[caller]) revert BuybackCooldownManager_NotCurrentlyAuthorized();
        if (caller == owner) revert BuybackCooldownManager_NotAuthorized(); // Owner cannot remove themselves
        
        authorizedCallers[caller] = false;
        emit AuthorizedCallerRemoved(caller);
    }

    /// @inheritdoc IBuybackCooldownManager
    function isAuthorizedCaller(address caller) external view returns (bool) {
        return authorizedCallers[caller];
    }

    /// @inheritdoc IBuybackCooldownManager
    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert BuybackCooldownManager_NotAuthorized();
        
        address oldOwner = owner;
        owner = newOwner;
        
        // Ensure the new owner is an authorized caller
        if (!authorizedCallers[newOwner]) {
            authorizedCallers[newOwner] = true;
            emit AuthorizedCallerAdded(newOwner);
        }
        
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}