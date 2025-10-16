export const ARKCoreGlobalConfig = [
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
    name: 'ConfigOutOfAllowance',
    type: 'error',
  },
  {
    inputs: [],
    name: 'EnumerableSet__IndexOutOfBounds',
    type: 'error',
  },
  {
    inputs: [],
    name: 'UintUtils__InsufficientPadding',
    type: 'error',
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: 'uint256',
        name: 'modeId',
        type: 'uint256',
      },
      {
        indexed: false,
        internalType: 'uint256',
        name: 'vestingPeriod',
        type: 'uint256',
      },
      {
        indexed: false,
        internalType: 'uint256',
        name: 'interestRate',
        type: 'uint256',
      },
    ],
    name: 'ModeCreated',
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
    inputs: [
      {
        internalType: 'uint32',
        name: 'vestingPeriod',
        type: 'uint32',
      },
      {
        internalType: 'uint16',
        name: 'discountRate',
        type: 'uint16',
      },
      {
        internalType: 'uint16',
        name: 'interestRate',
        type: 'uint16',
      },
      {
        internalType: 'uint16',
        name: 'daoNftVotingPowerMultiplier',
        type: 'uint16',
      },
    ],
    name: 'createMode',
    outputs: [
      {
        internalType: 'uint256',
        name: '',
        type: 'uint256',
      },
    ],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'modeId',
        type: 'uint256',
      },
    ],
    name: 'deleteMode',
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
            name: 'baseToken',
            type: 'address',
          },
          {
            internalType: 'contract IERC20Extended',
            name: 'principalToken',
            type: 'address',
          },
          {
            internalType: 'contract IPancakeRouter02',
            name: 'swapRouter',
            type: 'address',
          },
          {
            internalType: 'contract IPancakePair',
            name: 'lpPool',
            type: 'address',
          },
          {
            internalType: 'address',
            name: 'daoPool',
            type: 'address',
          },
          {
            internalType: 'address',
            name: 'rewardPool',
            type: 'address',
          },
          {
            internalType: 'address',
            name: 'treasury',
            type: 'address',
          },
          {
            internalType: 'address',
            name: 'signer',
            type: 'address',
          },
          {
            internalType: 'contract IDAONft',
            name: 'daoNft',
            type: 'address',
          },
          {
            internalType: 'address',
            name: 'lpLiquidationTreasury',
            type: 'address',
          },
          {
            internalType: 'address',
            name: 'olympus__Operator',
            type: 'address',
          },
          {
            internalType: 'address',
            name: 'olympus__BondFixedTermTeller',
            type: 'address',
          },
          {
            internalType: 'address',
            name: 'olympus__VohmVault',
            type: 'address',
          },
          {
            internalType: 'contract IARKMinter',
            name: 'baseTokenMinter',
            type: 'address',
          },
          {
            internalType: 'contract IRewardVesting',
            name: 'rewardVesting',
            type: 'address',
          },
        ],
        internalType: 'struct AddressConfig',
        name: '',
        type: 'tuple',
      },
    ],
    stateMutability: 'pure',
    type: 'function',
  },
  {
    inputs: [],
    name: 'getAllModes',
    outputs: [
      {
        components: [
          {
            internalType: 'uint32',
            name: 'vestingPeriod',
            type: 'uint32',
          },
          {
            internalType: 'uint16',
            name: 'discountRate',
            type: 'uint16',
          },
          {
            internalType: 'bool',
            name: 'isActive',
            type: 'bool',
          },
          {
            internalType: 'bool',
            name: 'isExist',
            type: 'bool',
          },
          {
            internalType: 'uint16',
            name: 'interestRate',
            type: 'uint16',
          },
          {
            internalType: 'uint16',
            name: 'daoNftVotingPowerMultiplier',
            type: 'uint16',
          },
        ],
        internalType: 'struct Mode[]',
        name: 'list',
        type: 'tuple[]',
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
            internalType: 'uint8',
            name: 'modeIdEntry',
            type: 'uint8',
          },
          {
            internalType: 'uint96',
            name: 'deposit_minPrincipalTokenDeposit',
            type: 'uint96',
          },
          {
            internalType: 'uint96',
            name: 'currentDayBaseTokenSupply',
            type: 'uint96',
          },
          {
            internalType: 'uint96',
            name: 'dailySupplyLimit',
            type: 'uint96',
          },
          {
            internalType: 'uint96',
            name: 'dailySupplyLimit_current',
            type: 'uint96',
          },
          {
            internalType: 'uint16',
            name: 'dailySupplyLimit_baseEmissionRate_v1',
            type: 'uint16',
          },
          {
            internalType: 'uint96',
            name: 'dailySupplyLimit_minPremium',
            type: 'uint96',
          },
          {
            internalType: 'uint8',
            name: 'mintingcaplimit_buffer_v1',
            type: 'uint8',
          },
          {
            internalType: 'uint96',
            name: 'redeemBond_maxBondTokenRedeemAllowance',
            type: 'uint96',
          },
          {
            internalType: 'uint96',
            name: 'redeemBond_totalBondTokenRedeemed',
            type: 'uint96',
          },
          {
            internalType: 'uint96',
            name: 'stakeClaim_maxTotalClaimAllowance',
            type: 'uint96',
          },
          {
            internalType: 'uint96',
            name: 'stakeClaim_totalClaimAllowance',
            type: 'uint96',
          },
          {
            internalType: 'uint16',
            name: 'rcm_ratio_v1',
            type: 'uint16',
          },
          {
            internalType: 'uint32',
            name: 'mintingcaplimit_buffer',
            type: 'uint32',
          },
          {
            internalType: 'bool',
            name: 'paused_staking',
            type: 'bool',
          },
          {
            internalType: 'bool',
            name: 'paused_bonding',
            type: 'bool',
          },
          {
            internalType: 'uint32',
            name: 'rcm_buffer_multiplier',
            type: 'uint32',
          },
          {
            internalType: 'uint32',
            name: 'rcm_random_multiplier',
            type: 'uint32',
          },
          {
            internalType: 'uint32',
            name: 'rcm_random_range_min',
            type: 'uint32',
          },
          {
            internalType: 'uint32',
            name: 'rcm_random_range_max',
            type: 'uint32',
          },
          {
            internalType: 'uint32',
            name: 'dailySupplyLimit_baseEmissionRate',
            type: 'uint32',
          },
        ],
        internalType: 'struct Config',
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
        internalType: 'uint256',
        name: 'modeId',
        type: 'uint256',
      },
    ],
    name: 'getMode',
    outputs: [
      {
        components: [
          {
            internalType: 'uint32',
            name: 'vestingPeriod',
            type: 'uint32',
          },
          {
            internalType: 'uint16',
            name: 'discountRate',
            type: 'uint16',
          },
          {
            internalType: 'bool',
            name: 'isActive',
            type: 'bool',
          },
          {
            internalType: 'bool',
            name: 'isExist',
            type: 'bool',
          },
          {
            internalType: 'uint16',
            name: 'interestRate',
            type: 'uint16',
          },
          {
            internalType: 'uint16',
            name: 'daoNftVotingPowerMultiplier',
            type: 'uint16',
          },
        ],
        internalType: 'struct Mode',
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
        internalType: 'bytes32',
        name: 'role',
        type: 'bytes32',
      },
      {
        internalType: 'uint256',
        name: 'index',
        type: 'uint256',
      },
    ],
    name: 'getRoleMember',
    outputs: [
      {
        internalType: 'address',
        name: '',
        type: 'address',
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
    name: 'getRoleMemberCount',
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
    inputs: [],
    name: 'pauseBonding',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [],
    name: 'pauseStaking',
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
        internalType: 'contract IARKMinter',
        name: 'newAddress',
        type: 'address',
      },
    ],
    name: 'setBaseTokenMinter',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [],
    name: 'setDailySupplyLimit',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint32',
        name: 'rate',
        type: 'uint32',
      },
    ],
    name: 'setDailySupplyLimit_baseEmissionRate',
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
    name: 'setDailySupplyLimit_minPremium',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'contract IDAONft',
        name: 'newAddress',
        type: 'address',
      },
    ],
    name: 'setDaoNft',
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
    name: 'setDaoPool',
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
    name: 'setMaxRedeemBondAllowance',
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
    name: 'setMaxStakeClaimAllowance',
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
    name: 'setMinimumLimitDeposit',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint32',
        name: 'amount',
        type: 'uint32',
      },
    ],
    name: 'setMintingCapLimit_buffer',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'modeId',
        type: 'uint256',
      },
      {
        components: [
          {
            internalType: 'uint32',
            name: 'vestingPeriod',
            type: 'uint32',
          },
          {
            internalType: 'uint16',
            name: 'discountRate',
            type: 'uint16',
          },
          {
            internalType: 'bool',
            name: 'isActive',
            type: 'bool',
          },
          {
            internalType: 'bool',
            name: 'isExist',
            type: 'bool',
          },
          {
            internalType: 'uint16',
            name: 'interestRate',
            type: 'uint16',
          },
          {
            internalType: 'uint16',
            name: 'daoNftVotingPowerMultiplier',
            type: 'uint16',
          },
        ],
        internalType: 'struct Mode',
        name: 'param',
        type: 'tuple',
      },
    ],
    name: 'setMode',
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
    name: 'setOlympus__BondFixedTermTeller',
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
    name: 'setOlympus__Operator',
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
    name: 'setOlympus__VohmVault',
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
        internalType: 'uint16',
        name: 'multiplier',
        type: 'uint32',
      },
    ],
    name: 'setRCMBufferMultiplier',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint32',
        name: 'multiplier',
        type: 'uint32',
      },
    ],
    name: 'setRCMRandomMultiplier',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint32',
        name: 'maxLimit',
        type: 'uint32',
      },
    ],
    name: 'setRCMRandomRangeMax',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint32',
        name: 'minLimit',
        type: 'uint32',
      },
    ],
    name: 'setRCMRandomRangeMin',
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
        internalType: 'contract IRewardVesting',
        name: 'newAddress',
        type: 'address',
      },
    ],
    name: 'setRewardVesting',
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
        internalType: 'address',
        name: 'newAddress',
        type: 'address',
      },
    ],
    name: 'setTreasury',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [],
    name: 'unpauseBonding',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [],
    name: 'unpauseStaking',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
] as const;
