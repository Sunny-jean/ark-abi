// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IUnitTestFramework {
    event TestResult(string indexed testName, bool success, string message);

    function runTest(string memory _testName) external returns (bool);
    function getTestResults(string memory _testName) external view returns (bool success, string memory message);
}