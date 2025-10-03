// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IGovernanceEvents - interface for common governance events
/// @notice Defines events that are emitted across various governance modules
interface IGovernanceEvents {
    /// @dev Emitted when a new governance proposal is created.
    /// @param proposalId The unique identifier of the proposal.
    /// @param proposer The address that created the proposal.
    /// @param target The target contract address for the proposal.
    /// @param value The amount of Ether (or other native token) to be sent with the proposal.
    /// @param signature The function signature to be called on the target contract.
    /// @param callData The calldata to be sent with the function call.
    /// @param description A short description of the proposal.
    event ProposalCreated(
        uint256 proposalId,
        address indexed proposer,
        address indexed target,
        uint256 value,
        string signature,
        bytes callData,
        string description
    );

    /// @dev Emitted when a vote is cast on a governance proposal.
    /// @param proposalId The unique identifier of the proposal.
    /// @param voter The address that cast the vote.
    /// @param support A boolean indicating whether the voter supports (true) or opposes (false) the proposal.
    /// @param weight The voting weight of the voter.
    /// @param reason An optional reason provided by the voter.
    event VoteCast(
        uint256 proposalId,
        address indexed voter,
        bool support,
        uint256 weight,
        string reason
    );

    /// @dev Emitted when a governance proposal's state changes.
    /// @param proposalId The unique identifier of the proposal.
    /// @param oldState The previous state of the proposal.
    /// @param newState The new state of the proposal.
    event ProposalStateChanged(
        uint256 proposalId,
        uint8 oldState,
        uint8 newState
    );

    /// @dev Emitted when a governance parameter is changed.
    /// @param parameterName The name of the parameter that was changed.
    /// @param oldValue The old value of the parameter.
    /// @param newValue The new value of the parameter.
    /// @param changedBy The address that initiated the parameter change.
    event ParameterChanged(
        string parameterName,
        bytes oldValue,
        bytes newValue,
        address indexed changedBy
    );

    /// @dev Emitted when a new governance role is granted.
    /// @param role The name of the role.
    /// @param account The address to which the role was granted.
    /// @param grantedBy The address that granted the role.
    event RoleGranted(
        string role,
        address indexed account,
        address indexed grantedBy
    );

    /// @dev Emitted when a governance role is revoked.
    /// @param role The name of the role.
    /// @param account The address from which the role was revoked.
    /// @param revokedBy The address that revoked the role.
    event RoleRevoked(
        string role,
        address indexed account,
        address indexed revokedBy
    );

    /// @dev Emitted when a module is registered within the governance system.
    /// @param moduleName The name of the registered module.
    /// @param moduleAddress The address of the registered module contract.
    /// @param registeredBy The address that registered the module.
    event ModuleRegistered(
        string moduleName,
        address indexed moduleAddress,
        address indexed registeredBy
    );

    /// @dev Emitted when a module is unregistered from the governance system.
    /// @param moduleName The name of the unregistered module.
    /// @param moduleAddress The address of the unregistered module contract.
    /// @param unregisteredBy The address that unregistered the module.
    event ModuleUnregistered(
        string moduleName,
        address indexed moduleAddress,
        address indexed unregisteredBy
    );

    /// @dev Emitted when an emergency shutdown is triggered.
    /// @param initiator The address that triggered the emergency shutdown.
    /// @param reason A description of the reason for the shutdown.
    event EmergencyShutdown(
        address indexed initiator,
        string reason
    );

    /// @dev Emitted when the system recovers from an emergency shutdown.
    /// @param initiator The address that initiated the recovery.
    /// @param reason A description of the reason for the recovery.
    event EmergencyRecovery(
        address indexed initiator,
        string reason
    );

    /// @dev Emitted when a security audit is scheduled or completed.
    /// @param auditId The unique identifier for the audit.
    /// @param auditor The address of the auditor or auditing firm.
    /// @param status The current status of the audit (e.g., "scheduled", "in-progress", "completed").
    /// @param reportHash A hash of the audit report, if available.
    event SecurityAuditStatus(
        uint256 auditId,
        address indexed auditor,
        string status,
        bytes32 reportHash
    );

