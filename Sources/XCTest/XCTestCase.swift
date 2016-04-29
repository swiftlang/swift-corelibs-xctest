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
/// `XCTestCase` subclass type with the list of test case methods to invoke on the class.
/// This type is intended to be produced by the `testCase` helper function.
/// - seealso: `testCase`
/// - seealso: `XCTMain`
public typealias XCTestCaseEntry = (testCaseClass: XCTestCase.Type, allTests: [(String, XCTestCase throws -> Void)])

// A global pointer to the currently running test case. This is required in
// order for XCTAssert functions to report failures.
internal var XCTCurrentTestCase: XCTestCase?

/// An instance of this class represents an individual test case which can be
/// run by the framework. This class is normally subclassed and extended with
/// methods containing the tests to run.
/// - seealso: `XCTMain`
public class XCTestCase: XCTest {
    private let testClosure: XCTestCase throws -> Void

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

    public override var testCaseCount: UInt {
        return 1
    }

    /// The set of expectations made upon this test case.
    /// - Note: FIXME: This is meant to be a `private var`, but is marked as
    ///   `public` here to work around a Swift compiler bug on Linux. To ensure
    ///   compatibility of tests between swift-corelibs-xctest and Apple XCTest,
    ///   this property should not be modified. See
    ///   https://bugs.swift.org/browse/SR-1129 for details.
    public var _allExpectations = [XCTestExpectation]()

    public override var testRunClass: AnyClass? {
        return XCTestCaseRun.self
    }

    public override func perform(_ run: XCTestRun) {
        guard let testRun = run as? XCTestCaseRun else {
            fatalError("Wrong XCTestRun class.")
        }

        XCTCurrentTestCase = self
        testRun.start()
        invokeTest()
        failIfExpectationsNotWaitedFor(_allExpectations)
        testRun.stop()
        XCTCurrentTestCase = nil
    }

    /// The designated initializer for SwiftXCTest's XCTestCase.
    /// - Note: Like the designated initializer for Apple XCTest's XCTestCase,
    ///   `-[XCTestCase initWithInvocation:]`, it's rare for anyone outside of
    ///   XCTest itself to call this initializer.
    public required init(name: String, testClosure: XCTestCase throws -> Void) {
        _name = "\(self.dynamicType).\(name)"
        self.testClosure = testClosure
    }

    /// Invoking a test performs its setUp, invocation, and tearDown. In
    /// general this should not be called directly.
    public func invokeTest() {
        setUp()
        do {
            try testClosure(self)
        } catch {
            recordFailure(
                withDescription: "threw error \"\(error)\"",
                inFile: "<EXPR>",
                atLine: 0,
                expected: false)
        }
        tearDown()
    }

    /// Records a failure in the execution of the test and is used by all test
    /// assertions.
    /// - Parameter description: The description of the failure being reported.
    /// - Parameter filePath: The file path to the source file where the failure
    ///   being reported was encountered.
    /// - Parameter lineNumber: The line number in the source file at filePath
    ///   where the failure being reported was encountered.
    /// - Parameter expected: `true` if the failure being reported was the
    ///   result of a failed assertion, `false` if it was the result of an
    ///   uncaught exception.
    public func recordFailure(withDescription description: String, inFile filePath: String, atLine lineNumber: UInt, expected: Bool) {
        testRun?.recordFailure(
            withDescription: description,
            inFile: filePath,
            atLine: lineNumber,
            expected: expected)

        // FIXME: Apple XCTest does not throw a fatal error and crash the test
        //        process, it merely prevents the remainder of a testClosure
        //        from execting after it's been determined that it has already
        //        failed. The following behavior is incorrect.
        // FIXME: No regression tests exist for this feature. We may break it
        //        without ever realizing.
        if !continueAfterFailure {
            fatalError("Terminating execution due to test failure")
        }
    }

    /// Setup method called before the invocation of any test method in the
    /// class.
    public class func setUp() {}

    /// Teardown method called after the invocation of every test method in the
    /// class.
    public class func tearDown() {}
}

/// Wrapper function allowing an array of static test case methods to fit
/// the signature required by `XCTMain`
/// - seealso: `XCTMain`
public func testCase<T: XCTestCase>(_ allTests: [(String, T -> () throws -> Void)]) -> XCTestCaseEntry {
    let tests: [(String, XCTestCase throws -> Void)] = allTests.map { ($0.0, test($0.1)) }
    return (T.self, tests)
}

private func test<T: XCTestCase>(_ testFunc: T -> () throws -> Void) -> XCTestCase throws -> Void {
    return { testCaseType in
        guard let testCase = testCaseType as? T else {
            fatalError("Attempt to invoke test on class \(T.self) with incompatible instance type \(testCaseType.dynamicType)")
        }

        try testFunc(testCase)()
    }
}

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

    /// It is an API violation to create expectations but not wait for them to
    /// be completed. Notify the user of a mistake via a test failure.
    private func failIfExpectationsNotWaitedFor(_ expectations: [XCTestExpectation]) {
        if expectations.count > 0 {
            recordFailure(
                withDescription: "Failed due to unwaited expectations.",
                inFile: String(expectations.last!.file),
                atLine: expectations.last!.line,
                expected: false)
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
    public func expectation(withDescription description: String, file: StaticString = #file, line: UInt = #line) -> XCTestExpectation {
        let expectation = XCTestExpectation(
            description: description,
            file: file,
            line: line,
            testCase: self)
        _allExpectations.append(expectation)
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
    public func waitForExpectations(withTimeout timeout: NSTimeInterval, file: StaticString = #file, line: UInt = #line, handler: XCWaitCompletionHandler? = nil) {
        // Mirror Objective-C XCTest behavior; display an unexpected test
        // failure when users wait without having first set expectations.
        // FIXME: Objective-C XCTest raises an exception for most "API
        //        violation" failures, including this one. Normally this causes
        //        the test to stop cold. swift-corelibs-xctest does not stop,
        //        and executes the rest of the test. This discrepancy should be
        //        fixed.
        if _allExpectations.count == 0 {
            recordFailure(
                withDescription: "API violation - call made to wait without any expectations having been set.",
                inFile: String(file),
                atLine: line,
                expected: false)
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
            for expectation in _allExpectations {
                if !expectation.isFulfilled {
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
            recordFailure(
                withDescription: "Asynchronous wait failed - Exceeded timeout of \(timeout) seconds, with unfulfilled expectations: \(descriptions)",
                inFile: String(file),
                atLine: line,
                expected: true)
        }

        // We've recorded all the failures; clear the expectations that
        // were set for this test case.
        _allExpectations = []

        // The handler is invoked regardless of whether the test passed.
        if let completionHandler = handler {
            var error: NSError? = nil
            if unfulfilledDescriptions.count > 0 {
                // If the test failed, send an error object.
                error = NSError(
                    domain: XCTestErrorDomain,
                    code: XCTestErrorCode.timeoutWhileWaiting.rawValue,
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
    public func expectation(forNotification notificationName: String, object objectToObserve: AnyObject?, handler: XCNotificationExpectationHandler? = nil) -> XCTestExpectation {
        let objectDescription = objectToObserve == nil ? "any object" : "\(objectToObserve!)"
        let expectation = self.expectation(withDescription: "Expect notification '\(notificationName)' from " + objectDescription)
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
