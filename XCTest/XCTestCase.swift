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

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

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
        for (name, test) in tests {
            XCTCurrentTestCase = self
            let method = "\(self.dynamicType).\(name)"
            var duration: Double = 0.0
            print("Test Case '\(method)' started.")
            var tv = timeval()
            let start = withUnsafeMutablePointer(&tv, { (t: UnsafeMutablePointer<timeval>) -> Double in
                gettimeofday(t, nil)
                return Double(t.memory.tv_sec) + Double(t.memory.tv_usec) / 1000000.0
            })
            
            test()
            let end = withUnsafeMutablePointer(&tv, { (t: UnsafeMutablePointer<timeval>) -> Double in
                gettimeofday(t, nil)
                return Double(t.memory.tv_sec) + Double(t.memory.tv_usec) / 1000000.0
            })
            duration = end - start
            totalDuration += duration
            for failure in XCTCurrentFailures {
                failure.emit(method)
                totalFailures++
            }
            var result = "passed"
            if XCTCurrentFailures.count > 0 {
                result = "failed"
            }
            print("Test Case '\(method)' \(result) (\(round(duration * 1000.0) / 1000.0) seconds).")
            XCTAllRuns.append(XCTRun(duration: duration, method: method, passed: XCTCurrentFailures.count == 0, failures: XCTCurrentFailures))
            XCTCurrentFailures.removeAll()
            XCTCurrentTestCase = nil
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
        
        
        print("Executed \(tests.count) test\(testCountSuffix), with \(totalFailures) failure\(failureSuffix) (0 unexpected) in \(round(averageDuration * 1000.0) / 1000.0) (\(round(totalDuration * 1000.0) / 1000.0)) seconds")
    }
    
    // This function is for the use of XCTestCase only, but we must make it public or clients will get a link failure when using XCTest (23476006)
    public func testFailure(message: String, file: StaticString , line: UInt) {
        if !continueAfterFailure {
            assert(false, message, file: file, line: line)
        } else {
            XCTCurrentFailures.append(XCTFailure(message: message, file: file, line: line))
        }
    }
    
    public func setUp() {
        
    }
    
    public func tearDown() {
        
    }
}
