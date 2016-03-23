// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTAssert.swift
//

private enum _XCTAssertion {
    case Equal
    case EqualWithAccuracy
    case GreaterThan
    case GreaterThanOrEqual
    case LessThan
    case LessThanOrEqual
    case NotEqual
    case NotEqualWithAccuracy
    case Nil
    case NotNil
    case True
    case False
    case Fail
    case ThrowsError

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
        case .ThrowsError: return "XCTAssertThrowsError"
        case .Fail: return nil
        }
    }
}

private enum _XCTAssertionResult {
    case Success
    case ExpectedFailure(String?)
    case UnexpectedFailure(ErrorProtocol)

    var expected: Bool {
        switch self {
        case .UnexpectedFailure(_): return false
        default: return true
        }
    }

    func failureDescription(assertion: _XCTAssertion) -> String {
        let explanation: String
        switch self {
        case .Success: explanation = "passed"
        case .ExpectedFailure(let details?): explanation = "failed: \(details)"
        case .ExpectedFailure(_): explanation = "failed"
        case .UnexpectedFailure(let error): explanation = "threw error \"\(error)\""
        }

        if let name = assertion.name {
            return "\(name) \(explanation)"
        } else {
            return explanation
        }
    }
}

private func _XCTEvaluateAssertion(assertion: _XCTAssertion, @autoclosure message: () -> String = "", file: StaticString = #file, line: UInt = #line, @noescape expression: () throws -> _XCTAssertionResult) {
    let result: _XCTAssertionResult
    do {
        result = try expression()
    } catch {
        result = .UnexpectedFailure(error)
    }

    switch result {
    case .Success:
        return
    default:
        if let handler = XCTFailureHandler {
            handler(XCTFailure(message: message(), failureDescription: result.failureDescription(assertion), expected: result.expected, file: file, line: line))
        }
    }
}

/// This function emits a test failure if the general `Boolean` expression passed
/// to it evaluates to `false`.
///
/// - Requires: This and all other XCTAssert* functions must be called from
///   within a test method, as passed to `XCTMain`.
///   Assertion failures that occur outside of a test method will *not* be
///   reported as failures.
///
/// - Parameter expression: A boolean test. If it evaluates to `false`, the
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
///  func AssertEmpty<T>(elements: [T], file: StaticString = #file, line: UInt = #line) {
///      XCTAssertEqual(elements.count, 0, "Array is not empty", file: file, line: line)
///  }
///  ```
///
///  Now calling failures in `AssertEmpty` will be reported in the file and on
///  the line that the assert function is *called*, not where it is defined.
public func XCTAssert(@autoclosure expression: () throws -> Boolean, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    XCTAssertTrue(expression, message, file: file, line: line)
}

public func XCTAssertEqual<T: Equatable>(@autoclosure expression1: () throws -> T?, @autoclosure _ expression2: () throws -> T?, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.Equal, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 == value2 {
            return .Success
        } else {
            return .ExpectedFailure("(\"\(value1)\") is not equal to (\"\(value2)\")")
        }
    }
}

public func XCTAssertEqual<T: Equatable>(@autoclosure expression1: () throws -> ArraySlice<T>, @autoclosure _ expression2: () throws -> ArraySlice<T>, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.Equal, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 == value2 {
            return .Success
        } else {
            return .ExpectedFailure("(\"\(value1)\") is not equal to (\"\(value2)\")")
        }
    }
}

public func XCTAssertEqual<T: Equatable>(@autoclosure expression1: () throws -> ContiguousArray<T>, @autoclosure _ expression2: () throws -> ContiguousArray<T>, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.Equal, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 == value2 {
            return .Success
        } else {
            return .ExpectedFailure("(\"\(value1)\") is not equal to (\"\(value2)\")")
        }
    }
}

public func XCTAssertEqual<T: Equatable>(@autoclosure expression1: () throws -> [T], @autoclosure _ expression2: () throws -> [T], @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.Equal, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 == value2 {
            return .Success
        } else {
            return .ExpectedFailure("(\"\(value1)\") is not equal to (\"\(value2)\")")
        }
    }
}

public func XCTAssertEqual<T, U: Equatable>(@autoclosure expression1: () throws -> [T: U], @autoclosure _ expression2: () throws -> [T: U], @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.Equal, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 == value2 {
            return .Success
        } else {
            return .ExpectedFailure("(\"\(value1)\") is not equal to (\"\(value2)\")")
        }
    }
}

public func XCTAssertEqualWithAccuracy<T: FloatingPoint>(@autoclosure expression1: () throws -> T, @autoclosure _ expression2: () throws -> T, accuracy: T, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.EqualWithAccuracy, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if abs(value1.distance(to: value2)) <= abs(accuracy.distance(to: T(0))) {
            return .Success
        } else {
            return .ExpectedFailure("(\"\(value1)\") is not equal to (\"\(value2)\") +/- (\"\(accuracy)\")")
        }
    }
}

public func XCTAssertFalse(@autoclosure expression: () throws -> Boolean, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.False, message: message, file: file, line: line) {
        let value = try expression()
        if !value.boolValue {
            return .Success
        } else {
            return .ExpectedFailure(nil)
        }
    }
}