    /// @dev Emitted when a compliance report is generated.
    /// @param reportId The unique identifier for the report.
    /// @param standard The compliance standard (e.g., "ERC-20", "KYC").
    /// @param generatedBy The address that generated the report.
    /// @param reportHash A hash of the generated report.
    event ComplianceReportGenerated(
        uint256 reportId,
        string standard,
        address indexed generatedBy,
        bytes32 reportHash
    );

    /// @dev Emitted when a vulnerability is reported or addressed.
    /// @param vulnerabilityId The unique identifier for the vulnerability.
    /// @param reporter The address that reported the vulnerability.
    /// @param severity The severity level of the vulnerability (e.g., "critical", "high", "medium", "low").
    /// @param status The current status of the vulnerability (e.g., "reported", "triaged", "fixed").
    /// @param description A short description of the vulnerability.
    event VulnerabilityStatus(
        uint256 vulnerabilityId,
        address indexed reporter,
        string severity,
        string status,
        string description
    );

    /// @dev Emitted when funds are allocated from the treasury.
    /// @param allocationId The unique identifier for the allocation.
    /// @param recipient The address receiving the allocated funds.
    /// @param amount The amount of funds allocated.
    /// @param token The address of the token being allocated (ERC-20) or address(0) for native token.
    /// @param purpose A description of the purpose of the allocation.
    event FundsAllocated(
        uint256 allocationId,
        address indexed recipient,
        uint256 amount,
        address indexed token,
        string purpose
    );

    /// @dev Emitted when a budget proposal is submitted.
    /// @param proposalId The unique identifier of the budget proposal.
    /// @param proposer The address that submitted the proposal.
    /// @param amount The total amount requested in the budget.
    /// @param description A description of the budget proposal.
    event BudgetProposalSubmitted(
        uint256 proposalId,
        address indexed proposer,
        uint256 amount,
        string description
    );

    /// @dev Emitted when a budget proposal is approved or rejected.
    /// @param proposalId The unique identifier of the budget proposal.
    /// @param approver The address that approved or rejected the proposal.
    /// @param approved A boolean indicating whether the proposal was approved (true) or rejected (false).
    /// @param reason An optional reason for the approval/rejection.
    event BudgetProposalStatus(
        uint256 proposalId,
        address indexed approver,
        bool approved,
        string reason
    );

    /// @dev Emitted when a contract version is updated.
    /// @param contractAddress The address of the contract whose version was updated.
    /// @param newVersion The new version string.
    /// @param oldVersion The old version string.
    event ContractVersionUpdated(
        address indexed contractAddress,
        string newVersion,
        string oldVersion
    );

    /// @dev Emitted when a proxy contract is upgraded.
    /// @param proxyAddress The address of the proxy contract.
    /// @param newImplementation The address of the new implementation contract.
    /// @param oldImplementation The address of the old implementation contract.
    event ProxyUpgraded(
        address indexed proxyAddress,
        address indexed newImplementation,
        address indexed oldImplementation
    );

    /// @dev Emitted when a cross-chain message is sent.
    /// @param destinationChainId The ID of the destination blockchain.
    /// @param messageId The unique identifier of the cross-chain message.
    /// @param sender The address that sent the message on the source chain.
    /// @param payloadHash A hash of the message payload.
    event CrossChainMessageSent(
        uint256 destinationChainId,
        bytes32 messageId,
        address indexed sender,
        bytes32 payloadHash
    );

    /// @dev Emitted when a cross-chain message is received.
    /// @param sourceChainId The ID of the source blockchain.
    /// @param messageId The unique identifier of the cross-chain message.
    /// @param recipient The address that received the message on the destination chain.
    /// @param payloadHash A hash of the message payload.
    event CrossChainMessageReceived(
        uint256 sourceChainId,
        bytes32 messageId,
        address indexed recipient,
        bytes32 payloadHash
    );

