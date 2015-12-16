// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTest.swift
//  This is the main file for the framework. It provides the entry point function
//  for running tests and some infrastructure for running them.
//

#if os(Linux)
import Glibc
#else
import Darwin
#endif

struct XCTFailure {
    var message: String
    var expected: Bool
    var file: StaticString
    var line: UInt
    
    func emit(method: String) {
        print("\(file):\(line): \(expected ? "" : "unexpected ")error: \(method) : \(message)")
    }
}

internal struct XCTRun {
    var duration: Double
    var method: String
    var passed: Bool
    var failures: [XCTFailure]
    var unexpectedFailures: [XCTFailure] {
        get { return failures.filter({ failure -> Bool in failure.expected == false }) }
    }
}

/// Starts a test run for the specified test cases.
///
/// This function will not return. If the test cases pass, then it will call `exit(0)`. If there is a failure, then it will call `exit(1)`.
/// - Parameter testCases: An array of test cases to run.
@noreturn public func XCTMain(testCases: [XCTestCase]) {
    for testCase in testCases {
        testCase.invokeTest()
    }
    let (totalDuration, totalFailures, totalUnexpectedFailures) = XCTAllRuns.reduce((0.0, 0, 0)) { totals, run in (totals.0 + run.duration, totals.1 + run.failures.count, totals.2 + run.unexpectedFailures.count) }
    
    var testCountSuffix = "s"
    if XCTAllRuns.count == 1 {
        testCountSuffix = ""
    }
    var failureSuffix = "s"
    if totalFailures == 1 {
        failureSuffix = ""
    }
    let averageDuration = totalDuration / Double(XCTAllRuns.count)
    print("Total executed \(XCTAllRuns.count) test\(testCountSuffix), with \(totalFailures) failure\(failureSuffix) (\(totalUnexpectedFailures) unexpected) in \(printableStringForTimeInterval(averageDuration)) (\(printableStringForTimeInterval(totalDuration))) seconds")
    exit(totalFailures > 0 ? 1 : 0)
}

internal var XCTCurrentTestCase: XCTestCase?
internal var XCTCurrentFailures = [XCTFailure]()
internal var XCTAllRuns = [XCTRun]()