public func XCTAssertGreaterThan<T: Comparable>(@autoclosure expression1: () throws -> T, @autoclosure _ expression2: () throws -> T, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.GreaterThan, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 > value2 {
            return .Success
        } else {
            return .ExpectedFailure("(\"\(value1)\") is not greater than (\"\(value2)\")")
        }
    }
}

public func XCTAssertGreaterThanOrEqual<T: Comparable>(@autoclosure expression1: () throws -> T, @autoclosure _ expression2: () throws -> T, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.GreaterThanOrEqual, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 >= value2 {
            return .Success
        } else {
            return .ExpectedFailure("(\"\(value1)\") is less than (\"\(value2)\")")
        }
    }
}

public func XCTAssertLessThan<T: Comparable>(@autoclosure expression1: () throws -> T, @autoclosure _ expression2: () throws -> T, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.LessThan, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 < value2 {
            return .Success
        } else {
            return .ExpectedFailure("(\"\(value1)\") is not less than (\"\(value2)\")")
        }
    }
}

public func XCTAssertLessThanOrEqual<T: Comparable>(@autoclosure expression1: () throws -> T, @autoclosure _ expression2: () throws -> T, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.LessThanOrEqual, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 <= value2 {
            return .Success
        } else {
            return .ExpectedFailure("(\"\(value1)\") is greater than (\"\(value2)\")")
        }
    }
}

public func XCTAssertNil(@autoclosure expression: () throws -> Any?, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.Nil, message: message, file: file, line: line) {
        let value = try expression()
        if value == nil {
            return .Success
        } else {
            return .ExpectedFailure("\"\(value!)\"")
        }
    }
}

public func XCTAssertNotEqual<T: Equatable>(@autoclosure expression1: () throws -> T?, @autoclosure _ expression2: () throws -> T?, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.NotEqual, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 != value2 {
            return .Success
        } else {
            return .ExpectedFailure("(\"\(value1)\") is equal to (\"\(value2)\")")
        }
    }
}

public func XCTAssertNotEqual<T: Equatable>(@autoclosure expression1: () throws -> ContiguousArray<T>, @autoclosure _ expression2: () throws -> ContiguousArray<T>, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.NotEqual, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 != value2 {
            return .Success
        } else {
            return .ExpectedFailure("(\"\(value1)\") is equal to (\"\(value2)\")")
        }
    }
}

public func XCTAssertNotEqual<T: Equatable>(@autoclosure expression1: () throws -> ArraySlice<T>, @autoclosure _ expression2: () throws -> ArraySlice<T>, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.NotEqual, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 != value2 {
            return .Success
        } else {
            return .ExpectedFailure("(\"\(value1)\") is equal to (\"\(value2)\")")
        }
    }
}

public func XCTAssertNotEqual<T: Equatable>(@autoclosure expression1: () throws -> [T], @autoclosure _ expression2: () throws -> [T], @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.NotEqual, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 != value2 {
            return .Success
        } else {
            return .ExpectedFailure("(\"\(value1)\") is equal to (\"\(value2)\")")
        }
    }
}

public func XCTAssertNotEqual<T, U: Equatable>(@autoclosure expression1: () throws -> [T: U], @autoclosure _ expression2: () throws -> [T: U], @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.NotEqual, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 != value2 {
            return .Success
        } else {
            return .ExpectedFailure("(\"\(value1)\") is equal to (\"\(value2)\")")
        }
    }
}

public func XCTAssertNotEqualWithAccuracy<T: FloatingPoint>(@autoclosure expression1: () throws -> T, @autoclosure _ expression2: () throws -> T, _ accuracy: T, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.NotEqualWithAccuracy, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if abs(value1.distance(to: value2)) > abs(accuracy.distance(to: T(0))) {
            return .Success
        } else {
            return .ExpectedFailure("(\"\(value1)\") is equal to (\"\(value2)\") +/- (\"\(accuracy)\")")
        }
    }
}

public func XCTAssertNotNil(@autoclosure expression: () throws -> Any?, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.NotNil, message: message, file: file, line: line) {
        let value = try expression()
        if value != nil {
            return .Success
        } else {
            return .ExpectedFailure(nil)
        }
    }
}

public func XCTAssertTrue(@autoclosure expression: () throws -> Boolean, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.True, message: message, file: file, line: line) {
        let value = try expression()
        if value.boolValue {
            return .Success
        } else {
            return .ExpectedFailure(nil)
        }
    }
}

public func XCTFail(message: String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.Fail, message: message, file: file, line: line) {
        return .ExpectedFailure(nil)
    }
}

public func XCTAssertThrowsError<T>(@autoclosure expression: () throws -> T, _ message: String = "", file: StaticString = #file, line: UInt = #line, _ errorHandler: (error: ErrorProtocol) -> Void = { _ in }) {
    _XCTEvaluateAssertion(.ThrowsError, message: message, file: file, line: line) {
        var caughtErrorOptional: ErrorProtocol?
        do {
            _ = try expression()
        } catch {
            caughtErrorOptional = error
        }

        if let caughtError = caughtErrorOptional {
            errorHandler(error: caughtError)
            return .Success
        } else {
            return .ExpectedFailure("did not throw error")
        }
    }
}
