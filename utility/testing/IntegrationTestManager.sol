// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IIntegrationTestManager {
    event IntegrationTestRun(string indexed testSuiteName, bool success);

    function runTestSuite(string memory _testSuiteName) external returns (bool);
    function getTestSuiteResults(string memory _testSuiteName) external view returns (bool success);
}