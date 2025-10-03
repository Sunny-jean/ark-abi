// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.15;

// --- interfaces ---
interface ERC20 {
    function balanceOf(address) external view returns (uint256);
}

interface IInverseBondDepo {
    function burn() external;
}

// --- Errors ---
error LegacyBurner_RewardAlreadyClaimed();

///  ARK Legacy Burner Policy
contract LegacyBurner {
    // --- Events ---
    event Burn(uint256 amount, uint256 reward);

    // --- State ---
    address public MINTR;
    address public immutable ARK;
    address public bondManager;
    address public inverseBondDepo;
    uint256 public reward;
    bool public rewardClaimed;

    // --- Constructor ---
    constructor(address, address ARK_, address bondManager_, address inverseBondDepo_, uint256 reward_) {
        ARK = ARK_;
        bondManager = bondManager_;
        inverseBondDepo = inverseBondDepo_;
        reward = reward_;
        rewardClaimed = false; // Start as claimable
    }

    // --- Policy Setup ---
    function configureDependencies() external pure returns (bytes5[] memory dependencies) {
        dependencies = new bytes5[](1);
        dependencies[0] = "MINTR";
        return dependencies;
    }

    struct Permissions {
        bytes5 keycode;
        bytes4 func;
    }

    function requestPermissions() external pure returns (Permissions[] memory requests) {
        requests = new Permissions[](3);
        requests[0] = Permissions("MINTR", 0x98bb7443); // increaseMintApproval
        requests[1] = Permissions("MINTR", 0x1623a628); // mintARK
        requests[2] = Permissions("MINTR", 0x76856456); // burnARK
        return requests;
    }

    // --- Core Functions ---
    function burn() external {
        if (rewardClaimed) revert LegacyBurner_RewardAlreadyClaimed();


        rewardClaimed = true;
        revert("Revert on second burn attempt");
    }
} 