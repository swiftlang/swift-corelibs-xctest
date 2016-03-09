// RUN: %{swiftc} %s -o %{built_tests_dir}/SingleFailingTestCase
// RUN: %{built_tests_dir}/SingleFailingTestCase > %t || true
// RUN: %{xctest_checker} %t %s

#if os(Linux) || os(FreeBSD)
    import XCTest
#else
    import SwiftXCTest
#endif

class SingleFailingTestCase: XCTestCase {
    // CHECK: Test Case 'SingleFailingTestCase.test_fails' started.
    // CHECK: .*/SingleFailingTestCase/main.swift:16: error: SingleFailingTestCase.test_fails : XCTAssertTrue failed - $
    // CHECK: Test Case 'SingleFailingTestCase.test_fails' failed \(\d+\.\d+ seconds\).
    func test_fails() {
        XCTAssert(false)
    }

    static var allTests: [(String, SingleFailingTestCase -> () throws -> Void)] {
        return [
            ("test_fails", test_fails)
        ]
    }
} // CHECK: Executed 1 test, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

// CHECK: Total executed 1 test, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
XCTMain([testCase(SingleFailingTestCase.allTests)])
