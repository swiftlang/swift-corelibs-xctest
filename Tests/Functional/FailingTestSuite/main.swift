// RUN: %{swiftc} %s -o %T/FailingTestSuite
// RUN: %T/FailingTestSuite > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'PassingTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class PassingTestCase: XCTestCase {
    static var allTests = {
        return [
            ("test_passes", test_passes),
        ]
    }()

// CHECK: Test Case 'PassingTestCase.test_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'PassingTestCase.test_passes' passed \(\d+\.\d+ seconds\)
    func test_passes() {
        XCTAssert(true)
    }
}
// CHECK: Test Suite 'PassingTestCase' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

// CHECK: Test Suite 'FailingTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class FailingTestCase: XCTestCase {
    static var allTests = {
        return [
            ("test_passes", test_passes),
            ("test_fails", test_fails),
            ("test_fails_with_message", test_fails_with_message),
        ]
    }()

// CHECK: Test Case 'FailingTestCase.test_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'FailingTestCase.test_passes' passed \(\d+\.\d+ seconds\)
    func test_passes() {
        XCTAssert(true)
    }

// CHECK: Test Case 'FailingTestCase.test_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*/FailingTestSuite/main.swift:[[@LINE+3]]: error: FailingTestCase.test_fails : XCTAssertTrue failed - $
// CHECK: Test Case 'FailingTestCase.test_fails' failed \(\d+\.\d+ seconds\)
    func test_fails() {
        XCTAssert(false)
    }

// CHECK: Test Case 'FailingTestCase.test_fails_with_message' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*/FailingTestSuite/main.swift:[[@LINE+3]]: error: FailingTestCase.test_fails_with_message : XCTAssertTrue failed - Foo bar.
// CHECK: Test Case 'FailingTestCase.test_fails_with_message' failed \(\d+\.\d+ seconds\)
    func test_fails_with_message() {
        XCTAssert(false, "Foo bar.")
    }
}
// CHECK: Test Suite 'FailingTestCase' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 3 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([
    testCase(PassingTestCase.allTests),
    testCase(FailingTestCase.allTests),
])

// CHECK: Test Suite '.*\.xctest' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 4 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 4 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
