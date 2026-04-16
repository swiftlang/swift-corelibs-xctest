// RUN: %{swiftc} %s -o %T/DetachedTaskLostFailure
// RUN: env XCT_EXPERIMENTAL_ENABLE_INTEROP=1 %T/DetachedTaskLostFailure > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif
import Foundation

let testsFinished = DispatchSemaphore(value: 0)
let issueReported = DispatchSemaphore(value: 0)

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'DetachedTaskLostFailureTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class DetachedTaskLostFailureTestCase: XCTestCase {
    static var allTests = {
        return [
            ("test_XCTFailInDetachedTaskIsLost", test_XCTFailInDetachedTaskIsLost),
        ]
    }()

    // Use semaphores to guarantee XCTFail() is called after the test case already ends.
    // The test failure should be dropped as a result.
    // CHECK: Test Case 'DetachedTaskLostFailureTestCase.test_XCTFailInDetachedTaskIsLost' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: Test Case 'DetachedTaskLostFailureTestCase.test_XCTFailInDetachedTaskIsLost' passed \(\d+\.\d+ seconds\)
    func test_XCTFailInDetachedTaskIsLost() {
        // Don't write actual tests like this :)
        Task.detached {
            testsFinished.wait()
            XCTFail("This is not reported")
            issueReported.signal()
        }
    }
}
// CHECK: Test Suite 'DetachedTaskLostFailureTestCase' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

// This has to capture the return value explicitly as CInt, otherwise we call
// the variant of XCTMain that terminates the program with exit()
let _: CInt = XCTMain([testCase(DetachedTaskLostFailureTestCase.allTests)])
// Unblock the code within Task.detached
testsFinished.signal()
issueReported.wait()

// CHECK: Test Suite '.*\.xctest' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