    /// @dev Emitted when a cross-chain parameter synchronization occurs.
    /// @param chainId The ID of the chain where parameters were synced.
    /// @param parameterName The name of the parameter that was synced.
    /// @param syncedValue The value of the parameter after synchronization.
    /// @param syncedAt The timestamp of the synchronization.
    event CrossChainParameterSynced(
        uint256 chainId,
        string parameterName,
        bytes syncedValue,
        uint256 syncedAt
    );

    /// @dev Emitted when a reward is claimed.
    /// @param claimant The address that claimed the reward.
    /// @param amount The amount of reward claimed.
    /// @param token The address of the token claimed.
    /// @param rewardType A string describing the type of reward (e.g., "governance", "engagement", "voting").
    event RewardClaimed(
        address indexed claimant,
        uint256 amount,
        address indexed token,
        string rewardType
    );

    /// @dev Emitted when an incentive rate is updated.
    /// @param incentiveType A string describing the type of incentive (e.g., "voting", "delegation", "engagement").
    /// @param newRate The new rate of the incentive.
    /// @param oldRate The old rate of the incentive.
    /// @param updatedBy The address that updated the rate.
    event IncentiveRateUpdated(
        string incentiveType,
        uint256 newRate,
        uint256 oldRate,
        address indexed updatedBy
    );

    /// @dev Emitted when a new AI model is set for vote counting or other AI-related tasks.
    /// @param modelName The name or identifier of the new AI model.
    /// @param modelAddress The address of the AI model contract or oracle.
    /// @param setBy The address that set the AI model.
    event AIModelSet(
        string modelName,
        address indexed modelAddress,
        address indexed setBy
    );

    /// @dev Emitted when a potential fraud is detected by the AI system.
    /// @param detectionId The unique identifier for the detection event.
    /// @param detectedAddress The address identified as potentially fraudulent.
    /// @param fraudType A string describing the type of fraud detected.
    /// @param severity The severity level of the detected fraud.
    /// @param details A string containing additional details about the detection.
    event FraudDetected(
        uint256 detectionId,
        address indexed detectedAddress,
        string fraudType,
        string severity,
        string details
    );

    /// @dev Emitted when a new allocation strategy is set.
    /// @param strategyName The name of the new strategy.
    /// @param strategyAddress The address of the contract implementing the strategy.
    /// @param setBy The address that set the strategy.
    event AllocationStrategySet(
        string strategyName,
        address indexed strategyAddress,
        address indexed setBy
    );

    /// @dev Emitted when a new reporting period is set for financial reports.
    /// @param newPeriodStart The start timestamp of the new reporting period.
    /// @param newPeriodEnd The end timestamp of the new reporting period.
    /// @param setBy The address that set the reporting period.
    event ReportingPeriodSet(
        uint256 newPeriodStart,
        uint256 newPeriodEnd,
        address indexed setBy
    );

    /// @dev Emitted when a new compliance standard is set.
    /// @param standardName The name of the compliance standard.
    /// @param standardHash A hash or identifier of the standard's rules.
    /// @param setBy The address that set the standard.
    event ComplianceStandardSet(
        string standardName,
        bytes32 standardHash,
        address indexed setBy
    );

    /// @dev Emitted when a new validation rule is set for parameters.
    /// @param parameterName The name of the parameter the rule applies to.
    /// @param ruleDescription A description of the validation rule.
    /// @param setBy The address that set the rule.
    event ValidationRuleSet(
        string parameterName,
        string ruleDescription,
        address indexed setBy
    );

    /// @dev Emitted when a new emergency admin is set.
    /// @param newAdmin The address of the new emergency admin.
    /// @param oldAdmin The address of the old emergency admin.
    /// @param setBy The address that set the new admin.
    event EmergencyAdminSet(
        address indexed newAdmin,
        address indexed oldAdmin,
        address indexed setBy
    );

    /// @dev Emitted when the upgradeability status of a proxy is changed.
    /// @param proxyAddress The address of the proxy contract.
    /// @param isUpgradeable A boolean indicating if the proxy is now upgradeable.
    /// @param changedBy The address that changed the status.
    event UpgradeabilityStatusChanged(
        address indexed proxyAddress,
        bool isUpgradeable,
        address indexed changedBy
    );

