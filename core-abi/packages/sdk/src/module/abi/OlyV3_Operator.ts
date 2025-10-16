export const OlyV3_Operator = [
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
    inputs: [],
    name: 'InvalidInitialization',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'caller_',
        type: 'address',
      },
    ],
    name: 'KernelAdapter_OnlyKernel',
    type: 'error',
  },
  {
    inputs: [],
    name: 'NotInitializing',
    type: 'error',
  },
  {
    inputs: [],
    name: 'Operator_AlreadyInitialized',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'amountOut',
        type: 'uint256',
      },
      {
        internalType: 'uint256',
        name: 'minAmountOut_',
        type: 'uint256',
      },
    ],
    name: 'Operator_AmountLessThanMinimum',
    type: 'error',
  },
  {
    inputs: [],
    name: 'Operator_Inactive',
    type: 'error',
  },
  {
    inputs: [],
    name: 'Operator_InsufficientCapacity',
    type: 'error',
  },
  {
    inputs: [],
    name: 'Operator_InvalidParams',
    type: 'error',
  },
  {
    inputs: [],
    name: 'Operator_NotInitialized',
    type: 'error',
  },
  {
    inputs: [],
    name: 'Operator_WallDown',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'bytes32',
        name: 'role_',
        type: 'bytes32',
      },
    ],
    name: 'ROLES_RequireRole',
    type: 'error',
  },
  {
    inputs: [],
    name: 'ReentrantCall',
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
    name: 'ARK',
    outputs: [
      {
        internalType: 'contract IERC20',
        name: '',
        type: 'address',
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
    inputs: [],
    name: 'ROLES',
    outputs: [
      {
        internalType: 'contract ROLESv1',
        name: '',
        type: 'address',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'activate',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [],
    name: 'active',
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
    name: 'auctioneer',
    outputs: [
      {
        internalType: 'contract IBondSDA',
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
        internalType: 'uint256',
        name: '',
        type: 'uint256',
      },
      {
        internalType: 'uint256',
        name: '',
        type: 'uint256',
      },
    ],
    name: 'bondPurchase',
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
            name: 'amount',
            type: 'uint256',
          },
          {
            internalType: 'uint256',
            name: 'modeId',
            type: 'uint256',
          },
          {
            internalType: 'uint32',
            name: 'deadline',
            type: 'uint32',
          },
        ],
        internalType: 'struct ARKBondInternal.DepositParam',
        name: 'depositParam',
        type: 'tuple',
      },
    ],
    name: 'bondPurchase__V3',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [],
    name: 'callback',
    outputs: [
      {
        internalType: 'contract IBondCallback',
        name: '',
        type: 'address',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'config',
    outputs: [
      {
        components: [
          {
            internalType: 'uint32',
            name: 'cushionFactor',
            type: 'uint32',
          },
          {
            internalType: 'uint32',
            name: 'cushionDuration',
            type: 'uint32',
          },
          {
            internalType: 'uint32',
            name: 'cushionDebtBuffer',
            type: 'uint32',
          },
          {
            internalType: 'uint32',
            name: 'cushionDepositInterval',
            type: 'uint32',
          },
          {
            internalType: 'uint32',
            name: 'reserveFactor',
            type: 'uint32',
          },
          {
            internalType: 'uint32',
            name: 'regenWait',
            type: 'uint32',
          },
          {
            internalType: 'uint32',
            name: 'regenThreshold',
            type: 'uint32',
          },
          {
            internalType: 'uint32',
            name: 'regenObserve',
            type: 'uint32',
          },
        ],
        internalType: 'struct Operator.Config',
        name: '',
        type: 'tuple',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'configureDependencies',
    outputs: [
      {
        internalType: 'Keycode[]',
        name: 'dependencies',
        type: 'bytes5[]',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'deactivate',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'bool',
        name: '',
        type: 'bool',
      },
    ],
    name: 'deactivateCushion',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'bool',
        name: '',
        type: 'bool',
      },
    ],
    name: 'fullCapacity',
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
        internalType: 'contract IERC20',
        name: '',
        type: 'address',
      },
      {
        internalType: 'uint256',
        name: 'amountIn_',
        type: 'uint256',
      },
    ],
    name: 'getAmountOut',
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
        internalType: 'contract Kernel',
        name: 'kernel_',
        type: 'address',
      },
      {
        internalType: 'address',
        name: 'ARK_',
        type: 'address',
      },
      {
        internalType: 'address',
        name: 'reserve_',
        type: 'address',
      },
      {
        internalType: 'address',
        name: 'sReserve_',
        type: 'address',
      },
      {
        internalType: 'address',
        name: 'oldReserve_',
        type: 'address',
      },
      {
        internalType: 'contract ARKBondInternal',
        name: 'arkInternal_',
        type: 'address',
      },
      {
        internalType: 'contract IERC20',
        name: 'principalToken_',
        type: 'address',
      },
    ],
    name: 'initialize',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [],
    name: 'initialized',
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
    name: 'kernel',
    outputs: [
      {
        internalType: 'contract Kernel',
        name: '',
        type: 'address',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'oldReserve',
    outputs: [
      {
        internalType: 'contract IERC20',
        name: '',
        type: 'address',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'operate',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'bool',
        name: '',
        type: 'bool',
      },
    ],
    name: 'regenerate',
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
    inputs: [],
    name: 'requestPermissions',
    outputs: [
      {
        components: [
          {
            internalType: 'Keycode',
            name: 'keycode',
            type: 'bytes5',
          },
          {
            internalType: 'bytes4',
            name: 'funcSelector',
            type: 'bytes4',
          },
        ],
        internalType: 'struct Permissions[]',
        name: 'requests',
        type: 'tuple[]',
      },
    ],
    stateMutability: 'view',
    type: 'function',
  },
  {
    inputs: [],
    name: 'reserve',
    outputs: [
      {
        internalType: 'contract IERC20',
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
    inputs: [],
    name: 'sReserve',
    outputs: [
      {
        internalType: 'contract IERC4626',
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
        components: [
          {
            internalType: 'contract IERC20',
            name: 'principalToken',
            type: 'address',
          },
          {
            internalType: 'contract ARKBondInternal',
            name: 'arkInternal',
            type: 'address',
          },
        ],
        internalType: 'struct Operator.ARKInternalAddressConfig',
        name: 'paramAddressConfig',
        type: 'tuple',
      },
    ],
    name: 'setARKInternalAddressConfig',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'contract IBondSDA',
        name: '',
        type: 'address',
      },
      {
        internalType: 'contract IBondCallback',
        name: '',
        type: 'address',
      },
    ],
    name: 'setBondContracts',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint32',
        name: '',
        type: 'uint32',
      },
    ],
    name: 'setCushionFactor',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint32',
        name: '',
        type: 'uint32',
      },
      {
        internalType: 'uint32',
        name: '',
        type: 'uint32',
      },
      {
        internalType: 'uint32',
        name: '',
        type: 'uint32',
      },
    ],
    name: 'setCushionParams',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint32',
        name: '',
        type: 'uint32',
      },
      {
        internalType: 'uint32',
        name: '',
        type: 'uint32',
      },
      {
        internalType: 'uint32',
        name: '',
        type: 'uint32',
      },
    ],
    name: 'setRegenParams',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint32',
        name: '',
        type: 'uint32',
      },
    ],
    name: 'setReserveFactor',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'bool',
        name: '',
        type: 'bool',
      },
      {
        internalType: 'uint256',
        name: '',
        type: 'uint256',
      },
      {
        internalType: 'uint256',
        name: '',
        type: 'uint256',
      },
    ],
    name: 'setSpreads',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: '',
        type: 'uint256',
      },
    ],
    name: 'setThresholdFactor',
    outputs: [],
    stateMutability: 'nonpayable',
    type: 'function',
  },
  {
    inputs: [],
    name: 'status',
    outputs: [
      {
        components: [
          {
            components: [
              {
                internalType: 'uint32',
                name: 'count',
                type: 'uint32',
              },
              {
                internalType: 'uint48',
                name: 'lastRegen',
                type: 'uint48',
              },
              {
                internalType: 'uint32',
                name: 'nextObservation',
                type: 'uint32',
              },
              {
                internalType: 'bool[]',
                name: 'observations',
                type: 'bool[]',
              },
            ],
            internalType: 'struct Operator.Regen',
            name: 'low',
            type: 'tuple',
          },
          {
            components: [
              {
                internalType: 'uint32',
                name: 'count',
                type: 'uint32',
              },
              {
                internalType: 'uint48',
                name: 'lastRegen',
                type: 'uint48',
              },
              {
                internalType: 'uint32',
                name: 'nextObservation',
                type: 'uint32',
              },
              {
                internalType: 'bool[]',
                name: 'observations',
                type: 'bool[]',
              },
            ],
            internalType: 'struct Operator.Regen',
            name: 'high',
            type: 'tuple',
          },
        ],
        internalType: 'struct Operator.Status',
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
    inputs: [
      {
        internalType: 'contract IERC20',
        name: '',
        type: 'address',
      },
      {
        internalType: 'uint256',
        name: '',
        type: 'uint256',
      },
      {
        internalType: 'uint256',
        name: '',
        type: 'uint256',
      },
    ],
    name: 'swap',
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
    inputs: [
      {
        internalType: 'uint256',
        name: 'givenAmount',
        type: 'uint256',
      },
    ],
    name: 'Deposit_AmountBelowMinLimit',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'dailySupplyLimit',
        type: 'uint256',
      },
      {
        internalType: 'uint256',
        name: 'dailySupplyAfterMint',
        type: 'uint256',
      },
    ],
    name: 'Deposit_ExceedDailySuply',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'mintingCapLimit',
        type: 'uint256',
      },
      {
        internalType: 'uint256',
        name: 'exceededAmount',
        type: 'uint256',
      },
    ],
    name: 'Deposit_ExceedMintingCap',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'safeMinQuote',
        type: 'uint256',
      },
      {
        internalType: 'uint256',
        name: 'givenQuote',
        type: 'uint256',
      },
    ],
    name: 'Deposit_InvalidQuoteAmountOut',
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
    name: 'ExceedMaxRedeemAllowance',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'modeId',
        type: 'uint256',
      },
      {
        internalType: 'bool',
        name: 'isExist',
        type: 'bool',
      },
      {
        internalType: 'bool',
        name: 'isActive',
        type: 'bool',
      },
    ],
    name: 'InvalidMode',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'nftDaoTokenId',
        type: 'uint256',
      },
      {
        internalType: 'uint256',
        name: 'nftDaoVotingPointsToBurn',
        type: 'uint256',
      },
    ],
    name: 'InvalidNftDAOParamForPartialBurn',
    type: 'error',
  },
  {
    inputs: [],
    name: 'InvalidSignature',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'address',
        name: 'operator',
        type: 'address',
      },
      {
        internalType: 'address',
        name: 'caller',
        type: 'address',
      },
    ],
    name: 'OnlyCallableByOlympusProxy',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'string',
        name: '',
        type: 'string',
      },
    ],
    name: 'Pausable__NotPaused',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'string',
        name: '',
        type: 'string',
      },
    ],
    name: 'Pausable__Paused',
    type: 'error',
  },
  {
    inputs: [],
    name: 'ReentrancyGuard__ReentrantCall',
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
    name: 'RevokedSignature',
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
    inputs: [
      {
        internalType: 'uint256',
        name: 'claimable',
        type: 'uint256',
      },
    ],
    name: 'ZeroClaimable',
    type: 'error',
  },
  {
    inputs: [
      {
        internalType: 'uint256',
        name: 'minAmount',
        type: 'uint256',
      },
      {
        internalType: 'uint256',
        name: 'givenAmount',
        type: 'uint256',
      },
    ],
    name: 'Stake_AmountBelowMinLimit',
    type: 'error',
  },
] as const;
