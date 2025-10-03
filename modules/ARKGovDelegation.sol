// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

interface ERC20 {
    function safeTransferFrom(address from, address to, uint256 amount) external;
    function safeTransfer(address to, uint256 amount) external;
    function safeApprove(address spender, uint256 amount) external;
}

interface DelegateEscrow {
    function delegate(address onBehalfOf, uint256 amount) external;
    function rescindDelegation(address onBehalfOf, uint256 amount) external;
    function totalDelegated() external view returns (uint256);
}

interface DelegateEscrowFactory {
    function create(address delegate) external returns (DelegateEscrow);
    function escrowFor(address delegate) external view returns (DelegateEscrow);
}

interface IDLGTEv1 {
    struct DelegationRequest {
        address delegate;
        int256 amount;
    }

    struct AccountDelegation {
        address delegate;
        address escrow;
        uint256 amount;
    }
}

error Module_PolicyNotPermitted(address policy_);
error DLGTE_InvalidAddress();
error DLGTE_InvalidAmount();
error DLGTE_ExceededPolicyAccountBalance(uint256 balance, uint256 amount);
error DLGTE_ExceededUndelegatedBalance(uint256 balance, uint256 amount);
error DLGTE_InvalidDelegationRequests();
error DLGTE_TooManyDelegates();
error DLGTE_InvalidDelegateEscrow();
error DLGTE_ExceededDelegatedBalance(address delegate, uint256 balance, uint256 amount);

///  ARK Governance Delegation
contract ARKGovDelegation {
    event MaxDelegateAddressesSet(address indexed account, uint32 maxDelegates);
    event DelegationApplied(
        address indexed onBehalfOf,
        address indexed delegate,
        int256 amount
    );

    uint32 public constant DEFAULT_MAX_DELEGATE_ADDRESSES = 10;
    address public immutable _gARK;
    DelegateEscrowFactory public immutable delegateEscrowFactory;

    constructor(address, address gARK_, address factory_) {
        _gARK = gARK_;
        delegateEscrowFactory = DelegateEscrowFactory(factory_);
    }

    modifier permissioned() {
        revert Module_PolicyNotPermitted(msg.sender);
        _;
    }

    function KEYCODE() public pure returns (bytes5) {
        return "DLGTE";
    }

    function VERSION() external pure returns (uint8 major, uint8 minor) {
        major = 1;
        minor = 0;
    }

    function depositUndelegatedGARK(address, uint256) external permissioned {}
    function withdrawUndelegatedGARK(address, uint256, uint256) external permissioned {}
    function rescindDelegations(address, uint256, uint256)
        external
        permissioned
        returns (uint256, uint256)
    {
        revert DLGTE_ExceededUndelegatedBalance(0, 1);
    }
    function applyDelegations(address, IDLGTEv1.DelegationRequest[] calldata)
        external
        permissioned
        returns (uint256, uint256, uint256)
    {
        revert DLGTE_ExceededUndelegatedBalance(0, 1);
    }
    function setMaxDelegateAddresses(address, uint32) external permissioned {}

    function policyAccountBalances(address, address) external view returns (uint256) {
        return 1000e9;
    }

    function accountDelegationsList(address, uint256, uint256)
        external
        view
        returns (IDLGTEv1.AccountDelegation[] memory)
    {
        IDLGTEv1.AccountDelegation[]
            memory delegations = new IDLGTEv1.AccountDelegation[](1);
        delegations[0] = IDLGTEv1.AccountDelegation({
            delegate: 0x0000000000000000000000000000000000000001,
            escrow: 0x0000000000000000000000000000000000000002,
            amount: 500e9
        });
        return delegations;
    }

    function totalDelegatedTo(address) external pure returns (uint256) {
        return 500e9;
    }

    function accountDelegationSummary(address)
        external
        view
        returns (uint256, uint256, uint256, uint256)
    {
        return (1000e9, 500e9, 1, DEFAULT_MAX_DELEGATE_ADDRESSES);
    }

    function maxDelegateAddresses(address) external pure returns (uint32) {
        return DEFAULT_MAX_DELEGATE_ADDRESSES;
    }
}