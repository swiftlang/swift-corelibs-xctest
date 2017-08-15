// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTestExpectation.swift
//  Expectations represent specific conditions in asynchronous testing.
//

/// Expectations represent specific conditions in asynchronous testing.
public class XCTestExpectation {
    internal let description: String
    internal let file: StaticString
    internal let line: Int

    internal var isFulfilled = false
    internal weak var testCase: XCTestCase?

    internal init(description: String, file: StaticString, line: Int, testCase: XCTestCase) {
        self.description = description
        self.file = file
        self.line = line
        self.testCase = testCase
    }

    /// Marks an expectation as having been met. It's an error to call this
    /// method on an expectation that has already been fulfilled, or when the
    /// test case that vended the expectation has already completed.
    ///
    /// - Parameter file: The file name to use in the error message if
    ///   expectations are not met before the given timeout. Default is the file
    ///   containing the call to this method. It is rare to provide this
    ///   parameter when calling this method.
    /// - Parameter line: The line number to use in the error message if the
    ///   expectations are not met before the given timeout. Default is the line
    ///   number of the call to this method in the calling file. It is rare to
    ///   provide this parameter when calling this method.
    ///
    /// - Note: Whereas Objective-C XCTest determines the file and line
    ///   number the expectation was fulfilled using symbolication, this
    ///   implementation opts to take `file` and `line` as parameters instead.
    ///   As a result, the interface to these methods are not exactly identical
    ///   between these environments. To ensure compatibility of tests between
    ///   swift-corelibs-xctest and Apple XCTest, it is not recommended to pass
    ///   explicit values for `file` and `line`.
    public func fulfill(_ file: StaticString = #file, line: Int = #line) {
        // FIXME: Objective-C XCTest emits failures when expectations are
        //        fulfilled after the test cases that generated those
        //        expectations have completed. Similarly, this should cause an
        //        error as well.
        if isFulfilled {
            // Mirror Objective-C XCTest behavior: treat multiple calls to
            // fulfill() as an unexpected failure.
            if let testCase = XCTCurrentTestCase {
                testCase.recordFailure(
                    withDescription: "API violation - multiple calls made to XCTestExpectation.fulfill() for \(description).",
                    inFile: String(describing: file),
                    atLine: line,
                    expected: false)
            }
        } else {
            isFulfilled = true
        }
    }
}
