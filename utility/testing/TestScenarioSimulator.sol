// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITestScenarioSimulator {
    event ScenarioSimulated(string indexed scenarioName, bool success);

    function simulateScenario(string memory _scenarioName, bytes memory _scenarioData) external returns (bool);
}