// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IDistributor {
    function triggerRebase() external;
    function distribute() external;
    function retrieveBounty() external returns (uint256);
}

