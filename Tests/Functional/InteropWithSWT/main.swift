// RUN: %{swiftc} %s -o %T/InteropWithSWT
// RUN: env XCT_EXPERIMENTAL_ENABLE_INTEROP=1 %T/InteropWithSWT > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif
import Testing

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'InteropWithSWTTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class InteropWithSWTTestCase: XCTestCase {
    // CHECK: Test Case 'InteropWithSWTTestCase.test_records_issue' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: .*[/\\]InteropWithSWT[/\\]main.swift:[[@LINE+3]]: error: InteropWithSWTTestCase.test_records_issue : Issue recorded: Interop recorded issue failure
    // CHECK: Test Case 'InteropWithSWTTestCase.test_records_issue' failed \(\d+\.\d+ seconds\)
    func test_records_issue() {
        Issue.record("Interop recorded issue failure")
    }

    // CHECK: Test Case 'InteropWithSWTTestCase.test_assertion_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: .*[/\\]InteropWithSWT[/\\]main.swift:[[@LINE+4]]: error: InteropWithSWTTestCase.test_assertion_fails : Expectation failed: Bool\(false\): Bool\(false\) → false
    // CHECK: false → \(\)
    // CHECK: Test Case 'InteropWithSWTTestCase.test_assertion_fails' failed \(\d+\.\d+ seconds\)
    func test_assertion_fails() {
        #expect(Bool(false))
    }

    static var allTests = {
        return [
            ("test_records_issue", test_records_issue),
            ("test_assertion_fails", test_assertion_fails)
        ]
    }()
}
// CHECK: Test Suite 'InteropWithSWTTestCase' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 2 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([testCase(InteropWithSWTTestCase.allTests)])

// CHECK: Test Suite '.*\.xctest' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 2 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 2 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
