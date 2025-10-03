// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IRunwayBudgetPlanner.sol";
import "../interfaces/IEfficiencyOptimizer.sol";
import "../interfaces/IRunwayCostManager.sol";
import "../interfaces/IRunwayComplianceChecker.sol";
import "../interfaces/IRiskExposureAnalyzer.sol";
import "../interfaces/IRiskMitigationManager.sol";
import "../interfaces/IRunwayAuditLog.sol";
import "../interfaces/IRunwayPerformanceReporter.sol";
import "../interfaces/IRunwayDashboardUpdater.sol";
import "../interfaces/IRunwayDataAggregator.sol";
import "../interfaces/IRunwayEventLogger.sol";
import "../interfaces/IPredictiveAnalyticsModel.sol";
import "../interfaces/IRunwayAlertManager.sol";
import "../interfaces/IThresholdNotifier.sol";
import "../interfaces/INotificationDispatcher.sol";
import "../interfaces/IRealTimeRunwayMonitor.sol";
import "../interfaces/IPeriodicUpdateNotifier.sol";
import "../interfaces/IRebondingStrategyManager.sol";
import "../interfaces/IRunwayExtensionStrategy.sol";
import "../interfaces/IIncentiveAdjustmentStrategy.sol";
import "../interfaces/ITreasuryManagementStrategy.sol";
import "../interfaces/IRunwayGovernanceModule.sol";
import "../interfaces/IVotingEscrowIntegration.sol";
import "../interfaces/IParameterController.sol";
import "../interfaces/IEmergencyBrakeModule.sol";
import "../interfaces/IAccessControlManager.sol";

interface IRunwayCore {
    event RunwayCoreInitialized(address indexed owner);
    event ModuleRegistered(string indexed moduleName, address indexed moduleAddress);

    error ModuleNotFound(string moduleName);
    error InvalidModuleAddress(address moduleAddress);

    function initializeRunwayCore() external;
    function registerModule(string calldata _moduleName, address _moduleAddress) external;
    function getModuleAddress(string calldata _moduleName) external view returns (address);
}

