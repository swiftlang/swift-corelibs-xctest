// RUN: %{swiftc} %s -o %T/FulfillmentTracking
// RUN: %T/FulfillmentTracking > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'FulfillmentTrackingTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class FulfillmentTrackingTestCase: XCTestCase {

// CHECK: Test Case 'FulfillmentTrackingTestCase.test_multipleFulfillmentsAreTrackedCorrectly' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'FulfillmentTrackingTestCase.test_multipleFulfillmentsAreTrackedCorrectly' passed \(\d+\.\d+ seconds\)
    func test_multipleFulfillmentsAreTrackedCorrectly() {
        // This test verifies that when multiple expectations are fulfilled during a wait,
        // they are all correctly tracked in the waiter's state.
        let expectation1 = XCTestExpectation(description: "first")
        let expectation2 = XCTestExpectation(description: "second")
        let expectation3 = XCTestExpectation(description: "third")

        // Fulfill expectations asynchronously with slight delays to ensure they are
        // processed as separate fulfillment events.
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
            expectation1.fulfill()
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.02) {
            expectation2.fulfill()
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.03) {
            expectation3.fulfill()
        }

        let waiter = XCTWaiter(delegate: self)
        let result = waiter.wait(for: [expectation1, expectation2, expectation3], timeout: 1.0)

        // If the bug is present (state not updated), the waiter may timeout or report
        // incorrect results. With the fix, it should complete successfully.
        XCTAssertEqual(result, .completed, "Waiter should complete successfully when all expectations are fulfilled")
        XCTAssertEqual(waiter.fulfilledExpectations.count, 3, "All three expectations should be tracked as fulfilled")
    }

// CHECK: Test Case 'FulfillmentTrackingTestCase.test_fulfillmentOrder' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'FulfillmentTrackingTestCase.test_fulfillmentOrder' passed \(\d+\.\d+ seconds\)
    func test_fulfillmentOrder() {
        // This test verifies that the order of fulfilled expectations is correctly tracked.
        let first = XCTestExpectation(description: "first")
        let second = XCTestExpectation(description: "second")

        // Fulfill in order
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
            first.fulfill()
            second.fulfill()
        }

        let waiter = XCTWaiter(delegate: self)
        let result = waiter.wait(for: [first, second], timeout: 1.0, enforceOrder: true)

        XCTAssertEqual(result, .completed, "Waiter should complete when expectations are fulfilled in order")
        XCTAssertEqual(waiter.fulfilledExpectations.count, 2)
    }

    static var allTests = {
        return [
            ("test_multipleFulfillmentsAreTrackedCorrectly", test_multipleFulfillmentsAreTrackedCorrectly),
            ("test_fulfillmentOrder", test_fulfillmentOrder),
        ]
    }()
}
// CHECK: Test Suite 'FulfillmentTrackingTestCase' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 2 tests, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([testCase(FulfillmentTrackingTestCase.allTests)])

// CHECK: Test Suite '.*\.xctest' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 2 tests, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 2 tests, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
