// RUN: %{swiftc} %s -o %T/ContinueAfterFailureTestCase
// RUN: %T/ContinueAfterFailureTestCase > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'ContinueAfterFailureTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class ContinueAfterFailureTestCase: XCTestCase {
    static var allTests = {
        return [
            ("testDoesNotContinueAfterFailure", testDoesNotContinueAfterFailure),
            ("testContinueAfterFailure", testContinueAfterFailure)
        ]
    }()

    override func tearDown() {
        super.tearDown()
        print("In \(#function)")
    }

    // CHECK: Test Case 'ContinueAfterFailureTestCase.testDoesNotContinueAfterFailure' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: First Log in DoesNotContinueAfterFailure test
    // CHECK: .*/ContinueAfterFailureTestCase/main.swift:[[@LINE+8]]: error: ContinueAfterFailureTestCase.testDoesNotContinueAfterFailure : XCTAssertTrue failed -
    // CHECK: In tearDown\(\)
    // CHECK: Terminating execution due to test failure
    // CHECK-NOT: Second Log in DoesNotContinueAfterFailure test
    // CHECK-NOT: Test Case 'ContinueAfterFailureTestCase.testDoesNotContinueAfterFailure' failed \(\d+\.\d+ seconds\)
    func testDoesNotContinueAfterFailure() {
        continueAfterFailure = false
        print("First Log in DoesNotContinueAfterFailure test")
        XCTAssert(false)
        print("Second Log in DoesNotContinueAfterFailure test")
    }
    
    // CHECK-NOT: Test Case 'ContinueAfterFailureTestCase.testContinueAfterFailure' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK-NOT: First Log in ContinueAfterFailure test
    // CHECK-NOT: .*/ContinueAfterFailureTestCase/main.swift:[[@LINE+6]]: error: ContinueAfterFailureTestCase.testContinueAfterFailure : XCTAssertTrue failed -
    // CHECK-NOT: Second Log in ContinueAfterFailure test
    // CHECK-NOT: Test Case 'ContinueAfterFailureTestCase.testContinueAfterFailure' failed \(\d+\.\d+ seconds\)
    func testContinueAfterFailure() {
        continueAfterFailure = true
        print("First Log in ContinueAfterFailure test")
        XCTAssert(false)
        print("Second Log in ContinueAfterFailure test")
    }
}
// CHECK-NOT: Test Suite 'ContinueAfterFailureTestCase' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-NOT: \t Executed 2 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([testCase(ContinueAfterFailureTestCase.allTests)])

// CHECK-NOT: Test Suite '.*\.xctest' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-NOT: \t Executed 2 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK-NOT: Test Suite 'All tests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-NOT: \t Executed 2 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
