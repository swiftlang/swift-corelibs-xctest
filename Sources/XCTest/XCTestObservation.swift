// This source file is part of the Swift.org open source project
//
// Copyright (c) 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTestObservation.swift
//  Hooks for being notified about progress during a test run.
//

/// `XCTestObservation` provides hooks for being notified about progress during a
/// test run.
/// - seealso: `XCTestObservationCenter`
public protocol XCTestObservation: class {
    /// Called just before a test begins executing.
    /// - Parameter testCase: The test case that is about to start. Its `name`
    ///   property can be used to identify it.
    func testCaseWillStart(testCase: XCTestCase)

    /// Called when a test failure is reported.
    /// - Parameter testCase: The test case that failed. Its `name` property 
    ///   can be used to identify it.
    /// - Parameter description: Details about the cause of the test failure.
    /// - Parameter filePath: The path to the source file where the failure
    ///   was reported, if available.
    /// - Parameter lineNumber: The line number in the source file where the
    ///   failure was reported.
    func testCase(testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt)

    /// Called just after a test finishes executing.
    /// - Parameter testCase: The test case that finished. Its `name` property 
    ///   can be used to identify it.
    func testCaseDidFinish(testCase: XCTestCase)
}

// All `XCTestObservation` methods are optional, so empty default implementations are provided
public extension XCTestObservation {
    func testCaseWillStart(testCase: XCTestCase) {}
    func testCase(testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {}
    func testCaseDidFinish(testCase: XCTestCase) {}
}