    /// @dev Emitted when a new executor role is set for DAO proposals.
    /// @param executorAddress The address of the new executor.
    /// @param setBy The address that set the executor.
    event DAOExecutorSet(
        address indexed executorAddress,
        address indexed setBy
    );

    /// @dev Emitted when a new bridge address is set for cross-chain governance.
    /// @param bridgeName The name or identifier of the bridge.
    /// @param bridgeAddress The address of the bridge contract.
    /// @param setBy The address that set the bridge address.
    event CrossChainBridgeSet(
        string bridgeName,
        address indexed bridgeAddress,
        address indexed setBy
    );

    /// @dev Emitted when a new relayer address is set for cross-chain proposals.
    /// @param relayerAddress The address of the new relayer.
    /// @param setBy The address that set the relayer.
    event CrossChainRelayerSet(
        address indexed relayerAddress,
        address indexed setBy
    );

    /// @dev Emitted when a new DAO parameter is set.
    /// @param parameterName The name of the DAO parameter.
    /// @param oldValue The old value of the parameter.
    /// @param newValue The new value of the parameter.
    /// @param setBy The address that set the parameter.
    event DAOParameterSet(
        string parameterName,
        bytes oldValue,
        bytes newValue,
        address indexed setBy
    );

    /// @dev Emitted when a new token is added to the governance treasury.
    /// @param tokenAddress The address of the token.
    /// @param addedBy The address that added the token.
    event TreasuryTokenAdded(
        address indexed tokenAddress,
        address indexed addedBy
    );

    /// @dev Emitted when a token is removed from the governance treasury.
    /// @param tokenAddress The address of the token.
    /// @param removedBy The address that removed the token.
    event TreasuryTokenRemoved(
        address indexed tokenAddress,
        address indexed removedBy
    );

    /// @dev Emitted when a new policy is added to the governance system.
    /// @param policyName The name of the policy.
    /// @param policyAddress The address of the policy contract.
    /// @param addedBy The address that added the policy.
    event PolicyAdded(
        string policyName,
        address indexed policyAddress,
        address indexed addedBy
    );

    /// @dev Emitted when a policy is removed from the governance system.
    /// @param policyName The name of the policy.
    /// @param policyAddress The address of the policy contract.
    /// @param removedBy The address that removed the policy.
    event PolicyRemoved(
        string policyName,
        address indexed policyAddress,
        address indexed removedBy
    );

    /// @dev Emitted when a new voting strategy is set.
    /// @param strategyName The name of the voting strategy.
    /// @param strategyAddress The address of the contract implementing the strategy.
    /// @param setBy The address that set the strategy.
    event VotingStrategySet(
        string strategyName,
        address indexed strategyAddress,
        address indexed setBy
    );

    /// @dev Emitted when a new delegation strategy is set.
    /// @param strategyName The name of the delegation strategy.
    /// @param strategyAddress The address of the contract implementing the strategy.
    /// @param setBy The address that set the strategy.
    event DelegationStrategySet(
        string strategyName,
        address indexed strategyAddress,
        address indexed setBy
    );

    /// @dev Emitted when a new community poll is created.
    /// @param pollId The unique identifier of the poll.
    /// @param creator The address that created the poll.
    /// @param question The question of the poll.
    /// @param options The options for the poll.
    /// @param endTime The timestamp when the poll ends.
    event CommunityPollCreated(
        uint256 pollId,
        address indexed creator,
        string question,
        string[] options,
        uint256 endTime
    );

    /// @dev Emitted when a vote is cast on a community poll.
    /// @param pollId The unique identifier of the poll.
    /// @param voter The address that cast the vote.
    /// @param optionIndex The index of the chosen option.
    /// @param weight The voting weight of the voter.
    event CommunityPollVoteCast(
        uint256 pollId,
        address indexed voter,
        uint256 optionIndex,
        uint256 weight
    );

