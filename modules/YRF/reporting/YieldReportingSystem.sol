// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IYieldReportingSystem
 * @dev interface for the YieldReportingSystem contract.
 */
interface IYieldReportingSystem {
    /**
     * @dev Error indicating that the caller is not authorized to perform the action.
     */
    error Unauthorized();

    /**
     * @dev Error indicating that a report with the given ID does not exist.
     * @param reportId The ID of the non-existent report.
     */
    error ReportNotFound(uint256 reportId);

    /**
     * @dev Error indicating that a report with the given ID is already finalized.
     * @param reportId The ID of the finalized report.
     */
    error ReportAlreadyFinalized(uint256 reportId);

    /**
     * @dev Emitted when a new yield report is initiated.
     * @param reportId The ID of the initiated report.
     * @param reporter The address of the entity initiating the report.
     * @param periodStart The start timestamp of the reporting period.
     * @param periodEnd The end timestamp of the reporting period.
     * @param reportType A string describing the type of report (e.g., "Daily", "Weekly", "Monthly").
     */
    event ReportInitiated(uint256 reportId, address reporter, uint256 periodStart, uint256 periodEnd, string reportType);

    /**
     * @dev Emitted when yield data is added to an existing report.
     * @param reportId The ID of the report.
     * @param dataKey A key describing the data point (e.g., "totalYield", "APY").
     * @param value The value of the data point.
     * @param timestamp The timestamp when the data was added.
     */
    event ReportDataAdded(uint256 reportId, string dataKey, uint256 value, uint256 timestamp);

    /**
     * @dev Emitted when a yield report is finalized.
     * @param reportId The ID of the finalized report.
     * @param finalizationTime The timestamp when the report was finalized.
     * @param summary A summary of the finalized report.
     */
    event ReportFinalized(uint256 reportId, uint256 finalizationTime, string summary);

    /**
     * @dev Initiates a new yield report for a specified period.
     * @param periodStart The start timestamp of the reporting period.
     * @param periodEnd The end timestamp of the reporting period.
     * @param reportType A string describing the type of report (e.g., "Daily", "Weekly", "Monthly").
     * @return The unique ID assigned to the initiated report.
     */
    function initiateReport(uint256 periodStart, uint256 periodEnd, string calldata reportType) external returns (uint256);

    /**
     * @dev Adds a data point to an existing yield report.
     * @param reportId The ID of the report to add data to.
     * @param dataKey A key describing the data point (e.g., "totalYield", "APY").
     * @param value The value of the data point.
     */
    function addReportData(uint256 reportId, string calldata dataKey, uint256 value) external;

    /**
     * @dev Finalizes an existing yield report.
     * @param reportId The ID of the report to finalize.
     * @param summary A summary of the finalized report.
     */
    function finalizeReport(uint256 reportId, string calldata summary) external;

    /**
     * @dev Retrieves details of a specific yield report.
     * @param reportId The ID of the report.
     * @return reporter The address of the entity initiating the report.
     * @return periodStart The start timestamp of the reporting period.
     * @return periodEnd The end timestamp of the reporting period.
     * @return reportType The type of report.
     * @return isFinalized Whether the report is finalized.
     * @return finalizationTime If finalized, the timestamp of finalization.
     * @return summary If finalized, a summary of the report.
     */
    function getReportDetails(uint256 reportId) external view returns (
        address reporter,
        uint256 periodStart,
        uint256 periodEnd,
        string memory reportType,
        bool isFinalized,
        uint256 finalizationTime,
        string memory summary
    );

    /**
     * @dev Retrieves all data points for a specific yield report.
     * @param reportId The ID of the report.
     * @return dataKeys An array of data keys.
     * @return values An array of corresponding values.
     * @return timestamps An array of corresponding timestamps.
     */
    function getReportData(uint256 reportId) external view returns (
        string[] memory dataKeys,
        uint256[] memory values,
        uint256[] memory timestamps
    );

    /**
     * @dev Retrieves a list of all report IDs.
     * @return An array of all report IDs.
     */
    function getAllReportIds() external view returns (uint256[] memory);

    /**
     * @dev Retrieves a list of finalized report IDs.
     * @return An array of finalized report IDs.
     */
    function getFinalizedReportIds() external view returns (uint256[] memory);
}

/**
 * @title YieldReportingSystem
 * @dev Manages and tracks various yield reports within the DAO.
 *      Allows for initiation, data addition, and finalization of yield reports.
 */
