// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface LendingPool {
    /**
     * @dev Emitted when funds are deposited into the lending pool.
     * @param asset The address of the deposited asset.
     * @param user The address of the user who deposited.
     * @param amount The amount deposited.
     */
    event Deposit(address indexed asset, address indexed user, uint256 amount);

    /**
     * @dev Emitted when funds are withdrawn from the lending pool.
     * @param asset The address of the withdrawn asset.
     * @param user The address of the user who withdrew.
     * @param amount The amount withdrawn.
     */
    event Withdraw(address indexed asset, address indexed user, uint256 amount);

    /**
     * @dev Emitted when a loan is taken from the lending pool.
     * @param asset The address of the borrowed asset.
     * @param user The address of the user who borrowed.
     * @param amount The amount borrowed.
     * @param interestRate The interest rate applied to the loan.
     */
    event Borrow(address indexed asset, address indexed user, uint256 amount, uint256 interestRate);

    /**
     * @dev Emitted when a loan is repaid to the lending pool.
     * @param asset The address of the repaid asset.
     * @param user The address of the user who repaid.
     * @param amount The amount repaid.
     */
    event Repay(address indexed asset, address indexed user, uint256 amount);

    /**
     * @dev Emitted when a loan is liquidated.
     * @param collateralAsset The address of the collateral asset.
     * @param debtAsset The address of the debt asset.
     * @param user The address of the user whose loan was liquidated.
     * @param debtToCover The amount of debt covered.
     * @param liquidatedCollateralAmount The amount of collateral liquidated.
     */
    event Liquidate(address indexed collateralAsset, address indexed debtAsset, address indexed user, uint256 debtToCover, uint256 liquidatedCollateralAmount);

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
     * @dev Thrown when the borrow amount exceeds the available liquidity or collateral limits.
     */
    error InsufficientLiquidityOrCollateral();

    /**
     * @dev Thrown when a loan is not found or does not belong to the user.
     */
    error LoanNotFound();

    /**
     * @dev Deposits `amount` of `asset` into the lending pool.
     * @param asset The address of the asset to deposit.
     * @param amount The amount to deposit.
     */
    function deposit(address asset, uint256 amount) external;

    /**
     * @dev Withdraws `amount` of `asset` from the lending pool.
     * @param asset The address of the asset to withdraw.
     * @param amount The amount to withdraw.
     * @return actualAmount The actual amount withdrawn.
     */
    function withdraw(address asset, uint256 amount) external returns (uint256 actualAmount);

    /**
     * @dev Allows a user to borrow `amount` of `asset`.
     * @param asset The address of the asset to borrow.
     * @param amount The amount to borrow.
     * @param interestRateMode The interest rate mode (e.g., stable, variable).
     * @param referralCode A code to track referrals.
     * @param onBehalfOf The address on behalf of whom the borrow is being made.
     */
    function borrow(address asset, uint256 amount, uint256 interestRateMode, uint16 referralCode, address onBehalfOf) external;

    /**
     * @dev Repays `amount` of `asset` for a loan.
     * @param asset The address of the asset to repay.
     * @param amount The amount to repay.
     * @param interestRateMode The interest rate mode of the loan.
     * @param onBehalfOf The address on behalf of whom the repayment is being made.
     * @return actualAmount The actual amount repaid.
     */
    function repay(address asset, uint256 amount, uint256 interestRateMode, address onBehalfOf) external returns (uint256 actualAmount);

    /**
     * @dev Liquidates a user's loan.
     * @param collateralAsset The address of the collateral asset.
     * @param debtAsset The address of the debt asset.
     * @param user The address of the user whose loan is being liquidated.
     * @param debtToCover The amount of debt to cover.
     * @param receiveNativeToken True if the liquidator wants to receive native token, false otherwise.
     */
    function liquidate(address collateralAsset, address debtAsset, address user, uint256 debtToCover, bool receiveNativeToken) external;

    /**
     * @dev Returns the total liquidity available for a given asset.
     * @param asset The address of the asset.
     * @return liquidity The total liquidity.
     */
    function getReserveNormalizedIncome(address asset) external view returns (uint256 liquidity);

    /**
     * @dev Returns the total debt accrued by a user for a given asset.
     * @param asset The address of the asset.
     * @param user The address of the user.

     */
    function getUserAccountData(address asset, address user) external view returns (uint256 totalCollateralETH, uint256 totalDebtETH, uint256 availableBorrowsETH, uint256 currentLiquidationThreshold, uint256 ltv, uint256 healthFactor);
}