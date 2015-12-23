// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTestCase.swift
//  Base protocol (and extension with default methods) for test cases
//

public protocol XCTestCase : XCTestCaseProvider {
    
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
    
    public func invokeTest() {
        let tests = self.allTests
        var totalDuration = 0.0
        var totalFailures = 0
        var unexpectedFailures = 0
        for (name, test) in tests {
            let method = "\(self.dynamicType).\(name)"

            var failures = [XCTFailure]()
            XCTFailureHandler = { failure in
                if !self.continueAfterFailure {
                    failure.emit(method)
                    fatalError("Terminating execution due to test failure")
                } else {
                    failures.append(failure)
                }
            }

            var duration: Double = 0.0
            print("Test Case '\(method)' started.")
            
            setUp()
            
            let start = currentTimeIntervalSinceReferenceTime()
            test()
            let end = currentTimeIntervalSinceReferenceTime()
            
            tearDown()
            
            duration = end - start
            totalDuration += duration
            for failure in failures {
                failure.emit(method)
                totalFailures += 1
                if !failure.expected {
                    unexpectedFailures += 1
                }
            }
            var result = "passed"
            if failures.count > 0 {
                result = "failed"
            }
            print("Test Case '\(method)' \(result) (\(printableStringForTimeInterval(duration)) seconds).")
            XCTAllRuns.append(XCTRun(duration: duration, method: method, passed: failures.count == 0, failures: failures))
            XCTFailureHandler = nil
        }
        var testCountSuffix = "s"
        if tests.count == 1 {
            testCountSuffix = ""
        }
        var failureSuffix = "s"
        if totalFailures == 1 {
            failureSuffix = ""
        }
        let averageDuration = totalDuration / Double(tests.count)
        
        print("Executed \(tests.count) test\(testCountSuffix), with \(totalFailures) failure\(failureSuffix) (\(unexpectedFailures) unexpected) in \(printableStringForTimeInterval(averageDuration)) (\(printableStringForTimeInterval(totalDuration))) seconds")
    }

    public func setUp() {
        
    }
    
    public func tearDown() {
        
    }
}
