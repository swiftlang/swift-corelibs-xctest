// This source file is part of the Swift.org open source project
//
// Copyright (c) 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTestSuiteRun.swift
//  A test run for an `XCTestSuite`.
//

#if os(Linux) || os(FreeBSD)
    import Foundation
#else
    import SwiftFoundation
#endif

/// A test run for an `XCTestSuite`.
public class XCTestSuiteRun: XCTestRun {
    /// The combined `testDuration` of each test case run in the suite.
    public override var totalDuration: TimeInterval {
        return testRuns.reduce(TimeInterval(0.0)) { $0 + $1.totalDuration }
    }

    /// The combined execution count of each test case run in the suite.
    public override var executionCount: UInt {
        return testRuns.reduce(0) { $0 + $1.executionCount }
    }

    /// The combined failure count of each test case run in the suite.
    public override var failureCount: UInt {
        return testRuns.reduce(0) { $0 + $1.failureCount }
    }

    /// The combined unexpected failure count of each test case run in the
    /// suite.
    public override var unexpectedExceptionCount: UInt {
        return testRuns.reduce(0) { $0 + $1.unexpectedExceptionCount }
    }

    public override func start() {
        super.start()
        XCTestObservationCenter.shared().testSuiteWillStart(testSuite)
    }

    public override func stop() {
        super.stop()
        XCTestObservationCenter.shared().testSuiteDidFinish(testSuite)
    }

    /// The test run for each of the tests in this suite.
    /// Depending on what kinds of tests this suite is composed of, these could
    /// be some combination of `XCTestCaseRun` and `XCTestSuiteRun` objects.
    public private(set) var testRuns = [XCTestRun]()

    /// Add a test run to the collection of `testRuns`.
    /// - Note: It is rare to call this method outside of XCTest itself.
    public func addTestRun(_ testRun: XCTestRun) {
        testRuns.append(testRun)
    }

    private var testSuite: XCTestSuite {
        return test as! XCTestSuite
    }
}
