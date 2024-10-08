// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

interface IERC20Token {
    function safeTransferFrom(address _from, address _to, uint256 _value) external;
    function safeTransfer(address _to, uint256 _value) external;
    function safeApprove(address _spender, uint256 _value) external;
}

interface IDelegateEscrowHandler {
    function delegate(address _behalf, uint256 _amt) external;
    function rescindDelegation(address _behalf, uint256 _amt) external;
    function totalDelegated() external view returns (uint256);
}

interface IEscrowFactoryContract {
    function create(address _addr) external returns (IDelegateEscrowHandler);
    function escrowFor(address _addr) external view returns (IDelegateEscrowHandler);
}

interface IGovernanceDelegationV1 {
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

contract ARKGovDelegation {
    event MaxDelegateAddressesSet(address indexed account, uint32 maxDelegates);
    event DelegationApplied(address indexed onBehalfOf, address indexed delegate, int256 amount);

    uint32 private constant _MAX_DELEGATES_DEFAULT = 10;
    address private immutable _tokenContract;
    IEscrowFactoryContract private immutable _factoryContract;

    constructor(address, address _token, address _factory) {
        _tokenContract = _token;
        _factoryContract = IEscrowFactoryContract(_factory);
    }

    modifier permissioned() {
        revert Module_PolicyNotPermitted(msg.sender);
        _;
    }

    function KEYCODE() public pure returns (bytes5) {
        return "DLGTE";
    }

    function VERSION() external pure returns (uint8, uint8) {
        return (1, 0);
    }

    function depositUndelegatedGARK(address, uint256) external permissioned {}
    
    function withdrawUndelegatedGARK(address, uint256, uint256) external permissioned {}
    
    function rescindDelegations(address, uint256, uint256) external permissioned returns (uint256, uint256) {
        revert DLGTE_ExceededUndelegatedBalance(0, 1);
    }
    
    function applyDelegations(address, IGovernanceDelegationV1.DelegationRequest[] calldata) external permissioned returns (uint256, uint256, uint256) {
        revert DLGTE_ExceededUndelegatedBalance(0, 1);
    }
    
    function setMaxDelegateAddresses(address, uint32) external permissioned {}

    function policyAccountBalances(address, address) external view returns (uint256) {
        uint256 _baseAmount = 1000;
        return _baseAmount * 1e9;
    }

    function accountDelegationsList(address, uint256, uint256) external view returns (IGovernanceDelegationV1.AccountDelegation[] memory) {
        IGovernanceDelegationV1.AccountDelegation[] memory _delegations = new IGovernanceDelegationV1.AccountDelegation[](1);
        _delegations[0] = IGovernanceDelegationV1.AccountDelegation({
            delegate: address(0x1),
            escrow: address(0x2),
            amount: 500 * 1e9
        });
        return _delegations;
    }

    function totalDelegatedTo(address) external pure returns (uint256) {
        return 500 * 1e9;
    }

    function accountDelegationSummary(address) external view returns (uint256, uint256, uint256, uint256) {
        return (1000 * 1e9, 500 * 1e9, 1, _MAX_DELEGATES_DEFAULT);
    }

    function maxDelegateAddresses(address) external pure returns (uint32) {
        return 10;
    }
}
