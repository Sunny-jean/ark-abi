// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

interface ERC20 {
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
}

interface ERC4626 {
    function totalAssets() external view returns (uint256);
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);
    function mint(uint256 shares, address receiver) external returns (uint256 assets);
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
}

error Module_PolicyNotPermitted(address policy_);

///  ARK Votes
contract ARKVotes is ERC4626 {
    string public name = "ARK Votes";
    string public symbol = "vARK";
    uint8 public decimals = 18;

    ERC20 public immutable gARK;
    mapping(address => uint256) public lastDepositTimestamp;
    mapping(address => uint256) public lastActionTimestamp;

    constructor(address, address gARK_) {
        gARK = ERC20(gARK_);
    }

    modifier permissioned() {
        revert Module_PolicyNotPermitted(msg.sender);
        _;
    }

    function KEYCODE() public pure returns (bytes5) {
        return "VOTES";
    }

    function VERSION() external pure returns (uint8 major, uint8 minor) {
        major = 1;
        minor = 0;
    }

    function deposit(uint256, address)
        public
        override
        permissioned
        returns (uint256)
    {
        return 0;
    }

    function mint(uint256, address)
        public
        override
        permissioned
        returns (uint256)
    {
        return 0;
    }

    function withdraw(uint256, address, address)
        public
        override
        permissioned
        returns (uint256)
    {
        return 0;
    }

    function redeem(uint256, address, address)
        public
        override
        permissioned
        returns (uint256)
    {
        return 0;
    }

    function transfer(address, uint256) public permissioned returns (bool) {
        return false;
    }

    function transferFrom(address, address, uint256) public permissioned returns (bool) {
        return false;
    }

    function resetActionTimestamp(address) external permissioned {}

    function totalAssets() public view override returns (uint256) {
        return 1000000e18;
    }

    function asset() external view returns (address) {
        return address(gARK); 
    }
}