    /// @dev Emitted when the results of a community poll are retrieved.
    /// @param pollId The unique identifier of the poll.
    /// @param results An array of vote counts for each option.
    event CommunityPollResultsRetrieved(
        uint256 pollId,
        uint256[] results
    );

    /// @dev Emitted when a new NFT is minted as part of governance rewards or recognition.
    /// @param tokenId The unique identifier of the NFT.
    /// @param recipient The address receiving the NFT.
    /// @param tokenURI The URI pointing to the NFT's metadata.
    /// @param nftType A string describing the type of NFT (e.g., "governance badge", "contributor award").
    event NFTMinted(
        uint256 tokenId,
        address indexed recipient,
        string tokenURI,
        string nftType
    );

    /// @dev Emitted when an NFT is burned.
    /// @param tokenId The unique identifier of the NFT.
    /// @param burner The address that burned the NFT.
    event NFTBurned(
        uint256 tokenId,
        address indexed burner
    );

    /// @dev Emitted when a new staking pool is created.
    /// @param poolId The unique identifier of the staking pool.
    /// @param token The address of the token being staked.
    /// @param rewardToken The address of the reward token.
    /// @param startTime The start time of the staking period.
    /// @param endTime The end time of the staking period.
    event StakingPoolCreated(
        uint256 poolId,
        address indexed token,
        address indexed rewardToken,
        uint256 startTime,
        uint256 endTime
    );

    /// @dev Emitted when tokens are staked in a pool.
    /// @param poolId The unique identifier of the staking pool.
    /// @param staker The address that staked the tokens.
    /// @param amount The amount of tokens staked.
    event TokensStaked(
        uint256 poolId,
        address indexed staker,
        uint256 amount
    );

    /// @dev Emitted when staked tokens are withdrawn from a pool.
    /// @param poolId The unique identifier of the staking pool.
    /// @param staker The address that withdrew the tokens.
    /// @param amount The amount of tokens withdrawn.
    event TokensWithdrawn(
        uint256 poolId,
        address indexed staker,
        uint256 amount
    );

    /// @dev Emitted when staking rewards are claimed from a pool.
    /// @param poolId The unique identifier of the staking pool.
    /// @param staker The address that claimed the rewards.
    /// @param amount The amount of rewards claimed.
    event StakingRewardsClaimed(
        uint256 poolId,
        address indexed staker,
        uint256 amount
    );

    /// @dev Emitted when a new governance test is executed.
    /// @param testId The unique identifier of the test.
    /// @param tester The address that executed the test.
    /// @param status The status of the test (e.g., "passed", "failed").
    /// @param details A string containing additional details about the test result.
    event GovernanceTestExecuted(
        uint256 testId,
        address indexed tester,
        string status,
        string details
    );

    /// @dev Emitted when a new test suite is run.
    /// @param suiteId The unique identifier of the test suite.
    /// @param tester The address that initiated the test suite run.
    /// @param totalTests The total number of tests in the suite.
    /// @param passedTests The number of tests that passed.
    /// @param failedTests The number of tests that failed.
    /// @param runTime The total time taken to run the suite.
    event TestSuiteRun(
        uint256 suiteId,
        address indexed tester,
        uint256 totalTests,
        uint256 passedTests,
        uint256 failedTests,
        uint256 runTime
    );

    /// @dev Emitted when a new test case is added or updated.
    /// @param testCaseId The unique identifier of the test case.
    /// @param description A description of the test case.
    /// @param addedBy The address that added/updated the test case.
    event TestCaseUpdated(
        uint256 testCaseId,
        string description,
        address indexed addedBy
    );

    /// @dev Emitted when a new test environment is configured.
    /// @param envId The unique identifier of the environment.
    /// @param configHash A hash of the environment configuration.
    /// @param configuredBy The address that configured the environment.
    event TestEnvironmentConfigured(
        uint256 envId,
        bytes32 configHash,
        address indexed configuredBy
    );

