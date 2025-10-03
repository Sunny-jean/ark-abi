// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDAOGovernanceToken {
    // DAO 治理代幣
    function mint(address _to, uint256 _amount) external;
    function burn(uint256 _amount) external;
    function balanceOf(address _account) external view returns (uint256);

    event Minted(address indexed to, uint256 amount);
    event Burned(address indexed from, uint256 amount);

    error MintingFailed();
    error BurningFailed();
}