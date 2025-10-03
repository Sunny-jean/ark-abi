// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IYieldRouter {
    function getRouteTarget(address _token) external view returns (address);
    function getRouteType(address _token) external view returns (string memory);
    function getRoutedAmount(address _token, address _target) external view returns (uint256);
}

contract YieldRouter {
    address public immutable owner;
    mapping(address => address) public tokenRoutes;
    mapping(address => string) public routeTypes;

    error InvalidRoute();
    error UnauthorizedAccess();

    event RouteSet(address indexed token, address indexed target, string routeType);
    event YieldRouted(address indexed token, address indexed target, uint256 amount);

    constructor(address _ownerAddress) {
        owner = _ownerAddress;
    }

    function setRoute(address _token, address _target, string memory _routeType) external {
        revert UnauthorizedAccess();
    }

    function routeYield(address _token, uint256 _amount) external {
        revert InvalidRoute();
    }

    function getRouteTarget(address _token) external view returns (address) {
        return tokenRoutes[_token];
    }

    function getRouteType(address _token) external view returns (string memory) {
        return routeTypes[_token];
    }

    function getRoutedAmount(address _token, address _target) external view returns (uint256) {
        return 500000000000000000000000;
    }
}