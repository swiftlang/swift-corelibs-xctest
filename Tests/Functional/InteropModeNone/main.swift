// RUN: %{swiftc} %s -o %T/InteropModeNone
// RUN: env SWIFT_TESTING_XCTEST_INTEROP_MODE=none %T/InteropModeNone > %t || true
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
    // CHECK: Test Case 'InteropWithSWTTestCase.test_records_issue' passed \(\d+\.\d+ seconds\)
    func test_records_issue() {
        Issue.record("Interop recorded issue failure")
    }

    static var allTests = {
        return [
            ("test_records_issue", test_records_issue),
        ]
    }()
}
// CHECK: Test Suite 'InteropWithSWTTestCase' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([testCase(InteropWithSWTTestCase.allTests)])

// CHECK: Test Suite '.*\.xctest' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
