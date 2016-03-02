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

/// This is a compound type used by `XCTMain` to represent tests to run. It combines an
/// `XCTestCase` subclass type with the list of test methods to invoke on the test case.
/// This type is intended to be produced by the `testCase` helper function.
/// - seealso: `testCase`
/// - seealso: `XCTMain`
public typealias XCTestCaseEntry = (testCaseClass: XCTestCase.Type, allTests: [(String, XCTestCase throws -> Void)])

public class XCTestCase {

    public required init() {
    }

    public func setUp() {
    }

    public func tearDown() {
    }
}

/// Wrapper function allowing an array of static test case methods to fit
/// the signature required by `XCTMain`
/// - seealso: `XCTMain`
public func testCase<T: XCTestCase>(allTests: [(String, T -> () throws -> Void)]) -> XCTestCaseEntry {
    let tests: [(String, XCTestCase throws -> Void)] = allTests.map({ ($0.0, test($0.1)) })
    return (T.self, tests)
}

private func test<T: XCTestCase>(testFunc: T -> () throws -> Void) -> XCTestCase throws -> Void {
    return { testCaseType in
        guard let testCase: T = testCaseType as? T else {
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
            // TODO: When using the Objective-C runtime, XCTest is able to throw an exception from an assert and then catch it at the frame above the test method. This enables the framework to effectively stop all execution in the current test. There is no such facility in Swift. Until we figure out how to get a compatible behavior, we have decided to hard-code the value of 'true' for continue after failure.
        }
    }

    internal static func invokeTests(tests: [(String, XCTestCase throws -> Void)]) {
        var totalDuration = 0.0
        var totalFailures = 0
        var unexpectedFailures = 0
        let overallDuration = measureTimeExecutingBlock {
            for (name, test) in tests {
                let testCase = self.init()
                let fullName = "\(testCase.dynamicType).\(name)"

                var failures = [XCTFailure]()
                XCTFailureHandler = { failure in
                    if !testCase.continueAfterFailure {
                        failure.emit(fullName)
                        fatalError("Terminating execution due to test failure", file: failure.file, line: failure.line)
                    } else {
                        failures.append(failure)
                    }
                }

                XCTPrint("Test Case '\(fullName)' started.")

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

                totalDuration += duration

                var result = "passed"
                for failure in failures {
                    failure.emit(fullName)
                    totalFailures += 1
                    if !failure.expected {
                        unexpectedFailures += 1
                    }
                    result = failures.count > 0 ? "failed" : "passed"
                }

                XCTPrint("Test Case '\(fullName)' \(result) (\(printableStringForTimeInterval(duration)) seconds).")
                XCTAllRuns.append(XCTRun(duration: duration, method: fullName, passed: failures.count == 0, failures: failures))
                XCTFailureHandler = nil
            }
        }

        var testCountSuffix = "s"
        if tests.count == 1 {
            testCountSuffix = ""
        }
        var failureSuffix = "s"
        if totalFailures == 1 {
            failureSuffix = ""
        }

        XCTPrint("Executed \(tests.count) test\(testCountSuffix), with \(totalFailures) failure\(failureSuffix) (\(unexpectedFailures) unexpected) in \(printableStringForTimeInterval(totalDuration)) (\(printableStringForTimeInterval(overallDuration))) seconds")
    }
}
