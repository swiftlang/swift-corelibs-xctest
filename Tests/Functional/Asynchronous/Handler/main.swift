// RUN: %{swiftc} %s -o %T/Handler
// RUN: %T/Handler > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'HandlerTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class HandlerTestCase: XCTestCase {
// CHECK: Test Case 'HandlerTestCase.test_whenExpectationsAreNotFulfilled_handlerCalled_andFails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*/Tests/Functional/Asynchronous/Handler/main.swift:[[@LINE+6]]: error: HandlerTestCase.test_whenExpectationsAreNotFulfilled_handlerCalled_andFails : Asynchronous wait failed - Exceeded timeout of 0.2 seconds, with unfulfilled expectations: fog
// CHECK: Test Case 'HandlerTestCase.test_whenExpectationsAreNotFulfilled_handlerCalled_andFails' failed \(\d+\.\d+ seconds\)
    func test_whenExpectationsAreNotFulfilled_handlerCalled_andFails() {
        self.expectation(description: "fog")

        var handlerWasCalled = false
        self.waitForExpectations(timeout: 0.2) { error in
            XCTAssertNotNil(error, "Expectation handlers for unfulfilled expectations should not be nil.")
            XCTAssertEqual(error?.domain, XCTestErrorDomain, "The error domain should be XCTest's own error domain")
            XCTAssertEqual(error?.code, XCTestError.Code.timeoutWhileWaiting.rawValue, "The error code should indicate that a timeout occurred")
            handlerWasCalled = true
        }
        XCTAssertTrue(handlerWasCalled)
    }

// CHECK: Test Case 'HandlerTestCase.test_whenExpectationsAreFulfilled_handlerCalled_andPasses' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'HandlerTestCase.test_whenExpectationsAreFulfilled_handlerCalled_andPasses' passed \(\d+\.\d+ seconds\)
    func test_whenExpectationsAreFulfilled_handlerCalled_andPasses() {
        let expectation = self.expectation(description: "bog")
        expectation.fulfill()

        var handlerWasCalled = false
        self.waitForExpectations(timeout: 0.2) { error in
            XCTAssertNil(error, "Expectation handlers for fulfilled expectations should be nil.")
            handlerWasCalled = true
        }
        XCTAssertTrue(handlerWasCalled)
    }

    static var allTests = {
        return [
            ("test_whenExpectationsAreNotFulfilled_handlerCalled_andFails", test_whenExpectationsAreNotFulfilled_handlerCalled_andFails),
            ("test_whenExpectationsAreFulfilled_handlerCalled_andPasses", test_whenExpectationsAreFulfilled_handlerCalled_andPasses),
        ]
    }()
}
// CHECK: Test Suite 'HandlerTestCase' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 2 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([testCase(HandlerTestCase.allTests)])

// CHECK: Test Suite '.*\.xctest' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 2 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 2 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
