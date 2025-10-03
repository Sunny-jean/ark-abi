// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IYieldAuditSystem
 * @dev interface for the YieldAuditSystem contract.
 */
interface IYieldAuditSystem {
    /**
     * @dev Error indicating that the caller is not authorized to perform the action.
     */
    error Unauthorized();

    /**
     * @dev Error indicating that an audit with the given ID does not exist.
     * @param auditId The ID of the non-existent audit.
     */
    error AuditNotFound(uint256 auditId);

    /**
     * @dev Error indicating that an audit with the given ID is already completed.
     * @param auditId The ID of the completed audit.
     */
    error AuditAlreadyCompleted(uint256 auditId);

    /**
     * @dev Emitted when a new yield audit is initiated.
     * @param auditId The ID of the initiated audit.
     * @param auditor The address of the auditor.
     * @param startTime The timestamp when the audit started.
     * @param endTime The scheduled timestamp for audit completion.
     * @param description A description of the audit scope.
     */
    event AuditInitiated(uint256 auditId, address auditor, uint256 startTime, uint256 endTime, string description);

    /**
     * @dev Emitted when a yield audit is completed.
     * @param auditId The ID of the completed audit.
     * @param completionTime The timestamp when the audit was completed.
     * @param findings A summary of audit findings.
     * @param isCompliant Whether the yield operations were found compliant.
     */
    event AuditCompleted(uint256 auditId, uint256 completionTime, string findings, bool isCompliant);

    /**
     * @dev Emitted when an audit's scheduled end time is extended.
     * @param auditId The ID of the audit.
     * @param newEndTime The new scheduled end time.
     */
    event AuditExtended(uint256 auditId, uint256 newEndTime);

    /**
     * @dev Initiates a new yield audit.
     * @param auditor The address of the auditor.
     * @param endTime The scheduled timestamp for audit completion.
     * @param description A description of the audit scope.
     * @return The unique ID assigned to the initiated audit.
     */
    function initiateAudit(address auditor, uint256 endTime, string calldata description) external returns (uint256);

    /**
     * @dev Completes an ongoing yield audit.
     * @param auditId The ID of the audit to complete.
     * @param findings A summary of audit findings.
     * @param isCompliant Whether the yield operations were found compliant.
     */
    function completeAudit(uint256 auditId, string calldata findings, bool isCompliant) external;

    /**
     * @dev Extends the scheduled end time of an ongoing audit.
     * @param auditId The ID of the audit to extend.
     * @param newEndTime The new scheduled end time.
     */
    function extendAudit(uint256 auditId, uint256 newEndTime) external;

    /**
     * @dev Retrieves details of a specific yield audit.
     * @param auditId The ID of the audit.
     * @return auditor The address of the auditor.
     * @return startTime The timestamp when the audit started.
     * @return endTime The scheduled timestamp for audit completion.
     * @return description A description of the audit scope.
     * @return isCompleted Whether the audit is completed.
     * @return findings If completed, a summary of audit findings.
     * @return isCompliant If completed, whether the yield operations were found compliant.
     */
    function getAuditDetails(uint256 auditId) external view returns (
        address auditor,
        uint256 startTime,
        uint256 endTime,
        string memory description,
        bool isCompleted,
        string memory findings,
        bool isCompliant
    );

    /**
     * @dev Retrieves a list of all audit IDs.
     * @return An array of all audit IDs.
     */
    function getAllAuditIds() external view returns (uint256[] memory);

    /**
     * @dev Retrieves a list of ongoing audit IDs.
     * @return An array of ongoing audit IDs.
     */
    function getOngoingAuditIds() external view returns (uint256[] memory);

    /**
     * @dev Retrieves a list of completed audit IDs.
     * @return An array of completed audit IDs.
     */
    function getCompletedAuditIds() external view returns (uint256[] memory);
}

/**
 * @title YieldAuditSystem
 * @dev Manages and tracks yield audits within the DAO.
 *      Allows for initiation, completion, and extension of yield audits.
 */