    /// @dev Emitted when a new access control rule is set.
    /// @param ruleId The unique identifier of the rule.
    /// @param role The role associated with the rule.
    /// @param permission The permission granted or revoked.
    /// @param targetAddress The address to which the rule applies.
    /// @param setBy The address that set the rule.
    event AccessControlRuleSet(
        uint256 ruleId,
        string role,
        string permission,
        address indexed targetAddress,
        address indexed setBy
    );

    /// @dev Emitted when an access control rule is revoked.
    /// @param ruleId The unique identifier of the rule.
    /// @param revokedBy The address that revoked the rule.
    event AccessControlRuleRevoked(
        uint256 ruleId,
        address indexed revokedBy
    );

    /// @dev Emitted when a new permission is defined.
    /// @param permissionName The name of the new permission.
    /// @param description A description of the permission.
    /// @param definedBy The address that defined the permission.
    event PermissionDefined(
        string permissionName,
        string description,
        address indexed definedBy
    );

    /// @dev Emitted when a new role is defined.
    /// @param roleName The name of the new role.
    /// @param description A description of the role.
    /// @param definedBy The address that defined the role.
    event RoleDefined(
        string roleName,
        string description,
        address indexed definedBy
    );

    /// @dev Emitted when a new policy is activated.
    /// @param policyId The unique identifier of the policy.
    /// @param activatedBy The address that activated the policy.
    event PolicyActivated(
        uint256 policyId,
        address indexed activatedBy
    );

    /// @dev Emitted when a policy is deactivated.
    /// @param policyId The unique identifier of the policy.
    /// @param deactivatedBy The address that deactivated the policy.
    event PolicyDeactivated(
        uint256 policyId,
        address indexed deactivatedBy
    );

    /// @dev Emitted when a new policy parameter is set.
    /// @param policyId The unique identifier of the policy.
    /// @param parameterName The name of the parameter.
    /// @param oldValue The old value of the parameter.
    /// @param newValue The new value of the parameter.
    /// @param setBy The address that set the parameter.
    event PolicyParameterSet(
        uint256 policyId,
        string parameterName,
        bytes oldValue,
        bytes newValue,
        address indexed setBy
    );

    /// @dev Emitted when a new policy rule is added.
    /// @param policyId The unique identifier of the policy.
    /// @param ruleDescription A description of the new rule.
    /// @param addedBy The address that added the rule.
    event PolicyRuleAdded(
        uint256 policyId,
        string ruleDescription,
        address indexed addedBy
    );

    /// @dev Emitted when a policy rule is removed.
    /// @param policyId The unique identifier of the policy.
    /// @param ruleDescription A description of the removed rule.
    /// @param removedBy The address that removed the rule.
    event PolicyRuleRemoved(
        uint256 policyId,
        string ruleDescription,
        address indexed removedBy
    );

    /// @dev Emitted when a new policy is updated.
    /// @param policyId The unique identifier of the policy.
    /// @param updatedBy The address that updated the policy.
    event PolicyUpdated(
        uint256 policyId,
        address indexed updatedBy
    );

    /// @dev Emitted when a new policy is created.
    /// @param policyId The unique identifier of the policy.
    /// @param policyName The name of the policy.
    /// @param policyAddress The address of the policy contract.
    /// @param createdBy The address that created the policy.
    event PolicyCreated(
        uint256 policyId,
        string policyName,
        address indexed policyAddress,
        address indexed createdBy
    );

    /// @dev Emitted when a new policy is deprecated.
    /// @param policyId The unique identifier of the policy.
    /// @param deprecatedBy The address that deprecated the policy.
    event PolicyDeprecated(
        uint256 policyId,
        address indexed deprecatedBy
    );

    /// @dev Emitted when a new policy is proposed.
    /// @param policyId The unique identifier of the policy.
    /// @param proposedBy The address that proposed the policy.
    event PolicyProposed(
        uint256 policyId,
        address indexed proposedBy
    );

    /// @dev Emitted when a new policy is approved.
    /// @param policyId The unique identifier of the policy.
    /// @param approvedBy The address that approved the policy.
    event PolicyApproved(
        uint256 policyId,
        address indexed approvedBy
    );

