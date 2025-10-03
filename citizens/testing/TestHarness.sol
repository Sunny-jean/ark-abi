// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface TestHarness {
    /**
     * @dev Emitted when a test function is executed.
     * @param testName The name of the test function.
     * @param success True if the test passed, false otherwise.
     * @param message An optional message providing details about the test result.
     */
    event TestExecuted(string indexed testName, bool success, string message);

    // Errors

    /**
     * @dev Thrown when an unauthorized address attempts to perform a restricted operation.
     */
    error UnauthorizedAccess();

    /**
     * @dev Thrown when a test function with the given name is not found.
     */
    error TestNotFound(string testName);

    /**
     * @dev Executes a specific test function by name.
     * Only callable in a test environment or by authorized testers.
     * @param testName The name of the test function to execute.
     * @return success True if the test passed, false otherwise.
     * @return message An optional message providing details about the test result.
     */
    function runTest(string calldata testName) external returns (bool success, string memory message);

    /**
     * @dev Executes all available test functions.
     * Only callable in a test environment or by authorized testers.
     * @return totalTests The total number of tests executed.
     * @return passedTests The number of tests that passed.
     * @return failedTests The number of tests that failed.
     * @return results An array of TestResult structs for each executed test.
     */
    function runAllTests() external returns (uint256 totalTests, uint256 passedTests, uint256 failedTests, TestResult[] memory results);

    /**
     * @dev Struct representing the result of a single test.
     */
    struct TestResult {
        string testName;
        bool success;
        string message;
    }
}