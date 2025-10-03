// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ILendingRouter {
    // 借款/還款/提款/補倉調用路由
    function routeBorrow(address _asset, uint256 _amount) external;
    function routeRepay(address _asset, uint256 _amount) external;
    function routeWithdraw(address _asset, uint256 _amount) external;
    function routeTopUp(address _asset, uint256 _amount) external;

    event BorrowRouted(address indexed user, address indexed asset, uint256 amount);
    event RepayRouted(address indexed user, address indexed asset, uint256 amount);
    event WithdrawRouted(address indexed user, address indexed asset, uint256 amount);
    event TopUpRouted(address indexed user, address indexed asset, uint256 amount);

    error RoutingFailed();
}