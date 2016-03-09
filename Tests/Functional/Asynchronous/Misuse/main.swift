// RUN: %{swiftc} %s -o %{built_tests_dir}/Misuse
// RUN: %{built_tests_dir}/Misuse > %t || true
// RUN: %{xctest_checker} %t %s

#if os(Linux) || os(FreeBSD)
    import XCTest
#else
    import SwiftXCTest
#endif

class MisuseTestCase: XCTestCase {
    // CHECK: Test Case 'MisuseTestCase.test_whenExpectationsAreMade_butNotWaitedFor_fails' started.
    // CHECK: .*/Asynchronous/Misuse/main.swift:[[@LINE+4]]: unexpected error: MisuseTestCase.test_whenExpectationsAreMade_butNotWaitedFor_fails :  - Failed due to unwaited expectations.
    // CHECK: Test Case 'MisuseTestCase.test_whenExpectationsAreMade_butNotWaitedFor_fails' failed \(\d+\.\d+ seconds\).
    func test_whenExpectationsAreMade_butNotWaitedFor_fails() {
        self.expectationWithDescription("the first expectation")
        self.expectationWithDescription("the second expectation (the file and line number for this one are included in the failure message")
    }

    // CHECK: Test Case 'MisuseTestCase.test_whenNoExpectationsAreMade_butTheyAreWaitedFor_fails' started.
    // CHECK: .*/Asynchronous/Misuse/main.swift:[[@LINE+3]]: unexpected error: MisuseTestCase.test_whenNoExpectationsAreMade_butTheyAreWaitedFor_fails : API violation - call made to wait without any expectations having been set.
    // CHECK: Test Case 'MisuseTestCase.test_whenNoExpectationsAreMade_butTheyAreWaitedFor_fails' failed \(\d+\.\d+ seconds\).
    func test_whenNoExpectationsAreMade_butTheyAreWaitedFor_fails() {
        self.waitForExpectationsWithTimeout(0.1, handler: nil)
    }

    // CHECK: Test Case 'MisuseTestCase.test_whenExpectationIsFulfilledMultipleTimes_fails' started.
    // CHECK: .*/Asynchronous/Misuse/main.swift:[[@LINE+6]]: unexpected error: MisuseTestCase.test_whenExpectationIsFulfilledMultipleTimes_fails : API violation - multiple calls made to XCTestExpectation.fulfill\(\) for rob.
    // CHECK: .*/Asynchronous/Misuse/main.swift:[[@LINE+15]]: unexpected error: MisuseTestCase.test_whenExpectationIsFulfilledMultipleTimes_fails : API violation - multiple calls made to XCTestExpectation.fulfill\(\) for rob.
    // CHECK: Test Case 'MisuseTestCase.test_whenExpectationIsFulfilledMultipleTimes_fails' failed \(\d+\.\d+ seconds\).
    func test_whenExpectationIsFulfilledMultipleTimes_fails() {
        let expectation = self.expectationWithDescription("rob")
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
        self.waitForExpectationsWithTimeout(0.1, handler: nil)
    }

    static var allTests: [(String, MisuseTestCase -> () throws -> Void)] {
        return [
            ("test_whenExpectationsAreMade_butNotWaitedFor_fails", test_whenExpectationsAreMade_butNotWaitedFor_fails),
            ("test_whenNoExpectationsAreMade_butTheyAreWaitedFor_fails", test_whenNoExpectationsAreMade_butTheyAreWaitedFor_fails),
            ("test_whenExpectationIsFulfilledMultipleTimes_fails", test_whenExpectationIsFulfilledMultipleTimes_fails),
        ]
    }
} // CHECK: Executed 3 tests, with 4 failures \(4 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

// CHECK: Total executed 3 tests, with 4 failures \(4 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
XCTMain([testCase(MisuseTestCase.allTests)])
