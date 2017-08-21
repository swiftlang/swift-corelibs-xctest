// This source file is part of the Swift.org open source project
//
// Copyright (c) 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTestCase+Asynchronous.swift
//  Methods on XCTestCase for testing asynchronous operations
//

public extension XCTestCase {

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
    @discardableResult func expectation(description: String, file: StaticString = #file, line: Int = #line) -> XCTestExpectation {
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
    func waitForExpectations(timeout: TimeInterval, file: StaticString = #file, line: Int = #line, handler: XCWaitCompletionHandler? = nil) {
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
                inFile: String(describing: file),
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
        let runLoop = RunLoop.current
        let timeoutDate = Date(timeIntervalSinceNow: timeout)
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
            runLoop.run(until: Date(timeIntervalSinceNow: 0.01))
        } while Date().compare(timeoutDate) == ComparisonResult.orderedAscending

        if unfulfilledDescriptions.count > 0 {
            // Not all expectations were fulfilled. Append a failure
            // to the array of expectation-based failures.
            let descriptions = unfulfilledDescriptions.joined(separator: ", ")
            recordFailure(
                withDescription: "Asynchronous wait failed - Exceeded timeout of \(timeout) seconds, with unfulfilled expectations: \(descriptions)",
                inFile: String(describing: file),
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
                    code: XCTestError.Code.timeoutWhileWaiting.rawValue,
                    userInfo: [:])
            }
            completionHandler(error)
        }
    }
}

internal extension XCTestCase {
    /// It is an API violation to create expectations but not wait for them to
    /// be completed. Notify the user of a mistake via a test failure.
    func failIfExpectationsNotWaitedFor(_ expectations: [XCTestExpectation]) {
        if expectations.count > 0 {
            recordFailure(
                withDescription: "Failed due to unwaited expectations.",
                inFile: String(describing: expectations.last!.file),
                atLine: expectations.last!.line,
                expected: false)
        }
    }
}
