// RUN: %{swiftc} %s -o %T/Misuse
// RUN: %T/Misuse > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'MisuseTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class MisuseTestCase: XCTestCase {
// CHECK: Test Case 'MisuseTestCase.test_whenExpectationsAreMade_butNotWaitedFor_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*/Tests/Functional/Asynchronous/Misuse/main.swift:[[@LINE+4]]: error: MisuseTestCase.test_whenExpectationsAreMade_butNotWaitedFor_fails : Failed due to unwaited expectations.
// CHECK: Test Case 'MisuseTestCase.test_whenExpectationsAreMade_butNotWaitedFor_fails' failed \(\d+\.\d+ seconds\)
    func test_whenExpectationsAreMade_butNotWaitedFor_fails() {
        self.expectation(description: "the first expectation")
        self.expectation(description: "the second expectation (the file and line number for this one are included in the failure message")
    }

// CHECK: Test Case 'MisuseTestCase.test_whenNoExpectationsAreMade_butTheyAreWaitedFor_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*/Tests/Functional/Asynchronous/Misuse/main.swift:[[@LINE+3]]: error: MisuseTestCase.test_whenNoExpectationsAreMade_butTheyAreWaitedFor_fails : API violation - call made to wait without any expectations having been set.
// CHECK: Test Case 'MisuseTestCase.test_whenNoExpectationsAreMade_butTheyAreWaitedFor_fails' failed \(\d+\.\d+ seconds\)
    func test_whenNoExpectationsAreMade_butTheyAreWaitedFor_fails() {
        self.waitForExpectations(timeout: 0.1)
    }

// CHECK: Test Case 'MisuseTestCase.test_whenExpectationIsFulfilledMultipleTimes_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*/Tests/Functional/Asynchronous/Misuse/main.swift:[[@LINE+6]]: error: MisuseTestCase.test_whenExpectationIsFulfilledMultipleTimes_fails : API violation - multiple calls made to XCTestExpectation.fulfill\(\) for rob.
// CHECK: .*/Tests/Functional/Asynchronous/Misuse/main.swift:[[@LINE+15]]: error: MisuseTestCase.test_whenExpectationIsFulfilledMultipleTimes_fails : API violation - multiple calls made to XCTestExpectation.fulfill\(\) for rob.
// CHECK: Test Case 'MisuseTestCase.test_whenExpectationIsFulfilledMultipleTimes_fails' failed \(\d+\.\d+ seconds\)
    func test_whenExpectationIsFulfilledMultipleTimes_fails() {
        let expectation = self.expectation(description: "rob")
        expectation.fulfill()
        expectation.fulfill()
        // FIXME: The behavior here is subtly different from Objective-C XCTest.
        //        Objective-C XCTest would stop executing the test on the line
        //        above, and so would not report a failure for this line below.
        //        In total, it would highlight one line as a failure in this
        //        test.
        //
        //        swift-corelibs-xctest continues to execute the test, and so
        //        highlights both the lines above and below as failures.
        //        This should be fixed such that the behavior is identical.
        expectation.fulfill()
        self.waitForExpectations(timeout: 0.1)
    }

    static var allTests = {
        return [
            ("test_whenExpectationsAreMade_butNotWaitedFor_fails", test_whenExpectationsAreMade_butNotWaitedFor_fails),
            ("test_whenNoExpectationsAreMade_butTheyAreWaitedFor_fails", test_whenNoExpectationsAreMade_butTheyAreWaitedFor_fails),
            ("test_whenExpectationIsFulfilledMultipleTimes_fails", test_whenExpectationIsFulfilledMultipleTimes_fails),
        ]
    }()
}
// CHECK: Test Suite 'MisuseTestCase' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 3 tests, with 4 failures \(4 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([testCase(MisuseTestCase.allTests)])

// CHECK: Test Suite '.*\.xctest' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 3 tests, with 4 failures \(4 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 3 tests, with 4 failures \(4 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