contract RunwayCore is IRunwayCore, Ownable {
    mapping(string => address) private s_modules;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function initializeRunwayCore() external onlyOwner {
        emit RunwayCoreInitialized(owner());
    }

    function registerModule(string calldata _moduleName, address _moduleAddress) external onlyOwner {
        require(_moduleAddress != address(0), "Invalid module address.");
        s_modules[_moduleName] = _moduleAddress;
        emit ModuleRegistered(_moduleName, _moduleAddress);
    }

    function getModuleAddress(string calldata _moduleName) external view returns (address) {
        address moduleAddr = s_modules[_moduleName];
        require(moduleAddr != address(0), "Module not found.");
        return moduleAddr;
    }

    // Functions to interact with registered modules (examples)

    function planBudget(uint256 _amount, uint256 _duration) external returns (uint256 budgetId) {
        IRunwayBudgetPlanner planner = IRunwayBudgetPlanner(this.getModuleAddress("RunwayBudgetPlanner"));
        return planner.planBudget(_amount, _duration);
    }

    function optimizeEfficiency(uint256 _currentRunway) external returns (uint256 newRunway) {
        IEfficiencyOptimizer optimizer = IEfficiencyOptimizer(this.getModuleAddress("EfficiencyOptimizer"));
        return optimizer.optimizeEfficiency(_currentRunway);
    }

    function reduceCost(uint256 _currentCost) external returns (uint256 newCost) {
        IRunwayCostManager costManager = IRunwayCostManager(this.getModuleAddress("RunwayCostManager"));
        return costManager.reduceCost(_currentCost);
    }

    function checkCompliance() external view returns (bool) {
        IRunwayComplianceChecker checker = IRunwayComplianceChecker(this.getModuleAddress("RunwayComplianceChecker"));
        return checker.checkCompliance();
    }

    function analyzeRisk() external view returns (uint256 riskScore, string memory riskLevel) {
        IRiskExposureAnalyzer analyzer = IRiskExposureAnalyzer(this.getModuleAddress("RiskExposureAnalyzer"));
        return analyzer.analyzeRisk();
    }

    function triggerMitigation(string calldata _strategyName) external {
        IRiskMitigationManager manager = IRiskMitigationManager(this.getModuleAddress("RiskMitigationManager"));
        manager.triggerMitigation(_strategyName);
    }

    function logAuditEntry(string calldata _eventType, address _caller, bytes calldata _data) external {
        IRunwayAuditLog auditLog = IRunwayAuditLog(this.getModuleAddress("RunwayAuditLog"));
        auditLog.log(_eventType, _caller, _data);
    }

    function reportPerformance(uint256 _currentRunway, uint256 _projectedRunway) external {
        IRunwayPerformanceReporter reporter = IRunwayPerformanceReporter(this.getModuleAddress("RunwayPerformanceReporter"));
        reporter.reportPerformance(_currentRunway, _projectedRunway);
    }

    function updateDashboard(bytes calldata _data) external {
        IRunwayDashboardUpdater updater = IRunwayDashboardUpdater(this.getModuleAddress("RunwayDashboardUpdater"));
        updater.updateDashboard(_data);
    }

    function aggregateData(bytes[] calldata _sourcesData) external returns (bytes32 dataHash) {
        IRunwayDataAggregator aggregator = IRunwayDataAggregator(this.getModuleAddress("RunwayDataAggregator"));
        return aggregator.aggregateData(_sourcesData);
    }

    function logEvent(string calldata _eventName, address _initiator, bytes calldata _data) external {
        IRunwayEventLogger eventLogger = IRunwayEventLogger(this.getModuleAddress("RunwayEventLogger"));
        eventLogger.logEvent(_eventName, _initiator, _data);
    }

    function generateForecast(bytes calldata _inputData) external returns (uint256 predictedValue) {
        IPredictiveAnalyticsModel model = IPredictiveAnalyticsModel(this.getModuleAddress("PredictiveAnalyticsModel"));
        return model.generateForecast(_inputData);
    }

    function triggerAlert(string calldata _alertType, string calldata _message) external {
        IRunwayAlertManager alertManager = IRunwayAlertManager(this.getModuleAddress("RunwayAlertManager"));
        alertManager.triggerAlert(_alertType, _message);
    }

    function checkAndNotifyThreshold(string calldata _metric, uint256 _value, uint256 _threshold) external {
        IThresholdNotifier notifier = IThresholdNotifier(this.getModuleAddress("ThresholdNotifier"));
        notifier.checkAndNotify(_metric, _value, _threshold);
    }

    function dispatchNotification(string calldata _platform, address _recipient, string calldata _message) external {
        INotificationDispatcher dispatcher = INotificationDispatcher(this.getModuleAddress("NotificationDispatcher"));
        dispatcher.dispatchNotification(_platform, _recipient, _message);
    }

    function updateRealTimeRunwayStatus(uint256 _currentRunway) external {
        IRealTimeRunwayMonitor monitor = IRealTimeRunwayMonitor(this.getModuleAddress("RealTimeRunwayMonitor"));
        monitor.updateRunwayStatus(_currentRunway);
    }

    function sendPeriodicUpdate() external {
        IPeriodicUpdateNotifier notifier = IPeriodicUpdateNotifier(this.getModuleAddress("PeriodicUpdateNotifier"));
        notifier.sendUpdate();
    }

    function applyRebondingStrategy(string calldata _strategyName, uint256 _amount) external {
        IRebondingStrategyManager manager = IRebondingStrategyManager(this.getModuleAddress("RebondingStrategyManager"));
        manager.applyRebondingStrategy(_strategyName, _amount);
    }

    function executeRunwayExtensionStrategy(string calldata _strategyName, uint256 _currentRunwayDays) external {
        IRunwayExtensionStrategy strategy = IRunwayExtensionStrategy(this.getModuleAddress("RunwayExtensionStrategy"));
        strategy.executeStrategy(_strategyName, _currentRunwayDays);
    }

    function adjustIncentiveStrategy(string calldata _incentiveType, uint256 _newValue) external {
        IIncentiveAdjustmentStrategy strategy = IIncentiveAdjustmentStrategy(this.getModuleAddress("IncentiveAdjustmentStrategy"));
        strategy.adjustIncentive(_incentiveType, _newValue);
    }

    function executeTreasuryManagementAction(string calldata _actionType, uint256 _amount) external {
        ITreasuryManagementStrategy strategy = ITreasuryManagementStrategy(this.getModuleAddress("TreasuryManagementStrategy"));
        strategy.executeTreasuryAction(_actionType, _amount);
    }

    function createGovernanceProposal(string calldata _description, bytes calldata _callData) external {
        IRunwayGovernanceModule governance = IRunwayGovernanceModule(this.getModuleAddress("RunwayGovernanceModule"));
        governance.createProposal(_description, _callData);
    }

    function executeGovernanceProposal(uint256 _proposalId) external {
        IRunwayGovernanceModule governance = IRunwayGovernanceModule(this.getModuleAddress("RunwayGovernanceModule"));
        governance.executeProposal(_proposalId);
    }

    function castVoteForProposal(uint256 _proposalId, uint256 _votes, bool _support) external {
        IVotingEscrowIntegration voting = IVotingEscrowIntegration(this.getModuleAddress("VotingEscrowIntegration"));
        voting.castVote(_proposalId, _votes, _support);
    }

    function updateSystemParameter(string calldata _parameterName, bytes calldata _newValue) external {
        IParameterController controller = IParameterController(this.getModuleAddress("ParameterController"));
        controller.updateParameter(_parameterName, _newValue);
    }

    function activateEmergencyBrake() external {
        IEmergencyBrakeModule brake = IEmergencyBrakeModule(this.getModuleAddress("EmergencyBrakeModule"));
        brake.activateEmergencyBrake();
    }

    function deactivateEmergencyBrake() external {
        IEmergencyBrakeModule brake = IEmergencyBrakeModule(this.getModuleAddress("EmergencyBrakeModule"));
        brake.deactivateEmergencyBrake();
    }

    function grantAccessRole(bytes32 role, address account) external {
        IAccessControlManager acm = IAccessControlManager(this.getModuleAddress("AccessControlManager"));
        acm.grantRole(role, account);
    }

    function revokeAccessRole(bytes32 role, address account) external {
        IAccessControlManager acm = IAccessControlManager(this.getModuleAddress("AccessControlManager"));
        acm.revokeRole(role, account);
    }
}