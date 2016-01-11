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

private enum _XCTAssertion {
    case Equal(Any, Any)
    case EqualWithAccuracy(Any, Any, accuracy: Any)
    case GreaterThan(Any, Any)
    case GreaterThanOrEqual(Any, Any)
    case LessThan(Any, Any)
    case LessThanOrEqual(Any, Any)
    case NotEqual(Any, Any)
    case NotEqualWithAccuracy(Any, Any, accuracy: Any)
    case Nil(Any)
    case NotNil
    case True
    case False
    case Fail

    var name: String? {
        switch(self) {
        case .Equal: return "XCTAssertEqual"
        case .EqualWithAccuracy: return "XCTAssertEqualWithAccuracy"
        case .GreaterThan: return "XCTAssertGreaterThan"
        case .GreaterThanOrEqual: return "XCTAssertGreaterThanOrEqual"
        case .LessThan: return "XCTAssertLessThan"
        case .LessThanOrEqual: return "XCTAssertLessThanOrEqual"
        case .NotEqual: return "XCTAssertNotEqual"
        case .NotEqualWithAccuracy: return "XCTAssertNotEqualWithAccuracy"
        case .Nil: return "XCTAssertNil"
        case .NotNil: return "XCTAssertNotNil"
        case .True: return "XCTAssertTrue"
        case .False: return "XCTAssertFalse"
        case .Fail: return nil
        }
    }

    var failureDetails: String? {
        switch(self) {
        case .Equal(let value1, let value2):
            return "(\"\(value1)\") is not equal to (\"\(value2)\")"
        case .EqualWithAccuracy(let value1, let value2, let accuracy):
            return "(\"\(value1)\") is not equal to (\"\(value2)\") +/- (\"\(accuracy)\")"
        case .GreaterThan(let value1, let value2):
            return "(\"\(value1)\") is not greater than (\"\(value2)\")"
        case .GreaterThanOrEqual(let value1, let value2):
            return "(\"\(value1)\") is less than (\"\(value2)\")"
        case .LessThan(let value1, let value2):
            return "(\"\(value1)\") is not less than (\"\(value2)\")"
        case .LessThanOrEqual(let value1, let value2):
            return "(\"\(value1)\") is greater than (\"\(value2)\")"
        case .NotEqual(let value1, let value2):
            return "(\"\(value1)\") is equal to (\"\(value2)\")"
        case .NotEqualWithAccuracy(let value1, let value2, let accuracy):
            return "(\"\(value1)\") is equal to (\"\(value2)\") +/- (\"\(accuracy)\")"
        case .Nil(let value):
            return "\"\(value)\""
        case .NotNil: return nil
        case .True: return nil
        case .False: return nil
        case .Fail: return nil
        }
    }

    var failureDescription: String {
        switch (name, failureDetails) {
        case let (name?, description?):
            return "\(name) failed: \(description)"
        case let (name?, _):
            return "\(name) failed"
        default:
            return "failed"
        }
    }
}

private func _XCTAssert(@autoclosure expression: () -> BooleanType, @autoclosure assertion: () -> _XCTAssertion, @autoclosure _ message: () -> String, file: StaticString, line: UInt) {
    if !expression().boolValue {
        if let handler = XCTFailureHandler {
            handler(XCTFailure(message: message(), failureDescription: assertion().failureDescription, expected: true, file: file, line: line))
        }
    }
}

/// This function emits a test failure if the general Bool expression passed
/// to it evaluates to false.
///
/// - Requires: This and all other XCTAssert* functions must be called from
///   within a test method, as indicated by `XCTestCaseProvider.allTests`.
///   Assertion failures that occur outside of a test method will *not* be
///   reported as failures.
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
public func XCTAssert(@autoclosure expression: () -> BooleanType, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    XCTAssertTrue(expression, message, file: file, line: line)
}

public func XCTAssertEqual<T : Equatable>(@autoclosure expression1: () -> T?, @autoclosure _ expression2: () -> T?, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    let (value1, value2) = (expression1(), expression2())
    _XCTAssert(value1 == value2, assertion: .Equal(value1, value2), message, file: file, line: line)
}

public func XCTAssertEqual<T : Equatable>(@autoclosure expression1: () -> ArraySlice<T>, @autoclosure _ expression2: () -> ArraySlice<T>, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    let (value1, value2) = (expression1(), expression2())
    _XCTAssert(value1 == value2, assertion: .Equal(value1, value2), message, file: file, line: line)
}

public func XCTAssertEqual<T : Equatable>(@autoclosure expression1: () -> ContiguousArray<T>, @autoclosure _ expression2: () -> ContiguousArray<T>, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    let (value1, value2) = (expression1(), expression2())
    _XCTAssert(value1 == value2, assertion: .Equal(value1, value2), message, file: file, line: line)
}

public func XCTAssertEqual<T : Equatable>(@autoclosure expression1: () -> [T], @autoclosure _ expression2: () -> [T], @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    let (value1, value2) = (expression1(), expression2())
    _XCTAssert(value1 == value2, assertion: .Equal(value1, value2), message, file: file, line: line)
}

