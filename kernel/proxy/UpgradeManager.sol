// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/// @title Upgrade Manager
/// @notice Manages the upgrade process for proxies in the system
contract UpgradeManager {
    // ============================================================================================//
    //                                        EVENTS                                               //
    // ============================================================================================//

    event UpgradeProposed(address indexed proxy, address indexed implementation, uint256 indexed proposalId);
    event UpgradeApproved(address indexed proxy, address indexed implementation, uint256 indexed proposalId);
    event UpgradeRejected(address indexed proxy, address indexed implementation, uint256 indexed proposalId);
    event UpgradeExecuted(address indexed proxy, address indexed oldImplementation, address indexed newImplementation);
    event ApproverAdded(address indexed approver);
    event ApproverRemoved(address indexed approver);
    event ApprovalThresholdChanged(uint256 oldThreshold, uint256 newThreshold);

    // ============================================================================================//
    //                                        ERRORS                                               //
    // ============================================================================================//

    error UpgradeManager_OnlyAdmin(address caller_);
    error UpgradeManager_OnlyApprover(address caller_);
    error UpgradeManager_InvalidAddress(address addr_);
    error UpgradeManager_ProposalNotFound(uint256 proposalId_);
    error UpgradeManager_ProposalAlreadyApproved(uint256 proposalId_);
    error UpgradeManager_ProposalAlreadyRejected(uint256 proposalId_);
    error UpgradeManager_ProposalNotApproved(uint256 proposalId_);
    error UpgradeManager_ApproverAlreadyExists(address approver_);
    error UpgradeManager_ApproverDoesNotExist(address approver_);
    error UpgradeManager_InvalidThreshold(uint256 threshold_);
    error UpgradeManager_AlreadyApproved(address approver_, uint256 proposalId_);
    error UpgradeManager_InsufficientApprovals(uint256 approvals_, uint256 required_);

    // ============================================================================================//
    //                                        STRUCTS                                              //
    // ============================================================================================//

    enum ProposalStatus {
        Pending,
        Approved,
        Rejected,
        Executed
    }

    struct UpgradeProposal {
        uint256 id;
        address proxy;
        address implementation;
        ProposalStatus status;
        uint256 approvalCount;
        uint256 proposedAt;
        uint256 executedAt;
        string description;
    }

    // ============================================================================================//
    //                                     STATE VARIABLES                                         //
    // ============================================================================================//

    address public admin;
    address public proxyRegistry;
    
    // Upgrade proposals
    mapping(uint256 => UpgradeProposal) public proposals;
    uint256 public nextProposalId;
    
    // Approvers
    mapping(address => bool) public isApprover;
    address[] public approvers;
    uint256 public approvalThreshold;
    
    // Approvals tracking
    mapping(uint256 => mapping(address => bool)) public hasApproved;
    
    // Proxy upgrade history
    mapping(address => uint256[]) public proxyUpgradeHistory;

    // ============================================================================================//
    //                                       MODIFIERS                                             //
    // ============================================================================================//

    modifier onlyAdmin() {
        if (msg.sender != admin) revert UpgradeManager_OnlyAdmin(msg.sender);
        _;
    }

    modifier onlyApprover() {
        if (!isApprover[msg.sender]) revert UpgradeManager_OnlyApprover(msg.sender);
        _;
    }

    modifier proposalExists(uint256 proposalId_) {
        if (proposalId_ >= nextProposalId || proposals[proposalId_].id != proposalId_) {
            revert UpgradeManager_ProposalNotFound(proposalId_);
        }
        _;
    }

    // ============================================================================================//
    //                                      CONSTRUCTOR                                            //
    // ============================================================================================//

    constructor(address admin_, address proxyRegistry_, address[] memory initialApprovers_, uint256 threshold_) {
        if (admin_ == address(0)) revert UpgradeManager_InvalidAddress(admin_);
        if (proxyRegistry_ == address(0)) revert UpgradeManager_InvalidAddress(proxyRegistry_);
        if (threshold_ == 0 || threshold_ > initialApprovers_.length) {
            revert UpgradeManager_InvalidThreshold(threshold_);
        }
        
        admin = admin_;
        proxyRegistry = proxyRegistry_;
        approvalThreshold = threshold_;
        
        // Add initial approvers
        for (uint256 i = 0; i < initialApprovers_.length; i++) {
            address approver = initialApprovers_[i];
            if (approver == address(0)) revert UpgradeManager_InvalidAddress(approver);
            if (isApprover[approver]) continue; // Skip duplicates
            
            isApprover[approver] = true;
            approvers.push(approver);
            
            emit ApproverAdded(approver);
        }
    }

    // ============================================================================================//
    //                                    EXTERNAL FUNCTIONS                                       //
    // ============================================================================================//

    /// @notice Propose an upgrade for a proxy
    /// @param proxy_ The proxy address
    /// @param implementation_ The new implementation address
    /// @param description_ A description of the upgrade
    /// @return proposalId The ID of the created proposal
    function proposeUpgrade(
        address proxy_,
        address implementation_,
        string calldata description_
    ) external onlyApprover returns (uint256) {
        if (proxy_ == address(0)) revert UpgradeManager_InvalidAddress(proxy_);
        if (implementation_ == address(0)) revert UpgradeManager_InvalidAddress(implementation_);
        
        uint256 proposalId = nextProposalId++;
        
        // Create proposal
        proposals[proposalId] = UpgradeProposal({
            id: proposalId,
            proxy: proxy_,
            implementation: implementation_,
            status: ProposalStatus.Pending,
            approvalCount: 0,
            proposedAt: block.timestamp,
            executedAt: 0,
            description: description_
        });
        
        // Add to proxy upgrade history
        proxyUpgradeHistory[proxy_].push(proposalId);
        
        emit UpgradeProposed(proxy_, implementation_, proposalId);
        
        return proposalId;
    }

    /// @notice Approve an upgrade proposal
    /// @param proposalId_ The proposal ID
    function approveUpgrade(uint256 proposalId_) external onlyApprover proposalExists(proposalId_) {
        UpgradeProposal storage proposal = proposals[proposalId_];
        
        // Check proposal status
        if (proposal.status != ProposalStatus.Pending) {
            if (proposal.status == ProposalStatus.Approved) {
                revert UpgradeManager_ProposalAlreadyApproved(proposalId_);
            } else if (proposal.status == ProposalStatus.Rejected) {
                revert UpgradeManager_ProposalAlreadyRejected(proposalId_);
            }
        }
        
        // Check if already approved by this approver
        if (hasApproved[proposalId_][msg.sender]) {
            revert UpgradeManager_AlreadyApproved(msg.sender, proposalId_);
        }
        
        // Record approval
        hasApproved[proposalId_][msg.sender] = true;
        proposal.approvalCount++;
        
        // Check if threshold reached
        if (proposal.approvalCount >= approvalThreshold) {
            proposal.status = ProposalStatus.Approved;
            emit UpgradeApproved(proposal.proxy, proposal.implementation, proposalId_);
        }
    }

    /// @notice Reject an upgrade proposal
    /// @param proposalId_ The proposal ID
    function rejectUpgrade(uint256 proposalId_) external onlyApprover proposalExists(proposalId_) {
        UpgradeProposal storage proposal = proposals[proposalId_];
        
        // Check proposal status
        if (proposal.status != ProposalStatus.Pending) {
            if (proposal.status == ProposalStatus.Approved) {
                revert UpgradeManager_ProposalAlreadyApproved(proposalId_);
            } else if (proposal.status == ProposalStatus.Rejected) {
                revert UpgradeManager_ProposalAlreadyRejected(proposalId_);
            }
        }
        
        // Reject proposal
        proposal.status = ProposalStatus.Rejected;
        
        emit UpgradeRejected(proposal.proxy, proposal.implementation, proposalId_);
    }

    /// @notice Execute an approved upgrade
    /// @param proposalId_ The proposal ID
    function executeUpgrade(uint256 proposalId_) external onlyAdmin proposalExists(proposalId_) {
        UpgradeProposal storage proposal = proposals[proposalId_];
        
        // Check proposal status
        if (proposal.status != ProposalStatus.Approved) {
            revert UpgradeManager_ProposalNotApproved(proposalId_);
        }
        
        // Mark as executed
        proposal.status = ProposalStatus.Executed;
        proposal.executedAt = block.timestamp;
        
        // this would call the proxy to update its implementation
        //  we just emit the event
        address oldImplementation = address(0); // this would be fetched from the proxy
        
        emit UpgradeExecuted(proposal.proxy, oldImplementation, proposal.implementation);
    }

    /// @notice Add a new approver
    /// @param approver_ The approver address
    function addApprover(address approver_) external onlyAdmin {
        if (approver_ == address(0)) revert UpgradeManager_InvalidAddress(approver_);
        if (isApprover[approver_]) revert UpgradeManager_ApproverAlreadyExists(approver_);
        
        isApprover[approver_] = true;
        approvers.push(approver_);
        
        emit ApproverAdded(approver_);
    }

    /// @notice Remove an approver
    /// @param approver_ The approver address
    function removeApprover(address approver_) external onlyAdmin {
        if (!isApprover[approver_]) revert UpgradeManager_ApproverDoesNotExist(approver_);
        
        // Remove from mapping
        isApprover[approver_] = false;
        
        // Remove from array
        uint256 length = approvers.length;
        for (uint256 i = 0; i < length; i++) {
            if (approvers[i] == approver_) {
                approvers[i] = approvers[length - 1];
                approvers.pop();
                break;
            }
        }
        
        // Ensure threshold is still valid
        if (approvalThreshold > approvers.length) {
            approvalThreshold = approvers.length;
        }
        
        emit ApproverRemoved(approver_);
    }

    /// @notice Set the approval threshold
    /// @param threshold_ The new threshold
    function setApprovalThreshold(uint256 threshold_) external onlyAdmin {
        if (threshold_ == 0 || threshold_ > approvers.length) {
            revert UpgradeManager_InvalidThreshold(threshold_);
        }
        
        uint256 oldThreshold = approvalThreshold;
        approvalThreshold = threshold_;
        
        emit ApprovalThresholdChanged(oldThreshold, threshold_);
    }

    /// @notice Get all approvers
    /// @return Array of approver addresses
    function getAllApprovers() external view returns (address[] memory) {
        return approvers;
    }

    /// @notice Get approver count
    /// @return The number of approvers
    function getApproverCount() external view returns (uint256) {
        return approvers.length;
    }

    /// @notice Get upgrade history for a proxy
    /// @param proxy_ The proxy address
    /// @return Array of proposal IDs for the proxy
    function getUpgradeHistory(address proxy_) external view returns (uint256[] memory) {
        return proxyUpgradeHistory[proxy_];
    }

    /// @notice Get detailed proposal information
    /// @param proposalId_ The proposal ID
    /// @return id The proposal ID
    /// @return proxy The proxy address
    /// @return implementation The new implementation address
    /// @return status The proposal status
    /// @return approvalCount The number of approvals
    /// @return proposedAt When the proposal was created
    /// @return executedAt When the proposal was executed
    /// @return description The proposal description
    function getProposalDetails(uint256 proposalId_) external view proposalExists(proposalId_) returns (
        uint256 id,
        address proxy,
        address implementation,
        ProposalStatus status,
        uint256 approvalCount,
        uint256 proposedAt,
        uint256 executedAt,
        string memory description
    ) {
        UpgradeProposal memory proposal = proposals[proposalId_];
        return (
            proposal.id,
            proposal.proxy,
            proposal.implementation,
            proposal.status,
            proposal.approvalCount,
            proposal.proposedAt,
            proposal.executedAt,
            proposal.description
        );
    }

    /// @notice Check if an approver has approved a proposal
    /// @param proposalId_ The proposal ID
    /// @param approver_ The approver address
    /// @return Whether the approver has approved the proposal
    function hasApprovedProposal(uint256 proposalId_, address approver_) external view proposalExists(proposalId_) returns (bool) {
        return hasApproved[proposalId_][approver_];
    }
}