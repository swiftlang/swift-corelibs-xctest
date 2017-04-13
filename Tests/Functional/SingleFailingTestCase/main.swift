// RUN: %{swiftc} %s -o %T/SingleFailingTestCase
// RUN: %T/SingleFailingTestCase > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'SingleFailingTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class SingleFailingTestCase: XCTestCase {
    static var allTests = {
        return [
            ("test_fails", test_fails)
        ]
    }()

    // CHECK: Test Case 'SingleFailingTestCase.test_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: .*/SingleFailingTestCase/main.swift:[[@LINE+3]]: error: SingleFailingTestCase.test_fails : XCTAssertTrue failed -
    // CHECK: Test Case 'SingleFailingTestCase.test_fails' failed \(\d+\.\d+ seconds\)
    func test_fails() {
        XCTAssert(false)
    }
}
// CHECK: Test Suite 'SingleFailingTestCase' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 1 test, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([testCase(SingleFailingTestCase.allTests)])

// CHECK: Test Suite '.*\.xctest' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 1 test, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 1 test, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