public func XCTAssertEqual<T, U : Equatable>(@autoclosure expression1: () -> [T : U], @autoclosure _ expression2: () -> [T : U], @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    let (value1, value2) = (expression1(), expression2())
    _XCTAssert(value1 == value2, assertion: .Equal(value1, value2), message, file: file, line: line)
}

public func XCTAssertEqualWithAccuracy<T : FloatingPointType>(@autoclosure expression1: () -> T, @autoclosure _ expression2: () -> T, accuracy: T, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    let (value1, value2) = (expression1(), expression2())
    _XCTAssert(abs(value1.distanceTo(value2)) <= abs(accuracy.distanceTo(T(0))), assertion: .EqualWithAccuracy(value1, value2, accuracy: accuracy), message, file: file, line: line)
}

public func XCTAssertFalse(@autoclosure expression: () -> BooleanType, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    _XCTAssert(!expression().boolValue, assertion: .False, message, file: file, line: line)
}

public func XCTAssertGreaterThan<T : Comparable>(@autoclosure expression1: () -> T, @autoclosure _ expression2: () -> T, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    let (value1, value2) = (expression1(), expression2())
    _XCTAssert(value1 > value2, assertion: .GreaterThan(value1, value2), message, file: file, line: line)
}

public func XCTAssertGreaterThanOrEqual<T : Comparable>(@autoclosure expression1: () -> T, @autoclosure _ expression2: () -> T, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    let (value1, value2) = (expression1(), expression2())
    _XCTAssert(value1 >= value2, assertion: .GreaterThanOrEqual(value1, value2), message, file: file, line: line)
}

public func XCTAssertLessThan<T : Comparable>(@autoclosure expression1: () -> T, @autoclosure _ expression2: () -> T, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    let (value1, value2) = (expression1(), expression2())
    _XCTAssert(value1 < value2, assertion: .LessThan(value1, value2), message, file: file, line: line)
}

public func XCTAssertLessThanOrEqual<T : Comparable>(@autoclosure expression1: () -> T, @autoclosure _ expression2: () -> T, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    let (value1, value2) = (expression1(), expression2())
    _XCTAssert(value1 <= value2, assertion: .LessThanOrEqual(value1, value2), message, file: file, line: line)
}

public func XCTAssertNil(@autoclosure expression: () -> Any?, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    let value = expression()
    _XCTAssert(value == nil, assertion: value == nil ? .Nil(()) : .Nil(value!), message, file: file, line: line)
}

public func XCTAssertNotEqual<T : Equatable>(@autoclosure expression1: () -> T?, @autoclosure _ expression2: () -> T?, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    let (value1, value2) = (expression1(), expression2())
    _XCTAssert(value1 != value2, assertion: .NotEqual(value1, value2), message, file: file, line: line)
}

public func XCTAssertNotEqual<T : Equatable>(@autoclosure expression1: () -> ContiguousArray<T>, @autoclosure _ expression2: () -> ContiguousArray<T>, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    let (value1, value2) = (expression1(), expression2())
    _XCTAssert(value1 != value2, assertion: .NotEqual(value1, value2), message, file: file, line: line)
}

public func XCTAssertNotEqual<T : Equatable>(@autoclosure expression1: () -> ArraySlice<T>, @autoclosure _ expression2: () -> ArraySlice<T>, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    let (value1, value2) = (expression1(), expression2())
    _XCTAssert(value1 != value2, assertion: .NotEqual(value1, value2), message, file: file, line: line)
}

public func XCTAssertNotEqual<T : Equatable>(@autoclosure expression1: () -> [T], @autoclosure _ expression2: () -> [T], @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    let (value1, value2) = (expression1(), expression2())
    _XCTAssert(value1 != value2, assertion: .NotEqual(value1, value2), message, file: file, line: line)
}

public func XCTAssertNotEqual<T, U : Equatable>(@autoclosure expression1: () -> [T : U], @autoclosure _ expression2: () -> [T : U], @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    let (value1, value2) = (expression1(), expression2())
    _XCTAssert(value1 != value2, assertion: .NotEqual(value1, value2), message, file: file, line: line)
}

public func XCTAssertNotEqualWithAccuracy<T : FloatingPointType>(@autoclosure expression1: () -> T, @autoclosure _ expression2: () -> T, _ accuracy: T, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    let (value1, value2) = (expression1(), expression2())
    _XCTAssert(abs(value1.distanceTo(value2)) > abs(accuracy.distanceTo(T(0))), assertion: .NotEqualWithAccuracy(value1, value2, accuracy: accuracy), message, file: file, line: line)
}

public func XCTAssertNotNil(@autoclosure expression: () -> Any?, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    _XCTAssert(expression() != nil, assertion: .NotNil, message, file: file, line: line)
}

public func XCTAssertTrue(@autoclosure expression: () -> BooleanType, @autoclosure _ message: () -> String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    _XCTAssert(expression().boolValue, assertion: .True, message, file: file, line: line)
}

public func XCTFail(message: String = "", file: StaticString = __FILE__, line: UInt = __LINE__) {
    _XCTAssert(false, assertion: .Fail, message, file: file, line: line)
}
