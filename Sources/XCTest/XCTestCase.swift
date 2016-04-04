// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTestCase.swift
//  Base class for test cases
//

#if os(Linux) || os(FreeBSD)
    import Foundation
#else
    import SwiftFoundation
#endif

/// This is a compound type used by `XCTMain` to represent tests to run. It combines an
/// `XCTestCase` subclass type with the list of test methods to invoke on the test case.
/// This type is intended to be produced by the `testCase` helper function.
/// - seealso: `testCase`
/// - seealso: `XCTMain`
public typealias XCTestCaseEntry = (testCaseClass: XCTestCase.Type, allTests: [(String, XCTestCase throws -> Void)])

public class XCTestCase: XCTest {

    /// The name of the test case, consisting of its class name and the method
    /// name it will run.
    public override var name: String {
        return _name
    }
    /// A private setter for the name of this test case.
    /// - Note: FIXME: This property should be readonly, but currently has to
    ///   be publicly settable due to a Swift compiler bug on Linux. To ensure
    ///   compatibility of tests between swift-corelibs-xctest and Apple XCTest,
    ///   this property should not be modified. See
    ///   https://bugs.swift.org/browse/SR-1129 for details.
    public var _name: String

    public required override init() {
        _name = "\(self.dynamicType).<unknown>"
    }
}

/// Wrapper function allowing an array of static test case methods to fit
/// the signature required by `XCTMain`
/// - seealso: `XCTMain`
public func testCase<T: XCTestCase>(allTests: [(String, T -> () throws -> Void)]) -> XCTestCaseEntry {
    let tests: [(String, XCTestCase throws -> Void)] = allTests.map { ($0.0, test($0.1)) }
    return (T.self, tests)
}

private func test<T: XCTestCase>(testFunc: T -> () throws -> Void) -> XCTestCase throws -> Void {
    return { testCaseType in
        guard let testCase = testCaseType as? T else {
            fatalError("Attempt to invoke test on class \(T.self) with incompatible instance type \(testCaseType.dynamicType)")
        }

        try testFunc(testCase)()
    }
}

// FIXME: Expectations should be stored in an instance variable defined on
//        `XCTestCase`, but when so defined Linux tests fail with "hidden symbol
//        isn't defined". Use a global for the time being, as this seems to
//        appease the Linux compiler.
private var XCTAllExpectations = [XCTestExpectation]()

extension XCTestCase {
    
    public var continueAfterFailure: Bool {
        get {
            return true
        }
        set {
            // TODO: When using the Objective-C runtime, XCTest is able to throw an exception from an assert and then catch it at the frame above the test method.
            //      This enables the framework to effectively stop all execution in the current test.
            //      There is no such facility in Swift. Until we figure out how to get a compatible behavior,
            //      we have decided to hard-code the value of 'true' for continue after failure.
        }
    }

    internal static func invokeTests(tests: [(String, XCTestCase throws -> Void)]) {
        let observationCenter = XCTestObservationCenter.shared()

        var totalDuration = 0.0
        var totalFailures = 0
        var unexpectedFailures = 0
        let overallDuration = measureTimeExecutingBlock {
            for (name, test) in tests {
                let testCase = self.init()
                testCase._name = "\(testCase.dynamicType).\(name)"

                var failures = [XCTFailure]()
                XCTFailureHandler = { failure in
                    observationCenter.testCase(testCase,
                                               didFailWithDescription: failure.failureMessage,
                                               inFile: String(failure.file),
                                               atLine: failure.line)

                    if !testCase.continueAfterFailure {
                        failure.emit(testCase.name)
                        fatalError("Terminating execution due to test failure", file: failure.file, line: failure.line)
                    } else {
                        failures.append(failure)
                    }
                }

                XCTPrint("Test Case '\(testCase.name)' started.")

                observationCenter.testCaseWillStart(testCase)

                testCase.setUp()

                let duration = measureTimeExecutingBlock {
                    do {
                        try test(testCase)
                    } catch {
                        let unexpectedFailure = XCTFailure(message: "", failureDescription: "threw error \"\(error)\"", expected: false, file: "<EXPR>", line: 0)
                        XCTFailureHandler!(unexpectedFailure)
                    }
                }

                testCase.tearDown()
                testCase.failIfExpectationsNotWaitedFor(XCTAllExpectations)
                XCTAllExpectations = []

                observationCenter.testCaseDidFinish(testCase)

                totalDuration += duration

                var result = "passed"
                for failure in failures {
                    failure.emit(testCase.name)
                    totalFailures += 1
                    if !failure.expected {
                        unexpectedFailures += 1
                    }
                    result = failures.count > 0 ? "failed" : "passed"
                }

                XCTPrint("Test Case '\(testCase.name)' \(result) (\(printableStringForTimeInterval(duration)) seconds).")
                XCTAllRuns.append(XCTRun(duration: duration, method: testCase.name, passed: failures.count == 0, failures: failures))
                XCTFailureHandler = nil
            }
        }

        let testCountSuffix = (tests.count == 1) ? "" : "s"
        let failureSuffix = (totalFailures == 1) ? "" : "s"

        XCTPrint("Executed \(tests.count) test\(testCountSuffix), with \(totalFailures) failure\(failureSuffix) (\(unexpectedFailures) unexpected) in \(printableStringForTimeInterval(totalDuration)) (\(printableStringForTimeInterval(overallDuration))) seconds")
    }

