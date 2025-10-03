// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.15;

/// @title Buyback Router Executor
/// @notice Executes buyback orders on AMM DEXes like Uniswap
interface IBuybackRouterExecutor {
    function executeSwap(uint256 amountIn, uint256 minAmountOut) external returns (uint256 amountOut);
    function getExpectedOutput(uint256 amountIn) external view returns (uint256);
    function getOptimalPath() external view returns (address[] memory);
}

import "@openzeppelin/contracts/access/Ownable.sol";

interface IRouter {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    
    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract BuybackRouterExecutor is Ownable {
    // ============================================================================================//
    //                                        EVENTS                                                 //
    // ============================================================================================//

    event SwapExecuted(uint256 amountIn, uint256 amountOut, address[] path, uint256 timestamp);
    event SwapFailed(uint256 amountIn, string reason, uint256 timestamp);
    event RouterUpdated(address oldRouter, address newRouter);
    event PathUpdated(address[] oldPath, address[] newPath);
    event SlippageToleranceUpdated(uint256 oldTolerance, uint256 newTolerance);

    // ============================================================================================//
    //                                        ERRORS                                                //
    // ============================================================================================//

    error BuybackRouterExecutor_InvalidAmount();
    error BuybackRouterExecutor_InvalidAddress();
    error BuybackRouterExecutor_InvalidPath();
    error BuybackRouterExecutor_RouterCallFailed();
    error BuybackRouterExecutor_InsufficientOutput();
    error BuybackRouterExecutor_Unauthorized();

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//
    
    // Router for executing swaps
    IRouter public router;
    
    // Default swap path
    address[] public path;
    
    // Treasury address
    address public treasury;
    
    // Slippage tolerance (in basis points, e.g., 100 = 1%)
    uint256 public slippageTolerance;
    
    // Maximum slippage tolerance (in basis points)
    uint256 public constant MAX_SLIPPAGE_TOLERANCE = 1000; // 10%
    
    // Swap deadline (in seconds)
    uint256 public constant SWAP_DEADLINE = 300; // 5 minutes
    
    // Owner of the contract

    
    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(
        address initialOwner,
        address _router,
        address[] memory _path,
        address _treasury,
        uint256 _slippageTolerance
    ) Ownable(initialOwner) {
        if (_router == address(0) || _treasury == address(0)) {
            revert BuybackRouterExecutor_InvalidAddress();
        }
        
        if (_path.length < 2) {
            revert BuybackRouterExecutor_InvalidPath();
        }
        
        if (_slippageTolerance == 0 || _slippageTolerance > MAX_SLIPPAGE_TOLERANCE) {
            revert BuybackRouterExecutor_InvalidAmount();
        }
        
        router = IRouter(_router);
        path = _path;
        treasury = _treasury;
        slippageTolerance = _slippageTolerance;

    }
    
    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyOwner() override {
        if (msg.sender != owner()) {
            revert BuybackRouterExecutor_Unauthorized();
        }
        _;
    }
    
    // ============================================================================================//
    //                                       FUNCTIONS                                             //
    // ============================================================================================//

    /// @notice Execute a swap on the AMM DEX
    /// @param amountIn The amount of input tokens to swap
    /// @param minAmountOut The minimum amount of output tokens to receive
    /// @return amountOut The amount of output tokens received
    function executeSwap(uint256 amountIn, uint256 minAmountOut) external returns (uint256 amountOut) {
        // Check if amount is valid
        if (amountIn == 0) {
            revert BuybackRouterExecutor_InvalidAmount();
        }
        
        // Check if path is valid
        if (path.length < 2) {
            revert BuybackRouterExecutor_InvalidPath();
        }
        
        // Get input token
        IERC20 inputToken = IERC20(path[0]);
        
        // Get output token
        IERC20 outputToken = IERC20(path[path.length - 1]);
        
        // Check output token balance before swap
        uint256 balanceBefore = outputToken.balanceOf(address(this));
        
        // Transfer input tokens from treasury to this contract
        bool transferSuccess = inputToken.transferFrom(treasury, address(this), amountIn);
        if (!transferSuccess) {
            emit SwapFailed(amountIn, "Transfer from treasury failed", block.timestamp);
            return 0;
        }
        
        // Approve router to spend input tokens
        inputToken.approve(address(router), amountIn);
        
        // Execute swap
        try router.swapExactTokensForTokens(
            amountIn,
            minAmountOut,
            path,
            address(this),
            block.timestamp + SWAP_DEADLINE
        ) returns (uint256[] memory amounts) {
            // Check output token balance after swap
            uint256 balanceAfter = outputToken.balanceOf(address(this));
            amountOut = balanceAfter - balanceBefore;
            
            // Check if output amount is sufficient
            if (amountOut < minAmountOut) {
                revert BuybackRouterExecutor_InsufficientOutput();
            }
            
            // Transfer output tokens to treasury
            outputToken.transfer(treasury, amountOut);
            
            emit SwapExecuted(amountIn, amountOut, path, block.timestamp);
            
            return amountOut;
        } catch {
            emit SwapFailed(amountIn, "Router swap failed", block.timestamp);
            
            // Return any unused input tokens to treasury
            uint256 remainingBalance = inputToken.balanceOf(address(this));
            if (remainingBalance > 0) {
                inputToken.transfer(treasury, remainingBalance);
            }
            
            return 0;
        }
    }
    
    /// @notice Get the expected output amount for a given input amount
    /// @param amountIn The amount of input tokens
    /// @return The expected amount of output tokens
    function getExpectedOutput(uint256 amountIn) external view returns (uint256) {
        if (amountIn == 0) {
            return 0;
        }
        
        if (path.length < 2) {
            return 0;
        }
        
        try router.getAmountsOut(amountIn, path) returns (uint256[] memory amounts) {
            return amounts[amounts.length - 1];
        } catch {
            return 0;
        }
    }
    
    /// @notice Calculate the minimum output amount based on expected output and slippage tolerance
    /// @param expectedOutput The expected output amount
    /// @return The minimum output amount
    function calculateMinOutput(uint256 expectedOutput) public view returns (uint256) {
        return (expectedOutput * (10000 - slippageTolerance)) / 10000;
    }
    
    /// @notice Get the optimal path for the swap
    /// @return The optimal path as an array of token addresses
    function getOptimalPath() external view returns (address[] memory) {
        return path;
    }
    
    /// @notice Set the router address
    /// @param _router The new router address
    function setRouter(address _router) external onlyOwner {
        if (_router == address(0)) {
            revert BuybackRouterExecutor_InvalidAddress();
        }
        
        address oldRouter = address(router);
        router = IRouter(_router);
        
        emit RouterUpdated(oldRouter, _router);
    }
    
    /// @notice Set the swap path
    /// @param _path The new swap path
    function setPath(address[] calldata _path) external onlyOwner {
        if (_path.length < 2) {
            revert BuybackRouterExecutor_InvalidPath();
        }
        
        address[] memory oldPath = path;
        path = _path;
        
        emit PathUpdated(oldPath, _path);
    }
    
    /// @notice Set the slippage tolerance
    /// @param _slippageTolerance The new slippage tolerance in basis points
    function setSlippageTolerance(uint256 _slippageTolerance) external onlyOwner {
        if (_slippageTolerance == 0 || _slippageTolerance > MAX_SLIPPAGE_TOLERANCE) {
            revert BuybackRouterExecutor_InvalidAmount();
        }
        
        uint256 oldTolerance = slippageTolerance;
        slippageTolerance = _slippageTolerance;
        
        emit SlippageToleranceUpdated(oldTolerance, _slippageTolerance);
    }
    
    /// @notice Set the treasury address
    /// @param _treasury The new treasury address
    function setTreasury(address _treasury) external onlyOwner {
        if (_treasury == address(0)) {
            revert BuybackRouterExecutor_InvalidAddress();
        }
        
        treasury = _treasury;
    }
    
    /// @notice Transfer ownership of the contract
    /// @param newOwner The address of the new owner
    function transferOwnership(address newOwner) public override onlyOwner {
        super.transferOwnership(newOwner);
    }
}