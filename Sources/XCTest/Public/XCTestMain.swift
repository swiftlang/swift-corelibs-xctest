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

// Note that we are re-exporting Foundation so tests importing XCTest don't need
// to import it themselves. This is consistent with the behavior of Apple XCTest
#if os(macOS)
    @_exported import SwiftFoundation
#else
    @_exported import Foundation
#endif

#if os(macOS)
    import Darwin
#elseif os(Linux) || os(FreeBSD)
    import Glibc
#endif

/// Starts a test run for the specified test cases.
///
/// This function will not return. If the test cases pass, then it will call `exit(0)`. If there is a failure, then it will call `exit(1)`.
/// Example usage:
///
///     class TestFoo: XCTestCase {
///         static var allTests = {
///             return [
///                 ("test_foo", test_foo),
///                 ("test_bar", test_bar),
///             ]
///         }()
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
/// Command line arguments can be used to select a particular test case or class to execute. For example:
///
///     ./FooTests FooTestCase/testFoo  # Run a single test case
///     ./FooTests FooTestCase          # Run all the tests in FooTestCase
///
/// - Parameter testCases: An array of test cases run, each produced by a call to the `testCase` function
/// - seealso: `testCase`
public func XCTMain(_ testCases: [XCTestCaseEntry]) -> Never {
    let testBundle = Bundle.main

    let executionMode = ArgumentParser().executionMode

    // Apple XCTest behaves differently if tests have been filtered:
    // - The root `XCTestSuite` is named "Selected tests" instead of
    //   "All tests".
    // - An `XCTestSuite` representing the .xctest test bundle is not included.
    let rootTestSuite: XCTestSuite
    let currentTestSuite: XCTestSuite
    if executionMode.selectedTestName == nil {
        rootTestSuite = XCTestSuite(name: "All tests")
        currentTestSuite = XCTestSuite(name: "\(testBundle.bundleURL.lastPathComponent).xctest")
        rootTestSuite.addTest(currentTestSuite)
    } else {
        rootTestSuite = XCTestSuite(name: "Selected tests")
        currentTestSuite = rootTestSuite
    }

    let filter = TestFiltering(selectedTestName: executionMode.selectedTestName)
    TestFiltering.filterTests(testCases, filter: filter.selectedTestFilter)
        .map(XCTestCaseSuite.init)
        .forEach(currentTestSuite.addTest)

    switch executionMode {
    case .list(type: .humanReadable):
        TestListing(testSuite: rootTestSuite).printTestList()
        exit(0)
    case .list(type: .json):
        TestListing(testSuite: rootTestSuite).printTestJSON()
        exit(0)
    case .run(selectedTestName: _):
        // Add a test observer that prints test progress to stdout.
        let observationCenter = XCTestObservationCenter.shared
        observationCenter.addTestObserver(PrintObserver())

        observationCenter.testBundleWillStart(testBundle)
        rootTestSuite.run()
        observationCenter.testBundleDidFinish(testBundle)

        exit(rootTestSuite.testRun!.totalFailureCount == 0 ? 0 : 1)
    }
}
