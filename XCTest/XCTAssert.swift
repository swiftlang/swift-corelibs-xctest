// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTAssert.swift
//  Test assertion functions
//

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
    XCTAssert(abs(expression1().distanceTo(expression2())) <= abs(accuracy.distanceTo(T(0))), message, file: file, line: line)
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
    XCTAssert(abs(expression1().distanceTo(expression2())) > abs(accuracy.distanceTo(T(0))), message, file: file, line: line)
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
