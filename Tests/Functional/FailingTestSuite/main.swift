// RUN: %{swiftc} %s -o %{built_tests_dir}/FailingTestSuite
// RUN: %{built_tests_dir}/FailingTestSuite > %t || true
// RUN: %{xctest_checker} %t %s

#if os(Linux) || os(FreeBSD)
    import XCTest
#else
    import SwiftXCTest
#endif

class PassingTestCase: XCTestCase {
    static var allTests: [(String, PassingTestCase -> () throws -> Void)] {
        return [("test_passes", test_passes)]
    }

// CHECK: Test Case 'PassingTestCase.test_passes' started.
// CHECK: Test Case 'PassingTestCase.test_passes' passed \(\d+\.\d+ seconds\).
    func test_passes() {
        XCTAssert(true)
    }
}
// CHECK: Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds


class FailingTestCase: XCTestCase {
    static var allTests: [(String, FailingTestCase -> () throws -> Void)] {
        return [
            ("test_passes", test_passes),
            ("test_fails", test_fails),
            ("test_fails_with_message", test_fails_with_message)
        ]
    }

// CHECK: Test Case 'FailingTestCase.test_passes' started.
// CHECK: Test Case 'FailingTestCase.test_passes' passed \(\d+\.\d+ seconds\).
    func test_passes() {
        XCTAssert(true)
    }

// CHECK: Test Case 'FailingTestCase.test_fails' started.
// CHECK: .*/FailingTestSuite/main.swift:\d+: error: FailingTestCase.test_fails : XCTAssertTrue failed - $
// CHECK: Test Case 'FailingTestCase.test_fails' failed \(\d+\.\d+ seconds\).
    func test_fails() {
        XCTAssert(false)
    }

// CHECK: Test Case 'FailingTestCase.test_fails_with_message' started.
// CHECK: .*/FailingTestSuite/main.swift:\d+: error: FailingTestCase.test_fails_with_message : XCTAssertTrue failed - Foo bar.
// CHECK: Test Case 'FailingTestCase.test_fails_with_message' failed \(\d+\.\d+ seconds\).
    func test_fails_with_message() {
        XCTAssert(false, "Foo bar.")
    }
}
// CHECK: Executed 3 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds


XCTMain([
    testCase(PassingTestCase.allTests),
    testCase(FailingTestCase.allTests)
])

// CHECK: Total executed 4 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