contract YieldReportingSystem is IYieldReportingSystem {
    // State variables
    address public immutable i_owner;
    uint256 private s_nextReportId;

    struct Report {
        address reporter;
        uint256 periodStart;
        uint256 periodEnd;
        string reportType;
        bool isFinalized;
        uint256 finalizationTime;
        string summary;
        string[] dataKeys;
        uint256[] values;
        uint256[] timestamps;
    }

    mapping(uint256 => Report) private s_reports;
    uint256[] private s_allReportIds;

    // Constructor
    constructor() {
        i_owner = msg.sender;
        s_nextReportId = 1;
    }

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Unauthorized();
        }
        _;
    }

    /**
     * @inheritdoc IYieldReportingSystem
     */
    function initiateReport(uint256 periodStart, uint256 periodEnd, string calldata reportType) external onlyOwner returns (uint256) {
        require(periodStart < periodEnd, "Invalid period: start >= end");
        require(bytes(reportType).length > 0, "Report type cannot be empty");

        uint256 reportId = s_nextReportId++;
        s_reports[reportId] = Report({
            reporter: msg.sender,
            periodStart: periodStart,
            periodEnd: periodEnd,
            reportType: reportType,
            isFinalized: false,
            finalizationTime: 0,
            summary: "",
            dataKeys: new string[](0),
            values: new uint256[](0),
            timestamps: new uint256[](0)
        });
        s_allReportIds.push(reportId);
        emit ReportInitiated(reportId, msg.sender, periodStart, periodEnd, reportType);
        return reportId;
    }

    /**
     * @inheritdoc IYieldReportingSystem
     */
    function addReportData(uint256 reportId, string calldata dataKey, uint256 value) external onlyOwner {
        Report storage report = s_reports[reportId];
        if (report.reporter == address(0)) {
            revert ReportNotFound(reportId);
        }
        if (report.isFinalized) {
            revert ReportAlreadyFinalized(reportId);
        }
        require(bytes(dataKey).length > 0, "Data key cannot be empty");

        report.dataKeys.push(dataKey);
        report.values.push(value);
        report.timestamps.push(block.timestamp);
        emit ReportDataAdded(reportId, dataKey, value, block.timestamp);
    }

    /**
     * @inheritdoc IYieldReportingSystem
     */
    function finalizeReport(uint256 reportId, string calldata summary) external onlyOwner {
        Report storage report = s_reports[reportId];
        if (report.reporter == address(0)) {
            revert ReportNotFound(reportId);
        }
        if (report.isFinalized) {
            revert ReportAlreadyFinalized(reportId);
        }
        require(bytes(summary).length > 0, "Summary cannot be empty");

        report.isFinalized = true;
        report.finalizationTime = block.timestamp;
        report.summary = summary;
        emit ReportFinalized(reportId, block.timestamp, summary);
    }

    /**
     * @inheritdoc IYieldReportingSystem
     */
    function getReportDetails(uint256 reportId) external view returns (
        address reporter,
        uint256 periodStart,
        uint256 periodEnd,
        string memory reportType,
        bool isFinalized,
        uint256 finalizationTime,
        string memory summary
    ) {
        Report storage report = s_reports[reportId];
        if (report.reporter == address(0)) {
            revert ReportNotFound(reportId);
        }
        return (
            report.reporter,
            report.periodStart,
            report.periodEnd,
            report.reportType,
            report.isFinalized,
            report.finalizationTime,
            report.summary
        );
    }

    /**
     * @inheritdoc IYieldReportingSystem
     */
    function getReportData(uint256 reportId) external view returns (
        string[] memory dataKeys,
        uint256[] memory values,
        uint256[] memory timestamps
    ) {
        Report storage report = s_reports[reportId];
        if (report.reporter == address(0)) {
            revert ReportNotFound(reportId);
        }
        return (report.dataKeys, report.values, report.timestamps);
    }

    /**
     * @inheritdoc IYieldReportingSystem
     */
    function getAllReportIds() external view returns (uint256[] memory) {
        return s_allReportIds;
    }

    /**
     * @inheritdoc IYieldReportingSystem
     */
    function getFinalizedReportIds() external view returns (uint256[] memory) {
        uint256[] memory finalizedIds = new uint256[](s_allReportIds.length);
        uint256 count = 0;
        for (uint256 i = 0; i < s_allReportIds.length; i++) {
            uint256 reportId = s_allReportIds[i];
            if (s_reports[reportId].isFinalized) {
                finalizedIds[count] = reportId;
                count++;
            }
        }
        assembly {
            mstore(finalizedIds, count)
        }
        return finalizedIds;
    }
}