    /// @dev Emitted when a new policy is rejected.
    /// @param policyId The unique identifier of the policy.
    /// @param rejectedBy The address that rejected the policy.
    event PolicyRejected(
        uint256 policyId,
        address indexed rejectedBy
    );

    /// @dev Emitted when a new policy is executed.
    /// @param policyId The unique identifier of the policy.
    /// @param executedBy The address that executed the policy.
    event PolicyExecuted(
        uint256 policyId,
        address indexed executedBy
    );

    /// @dev Emitted when a new policy is cancelled.
    /// @param policyId The unique identifier of the policy.
    /// @param cancelledBy The address that cancelled the policy.
    event PolicyCancelled(
        uint256 policyId,
        address indexed cancelledBy
    );

    /// @dev Emitted when a new policy is paused.
    /// @param policyId The unique identifier of the policy.
    /// @param pausedBy The address that paused the policy.
    event PolicyPaused(
        uint256 policyId,
        address indexed pausedBy
    );

    /// @dev Emitted when a new policy is unpaused.
    /// @param policyId The unique identifier of the policy.
    /// @param unpausedBy The address that unpaused the policy.
    event PolicyUnpaused(
        uint256 policyId,
        address indexed unpausedBy
    );

    /// @dev Emitted when a new policy is re-enabled.
    /// @param policyId The unique identifier of the policy.
    /// @param reEnabledBy The address that re-enabled the policy.
    event PolicyReEnabled(
        uint256 policyId,
        address indexed reEnabledBy
    );

    /// @dev Emitted when a new policy is disabled.
    /// @param policyId The unique identifier of the policy.
    /// @param disabledBy The address that disabled the policy.
    event PolicyDisabled(
        uint256 policyId,
        address indexed disabledBy
    );

    /// @dev Emitted when a new policy is enabled.
    /// @param policyId The unique identifier of the policy.
    /// @param enabledBy The address that enabled the policy.
    event PolicyEnabled(
        uint256 policyId,
        address indexed enabledBy
    );

    /// @dev Emitted when a new policy is activated.
    /// @param policyId The unique identifier of the policy.
    /// @param activatedBy The address that activated the policy.
    event PolicyActivatedAgain(
        uint256 policyId,
        address indexed activatedBy
    );

    /// @dev Emitted when a new policy is deactivated.
    /// @param policyId The unique identifier of the policy.
    /// @param deactivatedBy The address that deactivated the policy.
    event PolicyDeactivatedAgain(
        uint256 policyId,
        address indexed deactivatedBy
    );

    /// @dev Emitted when a new policy is updated.
    /// @param policyId The unique identifier of the policy.
    /// @param updatedBy The address that updated the policy.
    event PolicyUpdatedAgain(
        uint256 policyId,
        address indexed updatedBy
    );

    /// @dev Emitted when a new policy is created.
    /// @param policyId The unique identifier of the policy.
    /// @param policyName The name of the policy.
    /// @param policyAddress The address of the policy contract.
    /// @param createdBy The address that created the policy.
    event PolicyCreatedAgain(
        uint256 policyId,
        string policyName,
        address indexed policyAddress,
        address indexed createdBy
    );

    /// @dev Emitted when a new policy is deprecated.
    /// @param policyId The unique identifier of the policy.
    /// @param deprecatedBy The address that deprecated the policy.
    event PolicyDeprecatedAgain(
        uint256 policyId,
        address indexed deprecatedBy
    );

    /// @dev Emitted when a new policy is proposed.
    /// @param policyId The unique identifier of the policy.
    /// @param proposedBy The address that proposed the policy.
    event PolicyProposedAgain(
        uint256 policyId,
        address indexed proposedBy
    );

    /// @dev Emitted when a new policy is approved.
    /// @param policyId The unique identifier of the policy.
    /// @param approvedBy The address that approved the policy.
    event PolicyApprovedAgain(
        uint256 policyId,
        address indexed approvedBy
    );
}