    /// It is an API violation to create expectations but not wait for them to
    /// be completed. Notify the user of a mistake via a test failure.
    private func failIfExpectationsNotWaitedFor(expectations: [XCTestExpectation]) {
        if expectations.count > 0 {
            let failure = XCTFailure(
                message: "Failed due to unwaited expectations.",
                failureDescription: "",
                expected: false,
                file: expectations.last!.file,
                line: expectations.last!.line)
            if let failureHandler = XCTFailureHandler {
                failureHandler(failure)
            }
        }
    }

    /// Creates and returns an expectation associated with the test case.
    ///
    /// - Parameter description: This string will be displayed in the test log
    ///   to help diagnose failures.
    /// - Parameter file: The file name to use in the error message if
    ///   this expectation is not waited for. Default is the file
    ///   containing the call to this method. It is rare to provide this
    ///   parameter when calling this method.
    /// - Parameter line: The line number to use in the error message if the
    ///   this expectation is not waited for. Default is the line
    ///   number of the call to this method in the calling file. It is rare to
    ///   provide this parameter when calling this method.
    ///
    /// - Note: Whereas Objective-C XCTest determines the file and line
    ///   number of expectations that are created by using symbolication, this
    ///   implementation opts to take `file` and `line` as parameters instead.
    ///   As a result, the interface to these methods are not exactly identical
    ///   between these environments. To ensure compatibility of tests between
    ///   swift-corelibs-xctest and Apple XCTest, it is not recommended to pass
    ///   explicit values for `file` and `line`.
    public func expectationWithDescription(description: String, file: StaticString = #file, line: UInt = #line) -> XCTestExpectation {
        let expectation = XCTestExpectation(
            description: description,
            file: file,
            line: line,
            testCase: self)
        XCTAllExpectations.append(expectation)
        return expectation
    }

