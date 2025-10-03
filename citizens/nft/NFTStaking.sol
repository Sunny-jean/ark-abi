// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface NFTStaking {
    /**
     * @dev Emitted when an NFT is staked.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the NFT.
     * @param staker The address of the staker.
     */
    event NFTStaked(address indexed nftContract, uint256 indexed tokenId, address indexed staker);

    /**
     * @dev Emitted when a staked NFT is unstaked.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the NFT.
     * @param staker The address of the staker.
     */
    event NFTUnstaked(address indexed nftContract, uint256 indexed tokenId, address indexed staker);

    /**
     * @dev Emitted when rewards are claimed for a staked NFT.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the NFT.
     * @param claimer The address of the claimer.
     * @param amount The amount of rewards claimed.
     */
    event NFTRewardsClaimed(address indexed nftContract, uint256 indexed tokenId, address indexed claimer, uint256 amount);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a required parameter is missing or invalid.
     */
    error InvalidParameter(string parameterName, string description);

    /**
     * @dev Thrown when an NFT is not found or not staked.
     */
    error NFTNotFoundOrNotStaked();

    /**
     * @dev Thrown when the NFT is already staked.
     */
    error NFTAlreadyStaked();

    /**
     * @dev Thrown when there are no rewards to claim for the NFT.
     */
    error NoRewardsToClaim();

    /**
     * @dev Stakes an NFT.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the NFT to stake.
     */
    function stakeNFT(address nftContract, uint256 tokenId) external;

    /**
     * @dev Unstakes an NFT.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the NFT to unstake.
     */
    function unstakeNFT(address nftContract, uint256 tokenId) external;

    /**
     * @dev Claims rewards for a staked NFT.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the NFT to claim rewards for.
     */
    function claimNFTRewards(address nftContract, uint256 tokenId) external;

    /**
     * @dev Returns the staker of a given NFT.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the NFT.
     * @return staker The address of the staker, or address(0) if not staked.
     */
    function getNFTStaker(address nftContract, uint256 tokenId) external view returns (address staker);

    /**
     * @dev Returns the pending rewards for a given staked NFT.
     * @param nftContract The address of the NFT contract.
     * @param tokenId The ID of the NFT.
     * @return rewardsAmount The amount of pending rewards.
     */
    function getNFTPendingRewards(address nftContract, uint256 tokenId) external view returns (uint256 rewardsAmount);
}