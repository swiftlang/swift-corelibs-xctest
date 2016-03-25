// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTestMain.swift
//  This is the main file for the framework. It provides the entry point function
//  for running tests and some infrastructure for running them.
//

#if os(Linux) || os(FreeBSD)
    import Glibc
    import Foundation
#else
    import Darwin
    import SwiftFoundation
#endif

internal func XCTPrint(message: String) {
    print(message)
    fflush(stdout)
}

struct XCTFailure {
    var message: String
    var failureDescription: String
    var expected: Bool
    var file: StaticString
    var line: UInt

    var failureMessage: String { return "\(failureDescription) - \(message)" }

    func emit(method: String) {
        XCTPrint("\(file):\(line): \(expected ? "" : "unexpected ")error: \(method) : \(failureMessage)")
    }
}

internal struct XCTRun {
    var duration: NSTimeInterval
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
/// Example usage:
///
///     class TestFoo: XCTestCase {
///         static var allTests : [(String, TestFoo -> () throws -> Void)] {
///             return [
///                 ("test_foo", test_foo),
///                 ("test_bar", test_bar),
///             ]
///         }
///
///         func test_foo() {
///             // Test things...
///         }
///
///         // etc...
///     }
///
///     XCTMain([ testCase(TestFoo.allTests) ])
///
/// Command line arguments can be used to select a particular test or test case to execute. For example:
///
///     ./FooTests FooTestCase/testFoo  # Run a single test method
///     ./FooTests FooTestCase          # Run all the tests in FooTestCase
///
/// - Parameter testCases: An array of test cases run, each produced by a call to the `testCase` function
/// - seealso: `testCase`
@noreturn public func XCTMain(testCases: [XCTestCaseEntry]) {
    let observationCenter = XCTestObservationCenter.shared()
    let testBundle = NSBundle.mainBundle()
    observationCenter.testBundleWillStart(testBundle)

    // Apple XCTest behaves differently if tests have been filtered:
    // - The root `XCTestSuite` is named "Selected tests" instead of
    //   "All tests".
    // - An `XCTestSuite` representing the .xctest test bundle is not included.
    let selectedTestName = ArgumentParser().selectedTestName
    var rootTestSuites = [XCTestSuite]()
    if selectedTestName == nil {
        rootTestSuites.append(XCTestSuite(name: "All tests"))
        rootTestSuites.append(XCTestSuite(name: "\(testBundle.bundlePath.lastPathComponent).xctest"))
    } else {
        rootTestSuites.append(XCTestSuite(name: "Selected tests"))
    }

    let filter = TestFiltering(selectedTestName: selectedTestName)
    let filteredTestCases = TestFiltering.filterTests(testCases, filter: filter.selectedTestFilter)

    // When `XCTestSuite` objects are announced, they need to already include
    // the correct tests.
    for (testCase, _) in filteredTestCases {
        let testCaseSuite = XCTestSuite(name: "\(testCase.init().dynamicType)")
        rootTestSuites.last!.addTest(testCaseSuite)
    }

    for suite in rootTestSuites {
        observationCenter.testSuiteWillStart(suite)
    }

    let overallDuration = measureTimeExecutingBlock {
        // FIXME: This was the simplest implementation that didn't involve
        //        changing how swift-corelibs-xctest builds up and executes a
        //        collection of test cases. However, instead of using an index
        //        to enumerate both the `XCTestSuite` and the test cases at
        //        once, we should enumerate the test cases in the `XCTestSuite`.
        //        `XCTestSuite` should be responsible for representing the
        //        collection of tests we execute here.
        for (index, test) in filteredTestCases.enumerated() {
            let (testCase, tests) = test
            let testSuite = rootTestSuites.last!.tests[index] as! XCTestSuite
            observationCenter.testSuiteWillStart(testSuite)
            testCase.invokeTests(tests)
            observationCenter.testSuiteDidFinish(testSuite)
        }
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

    for suite in rootTestSuites.reversed() {
        observationCenter.testSuiteDidFinish(suite)
    }

    XCTPrint("Total executed \(XCTAllRuns.count) test\(testCountSuffix), with \(totalFailures) failure\(failureSuffix) (\(totalUnexpectedFailures) unexpected) in \(printableStringForTimeInterval(totalDuration)) (\(printableStringForTimeInterval(overallDuration))) seconds")
    observationCenter.testBundleDidFinish(testBundle)
    exit(totalFailures > 0 ? 1 : 0)
}

internal var XCTFailureHandler: (XCTFailure -> Void)?
internal var XCTAllRuns = [XCTRun]()
