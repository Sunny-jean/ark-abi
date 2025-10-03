// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface YieldAggregator {
    /**
     * @dev Emitted when funds are deposited into the yield aggregator.
     * @param asset The address of the deposited asset.
     * @param user The address of the user who deposited.
     * @param amount The amount deposited.
     */
    event Deposited(address indexed asset, address indexed user, uint256 amount);

    /**
     * @dev Emitted when funds are withdrawn from the yield aggregator.
     * @param asset The address of the withdrawn asset.
     * @param user The address of the user who withdrew.
     * @param amount The amount withdrawn.
     */
    event Withdrew(address indexed asset, address indexed user, uint256 amount);

    /**
     * @dev Emitted when profits are harvested from a strategy.
     * @param strategy The address of the strategy.
     * @param profit The amount of profit harvested.
     */
    event Harvested(address indexed strategy, uint256 profit);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a required parameter is missing or invalid.
     */
    error InvalidParameter(string parameterName, string description);

    /**
     * @dev Thrown when an unsupported asset is used.
     */
    error UnsupportedAsset(address asset);

    /**
     * @dev Thrown when the deposit amount is zero.
     */
    error ZeroDepositAmount();

    /**
     * @dev Thrown when the withdrawal amount exceeds the available balance.
     */
    error InsufficientFunds(uint256 available, uint256 requested);

    /**
     * @dev Thrown when a strategy is not found or not active.
     */
    error StrategyNotFound(address strategy);

    /**
     * @dev Deposits `amount` of `asset` into the yield aggregator.
     * @param asset The address of the asset to deposit.
     * @param amount The amount to deposit.
     */
    function deposit(address asset, uint256 amount) external;

    /**
     * @dev Withdraws `amount` of `asset` from the yield aggregator.
     * @param asset The address of the asset to withdraw.
     * @param amount The amount to withdraw.
     * @return actualAmount The actual amount withdrawn.
     */
    function withdraw(address asset, uint256 amount) external returns (uint256 actualAmount);

    /**
     * @dev Adds a new yield farming strategy.
     * @param strategyAddress The address of the new strategy contract.
     */
    function addStrategy(address strategyAddress) external;

    /**
     * @dev Removes an existing yield farming strategy.
     * @param strategyAddress The address of the strategy contract to remove.
     */
    function removeStrategy(address strategyAddress) external;

    /**
     * @dev Harvests profits from a specific strategy.
     * @param strategyAddress The address of the strategy to harvest from.
     */
    function harvest(address strategyAddress) external;

    /**
     * @dev Returns the total value locked (TVL) for a given asset.
     * @param asset The address of the asset.
     * @return tvl The total value locked.
     */
    function getTotalValueLocked(address asset) external view returns (uint256 tvl);

    /**
     * @dev Returns the current APY for a given asset.
     * @param asset The address of the asset.
     * @return apy The annual percentage yield.
     */
    function getAPY(address asset) external view returns (uint256 apy);
}