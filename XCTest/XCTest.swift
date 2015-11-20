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
//  a mini version XCTest
//

#if os(Linux)
import Glibc
#else
import Darwin
#endif

public protocol XCTestCaseProvider {
    // In the Objective-C version of XCTest, it is possible to discover all tests when the test is executed by asking the runtime for all methods and looking for the string "test". In Swift, we ask test providers to tell us the list of tests by implementing this property.
    var allTests : [(String, () -> ())] { get }
}

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

internal struct XCTRun {
    var duration: Double
    var method: String
    var passed: Bool
    var failures: [XCTFailure]
}

/// Starts a test run for the specified test cases.
///
/// This function will not return. If the test cases pass, then it will call `exit(0)`. If there is a failure, then it will call `exit(1)`.
/// - Parameter testCases: An array of test cases to run.
@noreturn public func XCTMain(testCases: [XCTestCase]) {
    for testCase in testCases {
        testCase.invokeTest()
    }
    let (totalDuration, totalFailures) = XCTAllRuns.reduce((0.0, 0)) { ($0.0 + $1.duration, $0.1 + $1.failures.count) }
    
    var testCountSuffix = "s"
    if XCTAllRuns.count == 1 {
        testCountSuffix = ""
    }
    var failureSuffix = "s"
    if totalFailures == 1 {
        failureSuffix = ""
    }
    let averageDuration = totalDuration / Double(XCTAllRuns.count)
    print("Total executed \(XCTAllRuns.count) test\(testCountSuffix), with \(totalFailures) failure\(failureSuffix) (0 unexpected) in \(round(averageDuration * 1000.0) / 1000.0) (\(round(totalDuration * 1000.0) / 1000.0)) seconds")
    exit(totalFailures > 0 ? 1 : 0)
}

struct XCTFailure {
    var message: String
    var file: StaticString
    var line: UInt
    
    func emit(method: String) {
        print("\(file):\(line): error: \(method) : \(message)")
    }
}

internal var XCTCurrentTestCase: XCTestCase?
internal var XCTCurrentFailures = [XCTFailure]()
internal var XCTAllRuns = [XCTRun]()

public func XCTAssert(@autoclosure expression: () -> BooleanType, _ message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    if !expression().boolValue {
        if let test = XCTCurrentTestCase {
            test.testFailure(message, file: file, line: line)
        }
    }
}

public func XCTAssertEqual<T : Equatable>(@autoclosure expression1: () -> T?, @autoclosure _ expression2: () -> T?, _ message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    XCTAssert(expression1() == expression2(), message, file: file, line: line)
}

public func XCTAssertEqual<T : Equatable>(@autoclosure expression1: () -> ArraySlice<T>, @autoclosure _ expression2: () -> ArraySlice<T>, _ message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    XCTAssert(expression1() == expression2(), message, file: file, line: line)
}

public func XCTAssertEqual<T : Equatable>(@autoclosure expression1: () -> ContiguousArray<T>, @autoclosure _ expression2: () -> ContiguousArray<T>, _ message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    XCTAssert(expression1() == expression2(), message, file: file, line: line)
}

public func XCTAssertEqual<T : Equatable>(@autoclosure expression1: () -> [T], @autoclosure _ expression2: () -> [T], _ message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    XCTAssert(expression1() == expression2(), message, file: file, line: line)
}

public func XCTAssertEqual<T, U : Equatable>(@autoclosure expression1: () -> [T : U], @autoclosure _ expression2: () -> [T : U], _ message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    XCTAssert(expression1() == expression2(), message, file: file, line: line)
}

public func XCTAssertEqualWithAccuracy<T : FloatingPointType>(@autoclosure expression1: () -> T, @autoclosure _ expression2: () -> T, accuracy: T, _ message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    XCTAssert(expression1().distanceTo(expression2()) <= accuracy.distanceTo(T(0)), message, file: file, line: line)
}

public func XCTAssertFalse(@autoclosure expression: () -> BooleanType, _ message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    XCTAssert(!expression().boolValue, message, file: file, line: line)
}

public func XCTAssertGreaterThan<T : Comparable>(@autoclosure expression1: () -> T, @autoclosure _ expression2: () -> T, _ message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    XCTAssert(expression1() > expression2(), message, file: file, line: line)
}

public func XCTAssertGreaterThanOrEqual<T : Comparable>(@autoclosure expression1: () -> T, @autoclosure _ expression2: () -> T, _ message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    XCTAssert(expression1() >= expression2(), message, file: file, line: line)
}

public func XCTAssertLessThan<T : Comparable>(@autoclosure expression1: () -> T, @autoclosure _ expression2: () -> T, _ message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    XCTAssert(expression1() < expression2(), message, file: file, line: line)
}

public func XCTAssertLessThanOrEqual<T : Comparable>(@autoclosure expression1: () -> T, @autoclosure _ expression2: () -> T, _ message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    XCTAssert(expression1() <= expression2(), message, file: file, line: line)
}

public func XCTAssertNil(@autoclosure expression: () -> Any?, _ message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    XCTAssert(expression() == nil, message, file: file, line: line)
}

public func XCTAssertNotEqual<T : Equatable>(@autoclosure expression1: () -> T?, @autoclosure _ expression2: () -> T?, _ message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    XCTAssert(expression1() != expression2(), message, file: file, line: line)
}

public func XCTAssertNotEqual<T : Equatable>(@autoclosure expression1: () -> ContiguousArray<T>, @autoclosure _ expression2: () -> ContiguousArray<T>, _ message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    XCTAssert(expression1() != expression2(), message, file: file, line: line)
}

public func XCTAssertNotEqual<T : Equatable>(@autoclosure expression1: () -> ArraySlice<T>, @autoclosure _ expression2: () -> ArraySlice<T>, _ message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    XCTAssert(expression1() != expression2(), message, file: file, line: line)
}

public func XCTAssertNotEqual<T : Equatable>(@autoclosure expression1: () -> [T], @autoclosure _ expression2: () -> [T], _ message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    XCTAssert(expression1() != expression2(), message, file: file, line: line)
}

public func XCTAssertNotEqual<T, U : Equatable>(@autoclosure expression1: () -> [T : U], @autoclosure _ expression2: () -> [T : U], _ message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    XCTAssert(expression1() != expression2(), message, file: file, line: line)
}

public func XCTAssertNotEqualWithAccuracy<T : FloatingPointType>(@autoclosure expression1: () -> T, @autoclosure _ expression2: () -> T, _ accuracy: T, _ message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    XCTAssert(expression1().distanceTo(expression2()) > accuracy.distanceTo(T(0)), message, file: file, line: line)
}

public func XCTAssertNotNil(@autoclosure expression: () -> Any?, _ message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    XCTAssert(expression() != nil, message, file: file, line: line)
}

public func XCTAssertTrue(@autoclosure expression: () -> BooleanType, _ message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    XCTAssert(expression().boolValue, message, file: file, line: line)
}

public func XCTFail(message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    XCTAssert(false, message, file: file, line: line)
}
