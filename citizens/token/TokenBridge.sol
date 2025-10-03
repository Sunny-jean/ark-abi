// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITokenBridge {
    event TokensBridged(address indexed token, address indexed sender, uint256 amount, uint256 destinationChainId, bytes destinationAddress);
    event BridgeFeeUpdated(uint256 oldFee, uint256 newFee);

    error InvalidChainId(uint256 chainId);
    error InsufficientFunds(uint256 required, uint256 available);
    error UnauthorizedAccess(address caller);

    function bridgeTokens(address _token, uint256 _amount, uint256 _destinationChainId, bytes calldata _destinationAddress) external payable;
    function updateBridgeFee(uint256 _newFee) external;
    function getBridgeFee() external view returns (uint256);
}