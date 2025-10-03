// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.15;

/// @title Buyback Backtest Recorder
/// @notice Records historical buyback actions and results for analysis
interface IBuybackBacktestRecorder {
    function recordBuyback(uint256 amount, uint256 tokensBought, uint256 price, bool success) external;
    function getBuybackCount() external view returns (uint256);
    function getBuybackAtIndex(uint256 index) external view returns (uint256 timestamp, uint256 amount, uint256 tokensBought, uint256 price, bool success);
    function getRecentBuybacks(uint256 count) external view returns (uint256[] memory timestamps, uint256[] memory amounts, uint256[] memory tokensBought, uint256[] memory prices, bool[] memory successes);
}

contract BuybackBacktestRecorder {
    // ============================================================================================//
    //                                        EVENTS                                                 //
    // ============================================================================================//

    event BuybackRecorded(uint256 indexed index, uint256 timestamp, uint256 amount, uint256 tokensBought, uint256 price, bool success);
    event HistoricalDataCleared();

    // ============================================================================================//
    //                                        ERRORS                                                //
    // ============================================================================================//

    error BuybackBacktestRecorder_InvalidIndex();
    error BuybackBacktestRecorder_InvalidCount();
    error BuybackBacktestRecorder_Unauthorized();

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    // Struct to store buyback data
    struct BuybackData {
        uint256 timestamp;
        uint256 amount;
        uint256 tokensBought;
        uint256 price; // Price in reserve tokens per protocol token (scaled by 1e18)
        bool success;
    }
    
    // Array of buyback data
    BuybackData[] public buybacks;
    
    // Maximum number of buybacks to store
    uint256 public constant MAX_BUYBACKS = 1000;
    
    // Owner of the contract
    address public owner;
    
    // Authorized recorders who can record buybacks
    mapping(address => bool) public authorizedRecorders;
    
    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor() {
        owner = msg.sender;
        authorizedRecorders[msg.sender] = true;
    }
    
    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert BuybackBacktestRecorder_Unauthorized();
        }
        _;
    }
    
    modifier onlyAuthorized() {
        if (!authorizedRecorders[msg.sender]) {
            revert BuybackBacktestRecorder_Unauthorized();
        }
        _;
    }
    
    // ============================================================================================//
    //                                       FUNCTIONS                                             //
    // ============================================================================================//

    /// @notice Record a buyback action and its result
    /// @param amount The amount of reserve tokens used
    /// @param tokensBought The amount of protocol tokens bought
    /// @param price The price in reserve tokens per protocol token (scaled by 1e18)
    /// @param success Whether the buyback was successful
    function recordBuyback(uint256 amount, uint256 tokensBought, uint256 price, bool success) external onlyAuthorized {
        // If we've reached the maximum, remove the oldest entry
        if (buybacks.length >= MAX_BUYBACKS) {
            // Shift all elements one position to the left
            for (uint256 i = 0; i < buybacks.length - 1; i++) {
                buybacks[i] = buybacks[i + 1];
            }
            // Resize the array
            buybacks.pop();
        }
        
        // Add the new buyback data
        buybacks.push(BuybackData({
            timestamp: block.timestamp,
            amount: amount,
            tokensBought: tokensBought,
            price: price,
            success: success
        }));
        
        emit BuybackRecorded(buybacks.length - 1, block.timestamp, amount, tokensBought, price, success);
    }
    
    /// @notice Get the total number of recorded buybacks
    /// @return The number of buybacks
    function getBuybackCount() external view returns (uint256) {
        return buybacks.length;
    }
    
    /// @notice Get buyback data at a specific index
    /// @param index The index of the buyback
    /// @return timestamp The timestamp of the buyback
    /// @return amount The amount of reserve tokens used
    /// @return tokensBought The amount of protocol tokens bought
    /// @return price The price in reserve tokens per protocol token
    /// @return success Whether the buyback was successful
    function getBuybackAtIndex(uint256 index) external view returns (uint256 timestamp, uint256 amount, uint256 tokensBought, uint256 price, bool success) {
        if (index >= buybacks.length) {
            revert BuybackBacktestRecorder_InvalidIndex();
        }
        
        BuybackData memory data = buybacks[index];
        return (data.timestamp, data.amount, data.tokensBought, data.price, data.success);
    }
    
    /// @notice Get the most recent buybacks
    /// @param count The number of recent buybacks to retrieve
    /// @return timestamps The timestamps of the buybacks
    /// @return amounts The amounts of reserve tokens used
    /// @return tokensBought The amounts of protocol tokens bought
    /// @return prices The prices in reserve tokens per protocol token
    /// @return successes Whether the buybacks were successful
    function getRecentBuybacks(uint256 count) external view returns (uint256[] memory timestamps, uint256[] memory amounts, uint256[] memory tokensBought, uint256[] memory prices, bool[] memory successes) {
        if (count == 0 || count > buybacks.length) {
            revert BuybackBacktestRecorder_InvalidCount();
        }
        
        timestamps = new uint256[](count);
        amounts = new uint256[](count);
        tokensBought = new uint256[](count);
        prices = new uint256[](count);
        successes = new bool[](count);
        
        uint256 startIndex = buybacks.length - count;
        
        for (uint256 i = 0; i < count; i++) {
            BuybackData memory data = buybacks[startIndex + i];
            timestamps[i] = data.timestamp;
            amounts[i] = data.amount;
            tokensBought[i] = data.tokensBought;
            prices[i] = data.price;
            successes[i] = data.success;
        }
        
        return (timestamps, amounts, tokensBought, prices, successes);
    }
    
    /// @notice Get buybacks within a specific time range
    /// @param startTime The start timestamp of the range
    /// @param endTime The end timestamp of the range
    /// @return count The number of buybacks in the range
    function getBuybacksInTimeRange(uint256 startTime, uint256 endTime) external view returns (uint256 count) {
        for (uint256 i = 0; i < buybacks.length; i++) {
            if (buybacks[i].timestamp >= startTime && buybacks[i].timestamp <= endTime) {
                count++;
            }
        }
        return count;
    }
    
    /// @notice Calculate the average price of successful buybacks
    /// @param count The number of recent buybacks to consider
    /// @return avgPrice The average price
    function getAveragePrice(uint256 count) external view returns (uint256 avgPrice) {
        if (count == 0 || count > buybacks.length) {
            revert BuybackBacktestRecorder_InvalidCount();
        }
        
        uint256 startIndex = buybacks.length - count;
        uint256 totalPrice = 0;
        uint256 successCount = 0;
        
        for (uint256 i = 0; i < count; i++) {
            BuybackData memory data = buybacks[startIndex + i];
            if (data.success && data.tokensBought > 0) {
                totalPrice += data.price;
                successCount++;
            }
        }
        
        if (successCount > 0) {
            avgPrice = totalPrice / successCount;
        }
        
        return avgPrice;
    }
    
    /// @notice Calculate the total amount spent on buybacks
    /// @param count The number of recent buybacks to consider
    /// @return totalAmount The total amount spent
    function getTotalAmountSpent(uint256 count) external view returns (uint256 totalAmount) {
        if (count == 0 || count > buybacks.length) {
            revert BuybackBacktestRecorder_InvalidCount();
        }
        
        uint256 startIndex = buybacks.length - count;
        
        for (uint256 i = 0; i < count; i++) {
            BuybackData memory data = buybacks[startIndex + i];
            if (data.success) {
                totalAmount += data.amount;
            }
        }
        
        return totalAmount;
    }
    
    /// @notice Calculate the total tokens bought in buybacks
    /// @param count The number of recent buybacks to consider
    /// @return totalTokens The total tokens bought
    function getTotalTokensBought(uint256 count) external view returns (uint256 totalTokens) {
        if (count == 0 || count > buybacks.length) {
            revert BuybackBacktestRecorder_InvalidCount();
        }
        
        uint256 startIndex = buybacks.length - count;
        
        for (uint256 i = 0; i < count; i++) {
            BuybackData memory data = buybacks[startIndex + i];
            if (data.success) {
                totalTokens += data.tokensBought;
            }
        }
        
        return totalTokens;
    }
    
    /// @notice Calculate the success rate of buybacks
    /// @param count The number of recent buybacks to consider
    /// @return successRate The success rate in basis points (e.g., 8500 = 85%)
    function getSuccessRate(uint256 count) external view returns (uint256 successRate) {
        if (count == 0 || count > buybacks.length) {
            revert BuybackBacktestRecorder_InvalidCount();
        }
        
        uint256 startIndex = buybacks.length - count;
        uint256 successCount = 0;
        
        for (uint256 i = 0; i < count; i++) {
            if (buybacks[startIndex + i].success) {
                successCount++;
            }
        }
        
        successRate = (successCount * 10000) / count;
        
        return successRate;
    }
    
    /// @notice Clear all historical buyback data
    function clearHistory() external onlyOwner {
        delete buybacks;
        
        emit HistoricalDataCleared();
    }
    
    /// @notice Add an authorized recorder
    /// @param recorder The address to authorize
    function addAuthorizedRecorder(address recorder) external onlyOwner {
        authorizedRecorders[recorder] = true;
    }
    
    /// @notice Remove an authorized recorder
    /// @param recorder The address to remove authorization from
    function removeAuthorizedRecorder(address recorder) external onlyOwner {
        authorizedRecorders[recorder] = false;
    }
    
    /// @notice Transfer ownership of the contract
    /// @param newOwner The address of the new owner
    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) {
            revert BuybackBacktestRecorder_Unauthorized();
        }
        
        owner = newOwner;
    }
}