contract YieldAuditSystem is IYieldAuditSystem {
    // State variables
    address public immutable i_owner;
    uint256 private s_nextAuditId;

    struct Audit {
        address auditor;
        uint256 startTime;
        uint256 endTime;
        string description;
        bool isCompleted;
        string findings;
        bool isCompliant;
    }

    mapping(uint256 => Audit) private s_audits;
    uint256[] private s_allAuditIds;

    // Constructor
    constructor() {
        i_owner = msg.sender;
        s_nextAuditId = 1;
    }

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Unauthorized();
        }
        _;
    }

    /**
     * @inheritdoc IYieldAuditSystem
     */
    function initiateAudit(address auditor, uint256 endTime, string calldata description) external onlyOwner returns (uint256) {
        require(auditor != address(0), "Invalid auditor address");
        require(endTime > block.timestamp, "End time must be in the future");
        require(bytes(description).length > 0, "Description cannot be empty");

        uint256 auditId = s_nextAuditId++;
        s_audits[auditId] = Audit(auditor, block.timestamp, endTime, description, false, "", false);
        s_allAuditIds.push(auditId);
        emit AuditInitiated(auditId, auditor, block.timestamp, endTime, description);
        return auditId;
    }

    /**
     * @inheritdoc IYieldAuditSystem
     */
    function completeAudit(uint256 auditId, string calldata findings, bool isCompliant) external {
        Audit storage audit = s_audits[auditId];
        if (audit.auditor == address(0)) {
            revert AuditNotFound(auditId);
        }
        if (audit.isCompleted) {
            revert AuditAlreadyCompleted(auditId);
        }
        require(msg.sender == audit.auditor || msg.sender == i_owner, "Only auditor or owner can complete audit");
        require(bytes(findings).length > 0, "Findings cannot be empty");

        audit.isCompleted = true;
        audit.findings = findings;
        audit.isCompliant = isCompliant;
        emit AuditCompleted(auditId, block.timestamp, findings, isCompliant);
    }

    /**
     * @inheritdoc IYieldAuditSystem
     */
    function extendAudit(uint256 auditId, uint256 newEndTime) external onlyOwner {
        Audit storage audit = s_audits[auditId];
        if (audit.auditor == address(0)) {
            revert AuditNotFound(auditId);
        }
        if (audit.isCompleted) {
            revert AuditAlreadyCompleted(auditId);
        }
        require(newEndTime > audit.endTime, "New end time must be after current end time");

        audit.endTime = newEndTime;
        emit AuditExtended(auditId, newEndTime);
    }

    /**
     * @inheritdoc IYieldAuditSystem
     */
    function getAuditDetails(uint256 auditId) external view returns (
        address auditor,
        uint256 startTime,
        uint256 endTime,
        string memory description,
        bool isCompleted,
        string memory findings,
        bool isCompliant
    ) {
        Audit storage audit = s_audits[auditId];
        if (audit.auditor == address(0)) {
            revert AuditNotFound(auditId);
        }
        return (
            audit.auditor,
            audit.startTime,
            audit.endTime,
            audit.description,
            audit.isCompleted,
            audit.findings,
            audit.isCompliant
        );
    }

    /**
     * @inheritdoc IYieldAuditSystem
     */
    function getAllAuditIds() external view returns (uint256[] memory) {
        return s_allAuditIds;
    }

    /**
     * @inheritdoc IYieldAuditSystem
     */
    function getOngoingAuditIds() external view returns (uint256[] memory) {
        uint256[] memory ongoingIds = new uint256[](s_allAuditIds.length);
        uint256 count = 0;
        for (uint256 i = 0; i < s_allAuditIds.length; i++) {
            uint256 auditId = s_allAuditIds[i];
            if (!s_audits[auditId].isCompleted && s_audits[auditId].endTime > block.timestamp) {
                ongoingIds[count] = auditId;
                count++;
            }
        }
        assembly {
            mstore(ongoingIds, count)
        }
        return ongoingIds;
    }

    /**
     * @inheritdoc IYieldAuditSystem
     */
    function getCompletedAuditIds() external view returns (uint256[] memory) {
        uint256[] memory completedIds = new uint256[](s_allAuditIds.length);
        uint256 count = 0;
        for (uint256 i = 0; i < s_allAuditIds.length; i++) {
            uint256 auditId = s_allAuditIds[i];
            if (s_audits[auditId].isCompleted) {
                completedIds[count] = auditId;
                count++;
            }
        }
        assembly {
            mstore(completedIds, count)
        }
        return completedIds;
    }
}