    /// Creates a point of synchronization in the flow of a test. Only one
    /// "wait" can be active at any given time, but multiple discrete sequences
    /// of { expectations -> wait } can be chained together.
    ///
    /// - Parameter timeout: The amount of time within which all expectation
    ///   must be fulfilled.
    /// - Parameter file: The file name to use in the error message if
    ///   expectations are not met before the given timeout. Default is the file
    ///   containing the call to this method. It is rare to provide this
    ///   parameter when calling this method.
    /// - Parameter line: The line number to use in the error message if the
    ///   expectations are not met before the given timeout. Default is the line
    ///   number of the call to this method in the calling file. It is rare to
    ///   provide this parameter when calling this method.
    /// - Parameter handler: If provided, the handler will be invoked both on
    ///   timeout or fulfillment of all expectations. Timeout is always treated
    ///   as a test failure.
    ///
    /// - Note: Whereas Objective-C XCTest determines the file and line
    ///   number of the "wait" call using symbolication, this implementation
    ///   opts to take `file` and `line` as parameters instead. As a result,
    ///   the interface to these methods are not exactly identical between
    ///   these environments. To ensure compatibility of tests between
    ///   swift-corelibs-xctest and Apple XCTest, it is not recommended to pass
    ///   explicit values for `file` and `line`.
    public func waitForExpectationsWithTimeout(timeout: NSTimeInterval, file: StaticString = #file, line: UInt = #line, handler: XCWaitCompletionHandler?) {
        // Mirror Objective-C XCTest behavior; display an unexpected test
        // failure when users wait without having first set expectations.
        // FIXME: Objective-C XCTest raises an exception for most "API
        //        violation" failures, including this one. Normally this causes
        //        the test to stop cold. swift-corelibs-xctest does not stop,
        //        and executes the rest of the test. This discrepancy should be
        //        fixed.
        if XCTAllExpectations.count == 0 {
            let failure = XCTFailure(
                message: "call made to wait without any expectations having been set.",
                failureDescription: "API violation",
                expected: false,
                file: file,
                line: line)
            if let failureHandler = XCTFailureHandler {
                failureHandler(failure)
            }
            return
        }

        // Objective-C XCTest outputs the descriptions of every unfulfilled
        // expectation. We gather them into this array, which is also used
        // to determine failure--a non-empty array meets expectations weren't
        // met.
        var unfulfilledDescriptions = [String]()

        // We continue checking whether expectations have been fulfilled until
        // the specified timeout has been reached.
        // FIXME: Instead of polling the expectations to check whether they've
        //        been fulfilled, it would be more efficient to use a runloop
        //        source that can be signaled to wake up when an expectation is
        //        fulfilled.
        let runLoop = NSRunLoop.currentRunLoop()
        let timeoutDate = NSDate(timeIntervalSinceNow: timeout)
        repeat {
            unfulfilledDescriptions = []
            for expectation in XCTAllExpectations {
                if !expectation.fulfilled {
                    unfulfilledDescriptions.append(expectation.description)
                }
            }

            // If we've met all expectations, then break out of the specified
            // timeout loop early.
            if unfulfilledDescriptions.count == 0 {
                break
            }

            // Otherwise, wait another fraction of a second.
            runLoop.runUntilDate(NSDate(timeIntervalSinceNow: 0.01))
        } while NSDate().compare(timeoutDate) == NSComparisonResult.OrderedAscending

        if unfulfilledDescriptions.count > 0 {
            // Not all expectations were fulfilled. Append a failure
            // to the array of expectation-based failures.
            let descriptions = unfulfilledDescriptions.joined(separator: ", ")
            let failure = XCTFailure(
                message: "Exceeded timeout of \(timeout) seconds, with unfulfilled expectations: \(descriptions)",
                failureDescription: "Asynchronous wait failed",
                expected: true,
                file: file,
                line: line)
            if let failureHandler = XCTFailureHandler {
                failureHandler(failure)
            }
        }

        // We've recorded all the failures; clear the expectations that
        // were set for this test case.
        XCTAllExpectations = []

        // The handler is invoked regardless of whether the test passed.
        if let completionHandler = handler {
            var error: NSError? = nil
            if unfulfilledDescriptions.count > 0 {
                // If the test failed, send an error object.
                error = NSError(
                    domain: "org.swift.XCTestErrorDomain",
                    code: 0,
                    userInfo: [:])
            }
            completionHandler(error)
        }
    }
    
    /// Creates and returns an expectation for a notification.
    ///
    /// - Parameter notificationName: The name of the notification the
    ///   expectation observes.
    /// - Parameter object: The object whose notifications the expectation will
    ///   receive; that is, only notifications with this object are observed by
    ///   the test case. If you pass nil, the expectation doesn't use
    ///   a notification's object to decide whether it is fulfilled.
    /// - Parameter handler: If provided, the handler will be invoked when the
    ///   notification is observed. It will not be invoked on timeout. Use the
    ///   handler to further investigate if the notification fulfills the 
    ///   expectation.
    public func expectationForNotification(notificationName: String, object objectToObserve: AnyObject?, handler: XCNotificationExpectationHandler?) -> XCTestExpectation {
        let objectDescription = objectToObserve == nil ? "any object" : "\(objectToObserve!)"
        let expectation = self.expectationWithDescription("Expect notification '\(notificationName)' from " + objectDescription)
        // Start observing the notification with specified name and object.
        var observer: NSObjectProtocol? = nil
        func removeObserver() {
            if let observer = observer as? AnyObject {
                NSNotificationCenter.defaultCenter().removeObserver(observer)
            }
        }

        weak var weakExpectation = expectation
        observer = NSNotificationCenter
            .defaultCenter()
            .addObserverForName(notificationName,
                                object: objectToObserve,
                                queue: nil,
                                usingBlock: {
                                    notification in
                                    guard let expectation = weakExpectation else {
                                        removeObserver()
                                        return
                                    }

                                    // If the handler is invoked, the test will
                                    // only pass if true is returned.
                                    if let handler = handler {
                                        if handler(notification) {
                                            expectation.fulfill()
                                            removeObserver()
                                        }
                                    } else {
                                        expectation.fulfill()
                                        removeObserver()
                                    }
                })
        
        return expectation
    }

}
