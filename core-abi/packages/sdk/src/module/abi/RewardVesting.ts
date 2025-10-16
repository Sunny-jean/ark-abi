export const RewardVesting = [
  {
    inputs: [],
    stateMutability: 'nonpayable',
    type: 'constructor',
  },
  {
    inputs: [],
    name: 'AccessControlBadConfirmation',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'account',
        type: 'address',
      },
      {
        internalType: 'bytes32',
        name: 'neededRole',
        type: 'bytes32',
      },
    ],
    name: 'AccessControlUnauthorizedAccount',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'owner',
        type: 'address',
      },
      {
        internalType: 'address',
        name: 'spender',
        type: 'address',
      },
      {
        internalType: 'address',
        name: 'token',
        type: 'address',
      },
      {
        internalType: 'uint256',
        name: 'curAllowance',
        type: 'uint256',
      },
      {
        internalType: 'uint256',
        name: 'setAmount',
        type: 'uint256',
      },
    ],
    name: 'ClaimDelayedReward_ConfigOutOfAllowance',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'maxAllowance',
        type: 'uint256',
      },
      {
        internalType: 'uint256',
        name: 'updatedTotalTokenRedeemed',
        type: 'uint256',
      },
    ],
    name: 'ClaimDelayedReward_ExceedMaxClaimAllowance',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'rewardId',
        type: 'uint256',
      },
      {
        internalType: 'bool',
        name: 'rewardIsExist',
        type: 'bool',
      },
    ],
    name: 'ClaimDelayedReward_InexistReward',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'rewardId',
        type: 'uint256',
      },
      {
        internalType: 'bool',
        name: 'rewardIsClaimed',
        type: 'bool',
      },
    ],
    name: 'ClaimDelayedReward_RewardClaimed',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'rewardId',
        type: 'uint256',
      },
      {
        internalType: 'uint256',
        name: 'rewardUnlockTimestamp',
        type: 'uint256',
      },
      {
        internalType: 'uint256',
        name: 'currentTimestamp',
        type: 'uint256',
      },
    ],
    name: 'ClaimDelayedReward_RewardNotUnlockable',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'availableReward',
        type: 'uint256',
      },
      {
        internalType: 'uint256',
        name: 'inputAmountToClaim',
        type: 'uint256',
      },
    ],
    name: 'ClaimReward_AmountExceedAvailableReward',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'claimable',
        type: 'uint256',
      },
    ],
    name: 'ClaimReward_ZeroClaimable',
    type: 'error',
  },
  {
    inputs: [],
    name: 'ECDSAInvalidSignature',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'length',
        type: 'uint256',
      },
    ],
    name: 'ECDSAInvalidSignatureLength',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'bytes32',
        name: 's',
        type: 'bytes32',
      },
    ],
    name: 'ECDSAInvalidSignatureS',
    type: 'error',
  },
  {
    inputs: [],
    name: 'EnforcedPause',
    type: 'error',
  },
  {
    inputs: [],
    name: 'ExpectedPause',
    type: 'error',
  },
  {
    inputs: [],
    name: 'InvalidInitialization',
    type: 'error',
  },
  {
    inputs: [],
    name: 'NotInitializing',
    type: 'error',
  },
  {
    inputs: [],
    name: 'ReentrancyGuardReentrantCall',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'invalidType',
        type: 'uint256',
      },
    ],
    name: 'RewardVestingInit_InvalidRewardType',
    type: 'error',
  },
  {
    inputs: [],
    name: 'RewardVestingInit_InvalidSignature',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'bytes',
        name: 'signature',
        type: 'bytes',
      },
    ],
    name: 'RewardVestingInit_RevokedSignature',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'token',
        type: 'address',
      },
    ],
    name: 'SafeERC20FailedOperation',
    type: 'error',
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: 'address',
        name: 'user',
        type: 'address',
      },
      {
        indexed: false,
        internalType: 'uint256',
        name: 'amount',
        type: 'uint256',
      },
    ],
    name: 'DelayedRewardClaimed',
    type: 'event',
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: 'uint64',
        name: 'version',
        type: 'uint64',
      },
    ],
    name: 'Initialized',
    type: 'event',
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: 'address',
        name: 'account',
        type: 'address',
      },
    ],
    name: 'Paused',
    type: 'event',
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: 'address',
        name: 'user',
        type: 'address',
      },
      {
        indexed: false,
        internalType: 'uint256',
        name: 'amount',
        type: 'uint256',
      },
    ],
    name: 'RewardClaimed',
    type: 'event',
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: 'address',
        name: 'user',
        type: 'address',
      },
      {
        indexed: true,
        internalType: 'uint256',
        name: 'id',
        type: 'uint256',
      },
      {
        indexed: false,
        internalType: 'uint256',
        name: 'amount',
        type: 'uint256',
      },
      {
        indexed: false,
        internalType: 'uint256',
        name: 'createdAt',
        type: 'uint256',
      },
      {
        indexed: false,
        internalType: 'uint256',
        name: 'vestingDuration',
        type: 'uint256',
      },
      {
        indexed: false,
        internalType: 'string',
        name: '_data',
        type: 'string',
      },
    ],
    name: 'RewardVestingInitiated',
    type: 'event',
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: 'bytes32',
        name: 'role',
        type: 'bytes32',
      },
      {
        indexed: true,
        internalType: 'bytes32',
        name: 'previousAdminRole',
        type: 'bytes32',
      },
      {
        indexed: true,
        internalType: 'bytes32',
        name: 'newAdminRole',
        type: 'bytes32',
      },
    ],
    name: 'RoleAdminChanged',
    type: 'event',
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: 'bytes32',
        name: 'role',
        type: 'bytes32',
      },
      {
        indexed: true,
        internalType: 'address',
        name: 'account',
        type: 'address',
      },
      {
        indexed: true,
        internalType: 'address',
        name: 'sender',
        type: 'address',
      },
    ],
    name: 'RoleGranted',
    type: 'event',
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: 'bytes32',
        name: 'role',
        type: 'bytes32',
      },
      {
        indexed: true,
        internalType: 'address',
        name: 'account',
        type: 'address',
      },
      {
        indexed: true,
        internalType: 'address',
        name: 'sender',
        type: 'address',
      },
    ],
    name: 'RoleRevoked',
    type: 'event',
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: 'address',
        name: 'account',
        type: 'address',
      },
    ],
    name: 'Unpaused',
    type: 'event',
  },
  {
    inputs: [],
    name: 'ADMIN_ROLE',
    outputs: [
      {
        internalType: 'bytes32',
        name: '',
        type: 'bytes32',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'DEFAULT_ADMIN_ROLE',
    outputs: [
      {
        internalType: 'bytes32',
        name: '',
        type: 'bytes32',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'delayedRewardId',
        type: 'uint256',
      },
    ],
    name: 'claimDelayedReward',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'amountToClaim',
        type: 'uint256',
      },
      {
        internalType: 'uint256[]',
        name: 'ids',
        type: 'uint256[]',
      },
      {
        internalType: 'uint32',
        name: 'deadline',
        type: 'uint32',
      },
    ],
    name: 'claimRewardVesting',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getAddressConfig',
    outputs: [
      {
        components: [
          {
            internalType: 'contract IERC20Extended',
            name: 'principalToken',
            type: 'address',
          },
          {
            internalType: 'contract IERC20Extended',
            name: 'baseToken',
            type: 'address',
          },
          {
            internalType: 'contract IERC20Extended',
            name: 'ethToken',
            type: 'address',
          },
          {
            internalType: 'contract IPancakePair',
            name: 'lpPool',
            type: 'address',
          },
          {
            internalType: 'contract IPancakePair',
            name: 'ethUsdtPool',
            type: 'address',
          },
          {
            internalType: 'contract IPancakeRouter02',
            name: 'swapRouter',
            type: 'address',
          },
          {
            internalType: 'address',
            name: 'rewardPool',
            type: 'address',
          },
          {
            internalType: 'address',
            name: 'signer',
            type: 'address',
          },
          {
            internalType: 'address',
            name: 'dynamicRewardTreasury',
            type: 'address',
          },
          {
            internalType: 'address',
            name: 'staticRewardTreasury',
            type: 'address',
          },
          {
            internalType: 'contract IERC20Extended',
            name: 'staticRewardProofToken',
            type: 'address',
          },
        ],
        internalType: 'struct RewardVesting.AddressConfig',
        name: '',
        type: 'tuple',
      },
    ],
    stateMutability: 'pure',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'user',
        type: 'address',
      },
    ],
    name: 'getAllDelayedReward',
    outputs: [
      {
        components: [
          {
            internalType: 'uint96',
            name: 'delayedReward',
            type: 'uint96',
          },
          {
            internalType: 'uint32',
            name: 'unlockTimestamp',
            type: 'uint32',
          },
          {
            internalType: 'bool',
            name: 'isExist',
            type: 'bool',
          },
          {
            internalType: 'bool',
            name: 'isClaimed',
            type: 'bool',
          },
        ],
        internalType: 'struct RewardVesting.ClaimDelayedRewardInfo[]',
        name: 'delayedRewardInfo',
        type: 'tuple[]',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'user',
        type: 'address',
      },
      {
        internalType: 'uint256',
        name: 'claimTimestamp',
        type: 'uint256',
      },
      {
        internalType: 'uint256[]',
        name: 'ids',
        type: 'uint256[]',
      },
    ],
    name: 'getAllVestingClaimable',
    outputs: [
      {
        internalType: 'uint256',
        name: 'claimableAmount',
        type: 'uint256',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'account',
        type: 'address',
      },
      {
        internalType: 'uint32',
        name: 'id',
        type: 'uint32',
      },
    ],
    name: 'getClaimDelayedRewardInfo',
    outputs: [
      {
        components: [
          {
            internalType: 'uint96',
            name: 'delayedReward',
            type: 'uint96',
          },
          {
            internalType: 'uint32',
            name: 'unlockTimestamp',
            type: 'uint32',
          },
          {
            internalType: 'bool',
            name: 'isExist',
            type: 'bool',
          },
          {
            internalType: 'bool',
            name: 'isClaimed',
            type: 'bool',
          },
        ],
        internalType: 'struct RewardVesting.ClaimDelayedRewardInfo',
        name: '',
        type: 'tuple',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getConfig',
    outputs: [
      {
        components: [
          {
            internalType: 'uint32',
            name: 'delayedReward_delayDuration',
            type: 'uint32',
          },
          {
            internalType: 'uint96',
            name: 'totalVestingAmount',
            type: 'uint96',
          },
          {
            internalType: 'uint96',
            name: 'totalClaimAmount',
            type: 'uint96',
          },
          {
            internalType: 'uint96',
            name: 'globalMaxClaimAllowanceLimit',
            type: 'uint96',
          },
        ],
        internalType: 'struct RewardVesting.Config',
        name: '',
        type: 'tuple',
      },
    ],
    stateMutability: 'pure',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'user',
        type: 'address',
      },
      {
        internalType: 'uint256',
        name: 'rewardId',
        type: 'uint256',
      },
    ],
    name: 'getDelayedReward',
    outputs: [
      {
        components: [
          {
            internalType: 'uint96',
            name: 'delayedReward',
            type: 'uint96',
          },
          {
            internalType: 'uint32',
            name: 'unlockTimestamp',
            type: 'uint32',
          },
          {
            internalType: 'bool',
            name: 'isExist',
            type: 'bool',
          },
          {
            internalType: 'bool',
            name: 'isClaimed',
            type: 'bool',
          },
        ],
        internalType: 'struct RewardVesting.ClaimDelayedRewardInfo',
        name: '',
        type: 'tuple',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'baseTokenAmount',
        type: 'uint256',
      },
    ],
    name: 'getETHAmountFor',
    outputs: [
      {
        internalType: 'uint256',
        name: '',
        type: 'uint256',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'user',
        type: 'address',
      },
      {
        components: [
          {
            internalType: 'uint256',
            name: 'claimAmount',
            type: 'uint256',
          },
          {
            internalType: 'uint256',
            name: 'burnAmount',
            type: 'uint256',
          },
          {
            internalType: 'uint32',
            name: 'vestingPeriod',
            type: 'uint32',
          },
          {
            internalType: 'uint32',
            name: 'timestamp',
            type: 'uint32',
          },
          {
            internalType: 'enum RewardVesting.RewardType',
            name: 'rewardType',
            type: 'uint8',
          },
          {
            internalType: 'string',
            name: '_data',
            type: 'string',
          },
        ],
        internalType: 'struct RewardVesting.InitiateRewardVestingParam',
        name: 'param',
        type: 'tuple',
      },
    ],
    name: 'getInitiateRewardVestingMessageHash',
    outputs: [
      {
        internalType: 'bytes32',
        name: '',
        type: 'bytes32',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getPendingReleaseToDistributeFromRewardPool',
    outputs: [
      {
        internalType: 'uint256',
        name: '',
        type: 'uint256',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'user',
        type: 'address',
      },
    ],
    name: 'getRewardVesting',
    outputs: [
      {
        components: [
          {
            internalType: 'uint32',
            name: 'createdAt',
            type: 'uint32',
          },
          {
            internalType: 'uint32',
            name: 'vestingPeriod',
            type: 'uint32',
          },
          {
            internalType: 'uint96',
            name: 'amount',
            type: 'uint96',
          },
          {
            internalType: 'uint96',
            name: 'claimed',
            type: 'uint96',
          },
        ],
        internalType: 'struct RewardVesting.RewardVestingInfo[]',
        name: 'rewardVestingInfo',
        type: 'tuple[]',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'bytes32',
        name: 'role',
        type: 'bytes32',
      },
    ],
    name: 'getRoleAdmin',
    outputs: [
      {
        internalType: 'bytes32',
        name: '',
        type: 'bytes32',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'account',
        type: 'address',
      },
    ],
    name: 'getUserInfo',
    outputs: [
      {
        components: [
          {
            internalType: 'uint32',
            name: 'delayedRewardNextIdEntry',
            type: 'uint32',
          },
          {
            internalType: 'uint32',
            name: 'rewardVestingNextIdEntry',
            type: 'uint32',
          },
        ],
        internalType: 'struct RewardVesting.UserInfo',
        name: '',
        type: 'tuple',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'bytes32',
        name: 'role',
        type: 'bytes32',
      },
      {
        internalType: 'address',
        name: 'account',
        type: 'address',
      },
    ],
    name: 'grantRole',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'bytes32',
        name: 'role',
        type: 'bytes32',
      },
      {
        internalType: 'address',
        name: 'account',
        type: 'address',
      },
    ],
    name: 'hasRole',
    outputs: [
      {
        internalType: 'bool',
        name: '',
        type: 'bool',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      {
        components: [
          {
            internalType: 'contract IERC20Extended',
            name: 'principalToken',
            type: 'address',
          },
          {
            internalType: 'contract IERC20Extended',
            name: 'baseToken',
            type: 'address',
          },
          {
            internalType: 'contract IERC20Extended',
            name: 'ethToken',
            type: 'address',
          },
          {
            internalType: 'contract IPancakePair',
            name: 'lpPool',
            type: 'address',
          },
          {
            internalType: 'contract IPancakePair',
            name: 'ethUsdtPool',
            type: 'address',
          },
          {
            internalType: 'contract IPancakeRouter02',
            name: 'swapRouter',
            type: 'address',
          },
          {
            internalType: 'address',
            name: 'rewardPool',
            type: 'address',
          },
          {
            internalType: 'address',
            name: 'signer',
            type: 'address',
          },
          {
            internalType: 'address',
            name: 'dynamicRewardTreasury',
            type: 'address',
          },
          {
            internalType: 'address',
            name: 'staticRewardTreasury',
            type: 'address',
          },
          {
            internalType: 'contract IERC20Extended',
            name: 'staticRewardProofToken',
            type: 'address',
          },
        ],
        internalType: 'struct RewardVesting.AddressConfig',
        name: 'paramAddress',
        type: 'tuple',
      },
      {
        components: [
          {
            internalType: 'uint32',
            name: 'delayedReward_delayDuration',
            type: 'uint32',
          },
        ],
        internalType: 'struct RewardVesting.ConfigInit',
        name: 'paramConfig',
        type: 'tuple',
      },
    ],
    name: 'initialize',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        components: [
          {
            internalType: 'uint256',
            name: 'claimAmount',
            type: 'uint256',
          },
          {
            internalType: 'uint256',
            name: 'burnAmount',
            type: 'uint256',
          },
          {
            internalType: 'uint32',
            name: 'vestingPeriod',
            type: 'uint32',
          },
          {
            internalType: 'uint32',
            name: 'timestamp',
            type: 'uint32',
          },
          {
            internalType: 'enum RewardVesting.RewardType',
            name: 'rewardType',
            type: 'uint8',
          },
          {
            internalType: 'string',
            name: '_data',
            type: 'string',
          },
        ],
        internalType: 'struct RewardVesting.InitiateRewardVestingParam',
        name: 'param',
        type: 'tuple',
      },
      {
        internalType: 'uint32',
        name: 'deadline',
        type: 'uint32',
      },
      {
        internalType: 'bytes',
        name: 'signature',
        type: 'bytes',
      },
    ],
    name: 'initiateRewardVesting',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [],
    name: 'pause',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [],
    name: 'paused',
    outputs: [
      {
        internalType: 'bool',
        name: '',
        type: 'bool',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'bytes32',
        name: 'role',
        type: 'bytes32',
      },
      {
        internalType: 'address',
        name: 'callerConfirmation',
        type: 'address',
      },
    ],
    name: 'renounceRole',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'bytes32',
        name: 'role',
        type: 'bytes32',
      },
      {
        internalType: 'address',
        name: 'account',
        type: 'address',
      },
    ],
    name: 'revokeRole',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'bytes',
        name: '',
        type: 'bytes',
      },
    ],
    name: 'revokedClaimRewardSig',
    outputs: [
      {
        internalType: 'bool',
        name: '',
        type: 'bool',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'contract IERC20Extended',
        name: 'newAddress',
        type: 'address',
      },
    ],
    name: 'setBaseToken',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint32',
        name: 'delayDuration',
        type: 'uint32',
      },
    ],
    name: 'setDelayedRewardDelayDuration',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'newAddress',
        type: 'address',
      },
    ],
    name: 'setDynamicRewardTreasury',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'contract IERC20Extended',
        name: 'newAddress',
        type: 'address',
      },
    ],
    name: 'setEthToken',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'contract IPancakePair',
        name: 'newAddress',
        type: 'address',
      },
    ],
    name: 'setEthUsdtPool',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'contract IPancakePair',
        name: 'newAddress',
        type: 'address',
      },
    ],
    name: 'setLpPool',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint96',
        name: 'amount',
        type: 'uint96',
      },
    ],
    name: 'setMaxClaimAllowanceLimit',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'contract IERC20Extended',
        name: 'newAddress',
        type: 'address',
      },
    ],
    name: 'setPrincipalToken',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'newAddress',
        type: 'address',
      },
    ],
    name: 'setRewardPool',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'newAddress',
        type: 'address',
      },
    ],
    name: 'setSigner',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'contract IERC20Extended',
        name: 'newAddress',
        type: 'address',
      },
    ],
    name: 'setStaticRewardProofToken',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'newAddress',
        type: 'address',
      },
    ],
    name: 'setStaticRewardTreasury',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'contract IPancakeRouter02',
        name: 'newAddress',
        type: 'address',
      },
    ],
    name: 'setSwapRouter',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'bytes4',
        name: 'interfaceId',
        type: 'bytes4',
      },
    ],
    name: 'supportsInterface',
    outputs: [
      {
        internalType: 'bool',
        name: '',
        type: 'bool',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'unpause',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
] as const;
