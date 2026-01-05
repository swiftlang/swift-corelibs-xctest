// RUN: %{swiftc} %s -o %T/ExpectationCleanup
// RUN: %T/ExpectationCleanup > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'ExpectationCleanupTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class ExpectationCleanupTestCase: XCTestCase {
    static var notificationHandlerCalled = false

// CHECK: Test Case 'ExpectationCleanupTestCase.test_createExpectationAndSkipWait' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Expectations[/\\]Cleanup[/\\]main.swift:[[@LINE+3]]: error: ExpectationCleanupTestCase.test_createExpectationAndSkipWait : Failed due to unwaited expectation 'Expect notification 'TestCleanup' from any object'
// CHECK: Test Case 'ExpectationCleanupTestCase.test_createExpectationAndSkipWait' failed \(\d+\.\d+ seconds\)
    func test_createExpectationAndSkipWait() {
        self.expectation(
            forNotification: Notification.Name("TestCleanup"), object: nil,
            handler: { _ in
                ExpectationCleanupTestCase.notificationHandlerCalled = true
                return true
            })
    }

// CHECK: Test Case 'ExpectationCleanupTestCase.test_verifyCleanup' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ExpectationCleanupTestCase.test_verifyCleanup' passed \(\d+\.\d+ seconds\)
    func test_verifyCleanup() {
        // Post notification.
        NotificationCenter.default.post(name: Notification.Name("TestCleanup"), object: nil)

        // If observer was removed, handler is NOT called.
        XCTAssertFalse(
            ExpectationCleanupTestCase.notificationHandlerCalled,
            "Expectation handler called, meaning cleanup failed!")
    }

    static var allTests = {
        return [
            ("test_createExpectationAndSkipWait", test_createExpectationAndSkipWait),
            ("test_verifyCleanup", test_verifyCleanup),
        ]
    }()
}
// CHECK: Test Suite 'ExpectationCleanupTestCase' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 2 tests, with 1 failure \(1 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([testCase(ExpectationCleanupTestCase.allTests)])

// CHECK: Test Suite '.*\.xctest' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 2 tests, with 1 failure \(1 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 2 tests, with 1 failure \(1 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
