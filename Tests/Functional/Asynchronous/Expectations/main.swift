// RUN: %{swiftc} %s -o %T/Asynchronous
// RUN: %T/Asynchronous > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

import CoreFoundation

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'ExpectationsTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class ExpectationsTestCase: XCTestCase {
// CHECK: Test Case 'ExpectationsTestCase.test_waitingForAnUnfulfilledExpectation_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Expectations[/\\]main.swift:[[@LINE+4]]: error: ExpectationsTestCase.test_waitingForAnUnfulfilledExpectation_fails : Asynchronous wait failed - Exceeded timeout of 0.2 seconds, with unfulfilled expectations: foo
// CHECK: Test Case 'ExpectationsTestCase.test_waitingForAnUnfulfilledExpectation_fails' failed \(\d+\.\d+ seconds\)
    func test_waitingForAnUnfulfilledExpectation_fails() {
        expectation(description: "foo")
        waitForExpectations(timeout: 0.2)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_waitingForUnfulfilledExpectations_outputsAllExpectations_andFails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Expectations[/\\]main.swift:[[@LINE+5]]: error: ExpectationsTestCase.test_waitingForUnfulfilledExpectations_outputsAllExpectations_andFails : Asynchronous wait failed - Exceeded timeout of 0.2 seconds, with unfulfilled expectations: bar, baz
// CHECK: Test Case 'ExpectationsTestCase.test_waitingForUnfulfilledExpectations_outputsAllExpectations_andFails' failed \(\d+\.\d+ seconds\)
    func test_waitingForUnfulfilledExpectations_outputsAllExpectations_andFails() {
        expectation(description: "bar")
        expectation(description: "baz")
        waitForExpectations(timeout: 0.2)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_waitingForAnImmediatelyFulfilledExpectation_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ExpectationsTestCase.test_waitingForAnImmediatelyFulfilledExpectation_passes' passed \(\d+\.\d+ seconds\)
    func test_waitingForAnImmediatelyFulfilledExpectation_passes() {
        let expectation = self.expectation(description: "flim")
        expectation.fulfill()
        waitForExpectations(timeout: 0.2)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_waitingForAnEventuallyFulfilledExpectation_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ExpectationsTestCase.test_waitingForAnEventuallyFulfilledExpectation_passes' passed \(\d+\.\d+ seconds\)
    func test_waitingForAnEventuallyFulfilledExpectation_passes() {
        let expectation = self.expectation(description: "flam")
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            expectation.fulfill()
        }
        RunLoop.current.add(timer, forMode: .default)
        waitForExpectations(timeout: 1.0)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_waitingForAnExpectationFulfilledAfterTheTimeout_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Expectations[/\\]main.swift:[[@LINE+8]]: error: ExpectationsTestCase.test_waitingForAnExpectationFulfilledAfterTheTimeout_fails : Asynchronous wait failed - Exceeded timeout of 0.1 seconds, with unfulfilled expectations: hog
// CHECK: Test Case 'ExpectationsTestCase.test_waitingForAnExpectationFulfilledAfterTheTimeout_fails' failed \(\d+\.\d+ seconds\)
    func test_waitingForAnExpectationFulfilledAfterTheTimeout_fails() {
        let expectation = self.expectation(description: "hog")
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            expectation.fulfill()
        }
        RunLoop.current.add(timer, forMode: .default)
        waitForExpectations(timeout: 0.1)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_whenTimeoutIsImmediate_andAllExpectationsAreFulfilled_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ExpectationsTestCase.test_whenTimeoutIsImmediate_andAllExpectationsAreFulfilled_passes' passed \(\d+\.\d+ seconds\)
    func test_whenTimeoutIsImmediate_andAllExpectationsAreFulfilled_passes() {
        let expectation = self.expectation(description: "smog")
        expectation.fulfill()
        waitForExpectations(timeout: 0.0)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_whenTimeoutIsImmediate_butNotAllExpectationsAreFulfilled_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Expectations[/\\]main.swift:[[@LINE+4]]: error: ExpectationsTestCase.test_whenTimeoutIsImmediate_butNotAllExpectationsAreFulfilled_fails : Asynchronous wait failed - Exceeded timeout of -1.0 seconds, with unfulfilled expectations: dog
// CHECK: Test Case 'ExpectationsTestCase.test_whenTimeoutIsImmediate_butNotAllExpectationsAreFulfilled_fails' failed \(\d+\.\d+ seconds\)
    func test_whenTimeoutIsImmediate_butNotAllExpectationsAreFulfilled_fails() {
        expectation(description: "dog")
        waitForExpectations(timeout: -1.0)
    }

    // PRAGMA MARK: - Multiple Expectations

// CHECK: Test Case 'ExpectationsTestCase.test_multipleExpectations' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ExpectationsTestCase.test_multipleExpectations' passed \(\d+\.\d+ seconds\)
    func test_multipleExpectations() {
        let foo = expectation(description: "foo")
        let bar = XCTestExpectation(description: "bar")
        DispatchQueue.global(qos: .default).asyncAfter(wallDeadline: .now() + 0.01) {
            bar.fulfill()
        }
        DispatchQueue.global(qos: .default).asyncAfter(wallDeadline: .now() + 0.01) {
            foo.fulfill()
        }

        XCTWaiter(delegate: self).wait(for: [foo, bar], timeout: 1)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_multipleExpectationsEnforceOrderingCorrect' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ExpectationsTestCase.test_multipleExpectationsEnforceOrderingCorrect' passed \(\d+\.\d+ seconds\)
    func test_multipleExpectationsEnforceOrderingCorrect() {
        let foo = expectation(description: "foo")
        let bar = XCTestExpectation(description: "bar")
        DispatchQueue.global(qos: .default).asyncAfter(wallDeadline: .now() + 0.01) {
            foo.fulfill()
            bar.fulfill()
        }

        XCTWaiter(delegate: self).wait(for: [foo, bar], timeout: 1, enforceOrder: true)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_multipleExpectationsEnforceOrderingCorrectBeforeWait' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ExpectationsTestCase.test_multipleExpectationsEnforceOrderingCorrectBeforeWait' passed \(\d+\.\d+ seconds\)
    func test_multipleExpectationsEnforceOrderingCorrectBeforeWait() {
        let foo = expectation(description: "foo")
        let bar = XCTestExpectation(description: "bar")
        foo.fulfill()
        bar.fulfill()
        XCTWaiter(delegate: self).wait(for: [foo, bar], timeout: 1, enforceOrder: true)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_multipleExpectationsEnforceOrderingIncorrect' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Expectations[/\\]main.swift:[[@LINE+6]]: error: ExpectationsTestCase.test_multipleExpectationsEnforceOrderingIncorrect : Failed due to expectation fulfilled in incorrect order: requires 'foo', actually fulfilled 'bar'
// CHECK: Test Case 'ExpectationsTestCase.test_multipleExpectationsEnforceOrderingIncorrect' failed \(\d+\.\d+ seconds\)
    func test_multipleExpectationsEnforceOrderingIncorrect() {
        let foo = expectation(description: "foo")
        let bar = XCTestExpectation(description: "bar")
        DispatchQueue.global(qos: .default).asyncAfter(wallDeadline: .now() + 0.01) {
            bar.fulfill()
            foo.fulfill()
        }
        XCTWaiter(delegate: self).wait(for: [foo, bar], timeout: 1, enforceOrder: true)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_multipleExpectationsIncludingInvertedEnforceOrderingIncorrect' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Expectations[/\\]main.swift:[[@LINE+8]]: error: ExpectationsTestCase.test_multipleExpectationsIncludingInvertedEnforceOrderingIncorrect : Failed due to expectation fulfilled in incorrect order: requires 'foo', actually fulfilled 'bar'
// CHECK: Test Case 'ExpectationsTestCase.test_multipleExpectationsIncludingInvertedEnforceOrderingIncorrect' failed \(\d+\.\d+ seconds\)
    func test_multipleExpectationsIncludingInvertedEnforceOrderingIncorrect() {
        let inverted = expectation(description: "inverted")
        inverted.isInverted = true
        let foo = expectation(description: "foo")
        let bar = XCTestExpectation(description: "bar")
        DispatchQueue.global(qos: .default).asyncAfter(wallDeadline: .now() + 0.01) {
            bar.fulfill()
            foo.fulfill()
        }
        XCTWaiter(delegate: self).wait(for: [inverted, foo, bar], timeout: 1, enforceOrder: true)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_multipleExpectationsEnforceOrderingIncorrectBeforeWait' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Expectations[/\\]main.swift:[[@LINE+5]]: error: ExpectationsTestCase.test_multipleExpectationsEnforceOrderingIncorrectBeforeWait : Failed due to expectation fulfilled in incorrect order: requires 'foo', actually fulfilled 'bar'
// CHECK: Test Case 'ExpectationsTestCase.test_multipleExpectationsEnforceOrderingIncorrectBeforeWait' failed \(\d+\.\d+ seconds\)
    func test_multipleExpectationsEnforceOrderingIncorrectBeforeWait() {
        let foo = expectation(description: "foo")
        let bar = XCTestExpectation(description: "bar")
        bar.fulfill()
        foo.fulfill()
        XCTWaiter(delegate: self).wait(for: [foo, bar], timeout: 1, enforceOrder: true)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_multipleExpectationsEnforceOrderingStressTest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ExpectationsTestCase.test_multipleExpectationsEnforceOrderingStressTest' passed \(\d+\.\d+ seconds\)
    func test_multipleExpectationsEnforceOrderingStressTest() {
        for _ in 0..<2000 {
            let expectation1 = XCTestExpectation(description: "expectation1")
            let expectation2 = XCTestExpectation(description: "expectation2")

            DispatchQueue.global(qos: .default).async {
                expectation1.fulfill()
                expectation2.fulfill()
            }

            wait(for: [expectation1, expectation2], timeout: 5, enforceOrder: true)
        }
    }

    // PRAGMA MARK: - Inverse Expectations

// CHECK: Test Case 'ExpectationsTestCase.test_inverseExpectationPass' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ExpectationsTestCase.test_inverseExpectationPass' passed \(\d+\.\d+ seconds\)
    func test_inverseExpectationPass() {
        let foo = expectation(description: "foo")
        foo.isInverted = true
        waitForExpectations(timeout: 0.1)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_inverseExpectationFail' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Expectations[/\\]main.swift:[[@LINE+6]]: error: ExpectationsTestCase.test_inverseExpectationFail : Asynchronous wait failed - Fulfilled inverted expectation 'foo'
// CHECK: Test Case 'ExpectationsTestCase.test_inverseExpectationFail' failed \(\d+\.\d+ seconds\)
    func test_inverseExpectationFail() {
        let foo = expectation(description: "foo")
        foo.isInverted = true
        DispatchQueue.global(qos: .default).asyncAfter(wallDeadline: .now() + 0.01) {
            foo.fulfill()
        }
        waitForExpectations(timeout: 0.5)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_inverseExpectationFulfilledBeforeWait' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Expectations[/\\]main.swift:[[@LINE+5]]: error: ExpectationsTestCase.test_inverseExpectationFulfilledBeforeWait : Asynchronous wait failed - Fulfilled inverted expectation 'foo'
// CHECK: Test Case 'ExpectationsTestCase.test_inverseExpectationFulfilledBeforeWait' failed \(\d+\.\d+ seconds\)
    func test_inverseExpectationFulfilledBeforeWait() {
        let foo = expectation(description: "foo")
        foo.isInverted = true
        foo.fulfill()
        wait(for: [foo], timeout: 1)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_combiningInverseAndStandardExpectationsPass' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ExpectationsTestCase.test_combiningInverseAndStandardExpectationsPass' passed \(\d+\.\d+ seconds\)
    func test_combiningInverseAndStandardExpectationsPass() {
        let foo = expectation(description: "foo")
        foo.isInverted = true
        let bar = XCTestExpectation(description: "bar")
        DispatchQueue.global(qos: .default).asyncAfter(wallDeadline: .now() + 0.1) {
            bar.fulfill()
        }

        let start = Date.timeIntervalSinceReferenceDate
        waitForExpectations(timeout: 0.5)

        // Make sure we actually waited long enough.
        XCTAssertGreaterThanOrEqual(Date.timeIntervalSinceReferenceDate - start, 0.5)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_combiningInverseAndStandardExpectationsFailWithTimeout' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Expectations[/\\]main.swift:[[@LINE+8]]: error: ExpectationsTestCase.test_combiningInverseAndStandardExpectationsFailWithTimeout : Asynchronous wait failed - Exceeded timeout of 0.5 seconds, with unfulfilled expectations: bar
// CHECK: Test Case 'ExpectationsTestCase.test_combiningInverseAndStandardExpectationsFailWithTimeout' failed \(\d+\.\d+ seconds\)
    func test_combiningInverseAndStandardExpectationsFailWithTimeout() {
        let foo = expectation(description: "foo")
        foo.isInverted = true
        expectation(description: "bar")

        let start = Date.timeIntervalSinceReferenceDate
        waitForExpectations(timeout: 0.5)

        // Make sure we actually waited long enough.
        XCTAssertGreaterThanOrEqual(Date.timeIntervalSinceReferenceDate - start, 0.5)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_combiningInverseAndStandardExpectationsFailWithInverseFulfillment' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Expectations[/\\]main.swift:[[@LINE+8]]: error: ExpectationsTestCase.test_combiningInverseAndStandardExpectationsFailWithInverseFulfillment : Asynchronous wait failed - Fulfilled inverted expectation 'foo'
// CHECK: Test Case 'ExpectationsTestCase.test_combiningInverseAndStandardExpectationsFailWithInverseFulfillment' failed \(\d+\.\d+ seconds\)
    func test_combiningInverseAndStandardExpectationsFailWithInverseFulfillment() {
        let foo = expectation(description: "foo")
        foo.isInverted = true
        let bar = expectation(description: "bar")

        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.1) {
            foo.fulfill()
            bar.fulfill()
        }

        waitForExpectations(timeout: 0.5)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_combiningInverseAndStandardExpectationsWithOrderingEnforcement' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ExpectationsTestCase.test_combiningInverseAndStandardExpectationsWithOrderingEnforcement' passed \(\d+\.\d+ seconds\)
    func test_combiningInverseAndStandardExpectationsWithOrderingEnforcement() {
        var a, b, c: XCTestExpectation
        var start: CFAbsoluteTime

        a = XCTestExpectation(description: "a")
        a.isInverted = true
        b = XCTestExpectation(description: "b")
        c = XCTestExpectation(description: "c")
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.01) {
            b.fulfill()
            c.fulfill()
        }

        start = Date.timeIntervalSinceReferenceDate
        wait(for: [a, b, c], timeout: 0.2, enforceOrder: true)
        XCTAssertGreaterThanOrEqual(Date.timeIntervalSinceReferenceDate - start, 0.2)

        a = XCTestExpectation(description: "a")
        a.isInverted = true
        b = XCTestExpectation(description: "b")
        c = XCTestExpectation(description: "c")
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.01) {
            b.fulfill()
            c.fulfill()
        }

        start = Date.timeIntervalSinceReferenceDate
        wait(for: [b, a, c], timeout: 0.2, enforceOrder: true)
        XCTAssertGreaterThanOrEqual(Date.timeIntervalSinceReferenceDate - start, 0.2)

        a = XCTestExpectation(description: "a")
        a.isInverted = true
        b = XCTestExpectation(description: "b")
        c = XCTestExpectation(description: "c")
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.01) {
            b.fulfill()
            c.fulfill()
        }

        start = Date.timeIntervalSinceReferenceDate
        wait(for: [b, c, a], timeout: 0.2, enforceOrder: true)
        XCTAssertGreaterThanOrEqual(Date.timeIntervalSinceReferenceDate - start, 0.2)
    }

    // PRAGMA MARK: - Counted Expectations

// CHECK: Test Case 'ExpectationsTestCase.test_countedConditionPass' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ExpectationsTestCase.test_countedConditionPass' passed \(\d+\.\d+ seconds\)
    func test_countedConditionPass() {
        let foo = expectation(description: "foo")
        foo.expectedFulfillmentCount = 2
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.05) {
            foo.fulfill()
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.05) {
                foo.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_countedConditionPassBeforeWaiting' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ExpectationsTestCase.test_countedConditionPassBeforeWaiting' passed \(\d+\.\d+ seconds\)
    func test_countedConditionPassBeforeWaiting() {
        let foo = expectation(description: "foo")
        foo.expectedFulfillmentCount = 2
        foo.fulfill()
        foo.fulfill()
        waitForExpectations(timeout: 1)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_countedConditionFail' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Expectations[/\\]main.swift:[[@LINE+8]]: error: ExpectationsTestCase.test_countedConditionFail : Asynchronous wait failed - Exceeded timeout of 0.2 seconds, with unfulfilled expectations: foo
// CHECK: Test Case 'ExpectationsTestCase.test_countedConditionFail' failed \(\d+\.\d+ seconds\)
    func test_countedConditionFail() {
        let foo = expectation(description: "foo")
        foo.expectedFulfillmentCount = 2
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.01) {
            foo.fulfill()
        }
        waitForExpectations(timeout: 0.2)
    }

    // PRAGMA MARK: - assertForOverFulfill

// CHECK: Test Case 'ExpectationsTestCase.test_assertForOverfulfill_disabled' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ExpectationsTestCase.test_assertForOverfulfill_disabled' passed \(\d+\.\d+ seconds\)
    func test_assertForOverfulfill_disabled() {
        let foo = XCTestExpectation(description: "foo")
        XCTAssertFalse(foo.assertForOverFulfill, "assertForOverFulfill should be disabled by default")
        foo.fulfill()
        foo.fulfill()
    }

// CHECK: Test Case 'ExpectationsTestCase.test_assertForOverfulfill_failure' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Expectations[/\\]main.swift:[[@LINE+7]]: error: ExpectationsTestCase.test_assertForOverfulfill_failure : API violation - multiple calls made to XCTestExpectation.fulfill\(\) for rob.
// CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Expectations[/\\]main.swift:[[@LINE+16]]: error: ExpectationsTestCase.test_assertForOverfulfill_failure : API violation - multiple calls made to XCTestExpectation.fulfill\(\) for rob.
// CHECK: Test Case 'ExpectationsTestCase.test_assertForOverfulfill_failure' failed \(\d+\.\d+ seconds\)
    func test_assertForOverfulfill_failure() {
        let expectation = self.expectation(description: "rob")
        expectation.assertForOverFulfill = true
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

    // PRAGMA MARK: - Interrupted Waiters

    // Disabled due to non-deterministic ordering of XCTWaiterDelegate callbacks, see [SR-10034] and <rdar://problem/49123061>
/*
    CHECK: Test Case 'ExpectationsTestCase.test_outerWaiterTimesOut_InnerWaitersAreInterrupted' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Expectations[/\\]main.swift:[[@LINE+22]]: error: ExpectationsTestCase.test_outerWaiterTimesOut_InnerWaitersAreInterrupted : Asynchronous wait failed - Exceeded timeout of 0.1 seconds, with unfulfilled expectations: outer
    CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Expectations[/\\]main.swift:[[@LINE+11]]: error: ExpectationsTestCase.test_outerWaiterTimesOut_InnerWaitersAreInterrupted : Asynchronous waiter <XCTWaiter expectations: 'inner-1'> failed - Interrupted by timeout of containing waiter <XCTWaiter expectations: 'outer'>
    CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Expectations[/\\]main.swift:[[@LINE+15]]: error: ExpectationsTestCase.test_outerWaiterTimesOut_InnerWaitersAreInterrupted : Asynchronous waiter <XCTWaiter expectations: 'inner-2'> failed - Interrupted by timeout of containing waiter <XCTWaiter expectations: 'outer'>
    CHECK: Test Case 'ExpectationsTestCase.test_outerWaiterTimesOut_InnerWaitersAreInterrupted' failed \(\d+\.\d+ seconds\)
 */
    func test_outerWaiterTimesOut_InnerWaitersAreInterrupted() {
        let outerWaiter = XCTWaiter(delegate: self)
        let outerExpectation = XCTestExpectation(description: "outer")

        RunLoop.main.perform {
            do {
                let innerWaiter = XCTWaiter(delegate: self)
                let innerExpectation = XCTestExpectation(description: "inner-1")
                XCTAssertEqual(innerWaiter.wait(for: [innerExpectation], timeout: 1), .interrupted, "waiting for \(innerExpectation.expectationDescription)")
            }
            do {
                let innerWaiter = XCTWaiter(delegate: self)
                let innerExpectation = XCTestExpectation(description: "inner-2")
                XCTAssertEqual(innerWaiter.wait(for: [innerExpectation], timeout: 1), .interrupted, "waiting for \(innerExpectation.expectationDescription)")
            }
        }

        let start = Date.timeIntervalSinceReferenceDate
        let result = outerWaiter.wait(for: [outerExpectation], timeout: 0.1)
        let durationOfOuterWait = Date.timeIntervalSinceReferenceDate - start
        XCTAssertEqual(result, .timedOut)

        // The theoretical best-case duration in the current implementation is:
        //     `timeout` (.1) + `kOuterTimeoutSlop` (.25) = .35
        // Adding some leeway for other system activity brings us to this value for the assertion.
        XCTAssertLessThanOrEqual(durationOfOuterWait, 0.65)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_outerWaiterCompletes_InnerWaiterTimesOut' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Expectations[/\\]main.swift:[[@LINE+14]]: error: ExpectationsTestCase.test_outerWaiterCompletes_InnerWaiterTimesOut : Asynchronous wait failed - Exceeded timeout of 1.0 seconds, with unfulfilled expectations: inner
// CHECK: Test Case 'ExpectationsTestCase.test_outerWaiterCompletes_InnerWaiterTimesOut' failed \(\d+\.\d+ seconds\)
    func test_outerWaiterCompletes_InnerWaiterTimesOut() {
        let outerWaiter = XCTWaiter(delegate: self)
        let outerExpectation = XCTestExpectation(description: "outer")

        var outerExpectationFulfillTime = CFAbsoluteTime(0)
        RunLoop.main.perform {
            RunLoop.main.perform {
                outerExpectationFulfillTime = Date.timeIntervalSinceReferenceDate
                outerExpectation.fulfill()
            }
            let innerWaiter = XCTWaiter(delegate: self)
            let innerExpectation = XCTestExpectation(description: "inner")
            XCTAssertEqual(innerWaiter.wait(for: [innerExpectation], timeout: 1), .timedOut)
        }

        let start = Date.timeIntervalSinceReferenceDate
        XCTAssertEqual(outerWaiter.wait(for: [outerExpectation], timeout: 1), .completed)
        XCTAssertLessThanOrEqual(outerExpectationFulfillTime - start, 0.1)
        XCTAssertGreaterThanOrEqual(Date.timeIntervalSinceReferenceDate - start, 1)
    }

    // PRAGMA MARK: - Waiter Conveniences

// CHECK: Test Case 'ExpectationsTestCase.test_classWait' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ExpectationsTestCase.test_classWait' passed \(\d+\.\d+ seconds\)
    func test_classWait() {
        var a, b: XCTestExpectation

        a = XCTestExpectation(description: "a")
        b = XCTestExpectation(description: "b")
        XCTAssertEqual(XCTWaiter.wait(for: [a, b], timeout: 0.01), .timedOut)

        a = XCTestExpectation(description: "a")
        b = XCTestExpectation(description: "b")
        a.fulfill()
        b.fulfill()
        XCTAssertEqual(XCTWaiter.wait(for: [a, b], timeout: 1), .completed)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_classWaitEnforcingOrder' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ExpectationsTestCase.test_classWaitEnforcingOrder' passed \(\d+\.\d+ seconds\)
    func test_classWaitEnforcingOrder() {
        let a = XCTestExpectation(description: "a")
        let b = XCTestExpectation(description: "b")
        b.fulfill()
        a.fulfill()
        XCTAssertEqual(XCTWaiter.wait(for: [a, b], timeout: 1, enforceOrder: true), .incorrectOrder)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_classWaitInverseExpectationFail' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ExpectationsTestCase.test_classWaitInverseExpectationFail' passed \(\d+\.\d+ seconds\)
    func test_classWaitInverseExpectationFail() {
        let a = XCTestExpectation(description: "a")
        a.isInverted = true
        a.fulfill()
        XCTAssertEqual(XCTWaiter.wait(for: [a], timeout: 0.001), .invertedFulfillment)
    }

    // PRAGMA MARK: - Regressions

// CHECK: Test Case 'ExpectationsTestCase.test_fulfillmentOnSecondaryThread' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ExpectationsTestCase.test_fulfillmentOnSecondaryThread' passed \(\d+\.\d+ seconds\)
    func test_fulfillmentOnSecondaryThread() {
        let foo = expectation(description: "foo")
        DispatchQueue.global(qos: .default).async {
            foo.fulfill()
        }
        waitForExpectations(timeout: 1)
    }

// CHECK: Test Case 'ExpectationsTestCase.test_runLoopInsideDispatch' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Expectations[/\\]main.swift:[[@LINE+8]]: error: ExpectationsTestCase.test_runLoopInsideDispatch : Asynchronous wait failed - Exceeded timeout of 0.5 seconds, with unfulfilled expectations: foo
// CHECK: Test Case 'ExpectationsTestCase.test_runLoopInsideDispatch' failed \(\d+\.\d+ seconds\)
    func test_runLoopInsideDispatch() {
        DispatchQueue.main.async {
            var foo: XCTestExpectation? = self.expectation(description: "foo")
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.1) {
                foo?.fulfill()
            }
            self.waitForExpectations(timeout: 0.5)
            foo = nil
        }
        RunLoop.main.run(until: Date() + 1)
    }

    static var allTests = {
        return [
            ("test_waitingForAnUnfulfilledExpectation_fails", test_waitingForAnUnfulfilledExpectation_fails),
            ("test_waitingForUnfulfilledExpectations_outputsAllExpectations_andFails", test_waitingForUnfulfilledExpectations_outputsAllExpectations_andFails),
            ("test_waitingForAnImmediatelyFulfilledExpectation_passes", test_waitingForAnImmediatelyFulfilledExpectation_passes),
            ("test_waitingForAnEventuallyFulfilledExpectation_passes", test_waitingForAnEventuallyFulfilledExpectation_passes),
            ("test_waitingForAnExpectationFulfilledAfterTheTimeout_fails", test_waitingForAnExpectationFulfilledAfterTheTimeout_fails),
            ("test_whenTimeoutIsImmediate_andAllExpectationsAreFulfilled_passes", test_whenTimeoutIsImmediate_andAllExpectationsAreFulfilled_passes),
            ("test_whenTimeoutIsImmediate_butNotAllExpectationsAreFulfilled_fails", test_whenTimeoutIsImmediate_butNotAllExpectationsAreFulfilled_fails),

            // Multiple Expectations
            ("test_multipleExpectations", test_multipleExpectations),
            ("test_multipleExpectationsEnforceOrderingCorrect", test_multipleExpectationsEnforceOrderingCorrect),
            ("test_multipleExpectationsEnforceOrderingCorrectBeforeWait", test_multipleExpectationsEnforceOrderingCorrectBeforeWait),
            ("test_multipleExpectationsEnforceOrderingIncorrect", test_multipleExpectationsEnforceOrderingIncorrect),
            ("test_multipleExpectationsIncludingInvertedEnforceOrderingIncorrect", test_multipleExpectationsIncludingInvertedEnforceOrderingIncorrect),
            ("test_multipleExpectationsEnforceOrderingIncorrectBeforeWait", test_multipleExpectationsEnforceOrderingIncorrectBeforeWait),
            ("test_multipleExpectationsEnforceOrderingStressTest", test_multipleExpectationsEnforceOrderingStressTest),

            // Inverse Expectations
            ("test_inverseExpectationPass", test_inverseExpectationPass),
            ("test_inverseExpectationFail", test_inverseExpectationFail),
            ("test_inverseExpectationFulfilledBeforeWait", test_inverseExpectationFulfilledBeforeWait),
            ("test_combiningInverseAndStandardExpectationsPass", test_combiningInverseAndStandardExpectationsPass),
            ("test_combiningInverseAndStandardExpectationsFailWithTimeout", test_combiningInverseAndStandardExpectationsFailWithTimeout),
            ("test_combiningInverseAndStandardExpectationsFailWithInverseFulfillment", test_combiningInverseAndStandardExpectationsFailWithInverseFulfillment),
            ("test_combiningInverseAndStandardExpectationsWithOrderingEnforcement", test_combiningInverseAndStandardExpectationsWithOrderingEnforcement),

            // Counted Expectations
            ("test_countedConditionPass", test_countedConditionPass),
            ("test_countedConditionPassBeforeWaiting", test_countedConditionPassBeforeWaiting),
            ("test_countedConditionFail", test_countedConditionFail),

            // assertForOverFulfill
            ("test_assertForOverfulfill_disabled", test_assertForOverfulfill_disabled),
            ("test_assertForOverfulfill_failure", test_assertForOverfulfill_failure),

            // Interrupted Waiters
//            ("test_outerWaiterTimesOut_InnerWaitersAreInterrupted", test_outerWaiterTimesOut_InnerWaitersAreInterrupted),
            ("test_outerWaiterCompletes_InnerWaiterTimesOut", test_outerWaiterCompletes_InnerWaiterTimesOut),

            // Waiter Conveniences
            ("test_classWait", test_classWait),
            ("test_classWaitEnforcingOrder", test_classWaitEnforcingOrder),
            ("test_classWaitInverseExpectationFail", test_classWaitInverseExpectationFail),

            // Regressions
            ("test_fulfillmentOnSecondaryThread", test_fulfillmentOnSecondaryThread),
            ("test_runLoopInsideDispatch", test_runLoopInsideDispatch),
        ]
    }()
}
// CHECK: Test Suite 'ExpectationsTestCase' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 32 tests, with 16 failures \(2 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([testCase(ExpectationsTestCase.allTests)])

// CHECK: Test Suite '.*\.xctest' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 32 tests, with 16 failures \(2 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 32 tests, with 16 failures \(2 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
