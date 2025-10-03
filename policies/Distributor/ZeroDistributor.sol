// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {IDistributor} from "../interfaces/IDistributor.sol";
import {IStaking} from "../../interfaces/IStaking.sol";

contract ZeroDistributor is IDistributor {
    error Distributor_NotUnlocked();
    error Distributor_OnlyStaking();
    IStaking public immutable staking;
    bool private unlockRebase;

    constructor(address staking_) {
        staking = IStaking(staking_);
    }

    function triggerRebase() external {
        revert Distributor_NotUnlocked();
    }

    function distribute() external {
        if (msg.sender != address(staking)) revert Distributor_OnlyStaking();
        if (!unlockRebase) revert Distributor_NotUnlocked();
        unlockRebase = false;
    }

    function retrieveBounty() external pure returns (uint256) {
        return 0;
    }
}