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
//

/// The primitive assertion function for XCTest. All other XCTAssert* functions
/// are implemented in terms of this. This function emits a test failure if the
/// general Bool expression passed to it evaluates to false.
///
/// - Parameter expression: A boolean test. If it evaluates to false, the
///   assertion fails and emits a test failure.
/// - Parameter message: An optional message to use in the failure if the
///   assertion fails. If no message is supplied a default message is used.
/// - Parameter file: The file name to use in the error message if the assertion
///   fails. Default is the file containing the call to this function. It is
///   rare to provide this parameter when calling this function.
/// - Parameter line: The line number to use in the error message if the
///   assertion fails. Default is the line number of the call to this function
///   in the calling file. It is rare to provide this parameter when calling
///   this function.
///
/// - Note: It is rare to provide the `file` and `line` parameters when calling
///   this function, although you may consider doing so when creating your own
///   assertion functions. For example, consider the following custom assertion:
///
///   ```
///   // AssertEmpty.swift
///
///   func AssertEmpty<T>(elements: [T]) {
///       XCTAssertEqual(elements.count, 0, "Array is not empty")
///   }
///   ```
///
///  Calling this assertion will cause XCTest to report the failure occured
///  in the file where `AssertEmpty()` is defined, and on the line where
///  `XCTAssertEqual` is called from within that function:
///
///  ```
///  // MyFile.swift
///
///  AssertEmpty([1, 2, 3]) // Emits "AssertEmpty.swift:3: error: ..."
///  ```
///
///  To have XCTest properly report the file and line where the assertion
///  failed, you may specify the file and line yourself:
///
///  ```
///  // AssertEmpty.swift
///
///  func AssertEmpty<T>(elements: [T], file: StaticString = __FILE__, line: UInt = __LINE__) {
///      XCTAssertEqual(elements.count, 0, "Array is not empty", file: file, line: line)
///  }
///  ```
///
///  Now calling failures in `AssertEmpty` will be reported in the file and on
///  the line that the assert function is *called*, not where it is defined.
public func XCTAssert(@autoclosure expression: () -> BooleanType, _ message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    if !expression().boolValue {
        if let test = XCTCurrentTestCase {
            test.testFailure(message, expected: true, file: file, line: line)
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
