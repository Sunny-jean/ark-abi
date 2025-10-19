// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICrossChainGovernanceBridge {
    function sendMessage(uint256 _chainId, bytes calldata _message) external;
    function receiveMessage(uint256 _chainId, bytes calldata _message) external;
    function setBridgeAddress(uint256 _chainId, address _bridgeAddress) external;

    event MessageSent(uint256 indexed chainId, bytes message);
    event MessageReceived(uint256 indexed chainId, bytes message);
    event BridgeAddressSet(uint256 indexed chainId, address bridgeAddress);

    error InvalidChainId();
    error MessageProcessingFailed();
}