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
    case equal
    case equalWithAccuracy
    case greaterThan
    case greaterThanOrEqual
    case lessThan
    case lessThanOrEqual
    case notEqual
    case notEqualWithAccuracy
    case `nil`
    case notNil
    case `true`
    case `false`
    case fail
    case throwsError

    var name: String? {
        switch(self) {
        case .equal: return "XCTAssertEqual"
        case .equalWithAccuracy: return "XCTAssertEqualWithAccuracy"
        case .greaterThan: return "XCTAssertGreaterThan"
        case .greaterThanOrEqual: return "XCTAssertGreaterThanOrEqual"
        case .lessThan: return "XCTAssertLessThan"
        case .lessThanOrEqual: return "XCTAssertLessThanOrEqual"
        case .notEqual: return "XCTAssertNotEqual"
        case .notEqualWithAccuracy: return "XCTAssertNotEqualWithAccuracy"
        case .`nil`: return "XCTAssertNil"
        case .notNil: return "XCTAssertNotNil"
        case .`true`: return "XCTAssertTrue"
        case .`false`: return "XCTAssertFalse"
        case .throwsError: return "XCTAssertThrowsError"
        case .fail: return nil
        }
    }
}

private enum _XCTAssertionResult {
    case success
    case expectedFailure(String?)
    case unexpectedFailure(ErrorProtocol)

    var isExpected: Bool {
        switch self {
        case .unexpectedFailure(_): return false
        default: return true
        }
    }

    func failureDescription(_ assertion: _XCTAssertion) -> String {
        let explanation: String
        switch self {
        case .success: explanation = "passed"
        case .expectedFailure(let details?): explanation = "failed: \(details)"
        case .expectedFailure(_): explanation = "failed"
        case .unexpectedFailure(let error): explanation = "threw error \"\(error)\""
        }

        if let name = assertion.name {
            return "\(name) \(explanation)"
        } else {
            return explanation
        }
    }
}

private func _XCTEvaluateAssertion(_ assertion: _XCTAssertion, @autoclosure message: () -> String = "", file: StaticString = #file, line: UInt = #line, @noescape expression: () throws -> _XCTAssertionResult) {
    let result: _XCTAssertionResult
    do {
        result = try expression()
    } catch {
        result = .unexpectedFailure(error)
    }

    switch result {
    case .success:
        return
    default:
        if let handler = XCTFailureHandler {
            handler(XCTFailure(message: message(), failureDescription: result.failureDescription(assertion), expected: result.isExpected, file: file, line: line))
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
///   func AssertEmpty<T>(_ elements: [T]) {
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
///  func AssertEmpty<T>(_ elements: [T], file: StaticString = #file, line: UInt = #line) {
///      XCTAssertEqual(elements.count, 0, "Array is not empty", file: file, line: line)
///  }
///  ```
///
///  Now calling failures in `AssertEmpty` will be reported in the file and on
///  the line that the assert function is *called*, not where it is defined.
public func XCTAssert(@autoclosure _ expression: () throws -> Boolean, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    XCTAssertTrue(expression, message, file: file, line: line)
}

public func XCTAssertEqual<T: Equatable>(@autoclosure _ expression1: () throws -> T?, @autoclosure _ expression2: () throws -> T?, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.equal, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 == value2 {
            return .success
        } else {
            return .expectedFailure("(\"\(value1)\") is not equal to (\"\(value2)\")")
        }
    }
}

public func XCTAssertEqual<T: Equatable>(@autoclosure _ expression1: () throws -> ArraySlice<T>, @autoclosure _ expression2: () throws -> ArraySlice<T>, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.equal, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 == value2 {
            return .success
        } else {
            return .expectedFailure("(\"\(value1)\") is not equal to (\"\(value2)\")")
        }
    }
}

public func XCTAssertEqual<T: Equatable>(@autoclosure _ expression1: () throws -> ContiguousArray<T>, @autoclosure _ expression2: () throws -> ContiguousArray<T>, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.equal, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 == value2 {
            return .success
        } else {
            return .expectedFailure("(\"\(value1)\") is not equal to (\"\(value2)\")")
        }
    }
}

public func XCTAssertEqual<T: Equatable>(@autoclosure _ expression1: () throws -> [T], @autoclosure _ expression2: () throws -> [T], @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.equal, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 == value2 {
            return .success
        } else {
            return .expectedFailure("(\"\(value1)\") is not equal to (\"\(value2)\")")
        }
    }
}

public func XCTAssertEqual<T, U: Equatable>(@autoclosure _ expression1: () throws -> [T: U], @autoclosure _ expression2: () throws -> [T: U], @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.equal, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 == value2 {
            return .success
        } else {
            return .expectedFailure("(\"\(value1)\") is not equal to (\"\(value2)\")")
        }
    }
}

public func XCTAssertEqualWithAccuracy<T: FloatingPoint>(@autoclosure _ expression1: () throws -> T, @autoclosure _ expression2: () throws -> T, accuracy: T, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.equalWithAccuracy, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if abs(value1.distance(to: value2)) <= abs(accuracy.distance(to: T(0))) {
            return .success
        } else {
            return .expectedFailure("(\"\(value1)\") is not equal to (\"\(value2)\") +/- (\"\(accuracy)\")")
        }
    }
}

public func XCTAssertFalse(@autoclosure _ expression: () throws -> Boolean, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.`false`, message: message, file: file, line: line) {
        let value = try expression()
        if !value.boolValue {
            return .success
        } else {
            return .expectedFailure(nil)
        }
    }
}

public func XCTAssertGreaterThan<T: Comparable>(@autoclosure _ expression1: () throws -> T, @autoclosure _ expression2: () throws -> T, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.greaterThan, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 > value2 {
            return .success
        } else {
            return .expectedFailure("(\"\(value1)\") is not greater than (\"\(value2)\")")
        }
    }
}

public func XCTAssertGreaterThanOrEqual<T: Comparable>(@autoclosure _ expression1: () throws -> T, @autoclosure _ expression2: () throws -> T, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.greaterThanOrEqual, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 >= value2 {
            return .success
        } else {
            return .expectedFailure("(\"\(value1)\") is less than (\"\(value2)\")")
        }
    }
}

public func XCTAssertLessThan<T: Comparable>(@autoclosure _ expression1: () throws -> T, @autoclosure _ expression2: () throws -> T, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.lessThan, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 < value2 {
            return .success
        } else {
            return .expectedFailure("(\"\(value1)\") is not less than (\"\(value2)\")")
        }
    }
}

public func XCTAssertLessThanOrEqual<T: Comparable>(@autoclosure _ expression1: () throws -> T, @autoclosure _ expression2: () throws -> T, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.lessThanOrEqual, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 <= value2 {
            return .success
        } else {
            return .expectedFailure("(\"\(value1)\") is greater than (\"\(value2)\")")
        }
    }
}

public func XCTAssertNil(@autoclosure _ expression: () throws -> Any?, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.`nil`, message: message, file: file, line: line) {
        let value = try expression()
        if value == nil {
            return .success
        } else {
            return .expectedFailure("\"\(value!)\"")
        }
    }
}

public func XCTAssertNotEqual<T: Equatable>(@autoclosure _ expression1: () throws -> T?, @autoclosure _ expression2: () throws -> T?, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.notEqual, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 != value2 {
            return .success
        } else {
            return .expectedFailure("(\"\(value1)\") is equal to (\"\(value2)\")")
        }
    }
}

public func XCTAssertNotEqual<T: Equatable>(@autoclosure _ expression1: () throws -> ContiguousArray<T>, @autoclosure _ expression2: () throws -> ContiguousArray<T>, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.notEqual, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 != value2 {
            return .success
        } else {
            return .expectedFailure("(\"\(value1)\") is equal to (\"\(value2)\")")
        }
    }
}

public func XCTAssertNotEqual<T: Equatable>(@autoclosure _ expression1: () throws -> ArraySlice<T>, @autoclosure _ expression2: () throws -> ArraySlice<T>, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.notEqual, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 != value2 {
            return .success
        } else {
            return .expectedFailure("(\"\(value1)\") is equal to (\"\(value2)\")")
        }
    }
}

public func XCTAssertNotEqual<T: Equatable>(@autoclosure _ expression1: () throws -> [T], @autoclosure _ expression2: () throws -> [T], @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.notEqual, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 != value2 {
            return .success
        } else {
            return .expectedFailure("(\"\(value1)\") is equal to (\"\(value2)\")")
        }
    }
}

public func XCTAssertNotEqual<T, U: Equatable>(@autoclosure _ expression1: () throws -> [T: U], @autoclosure _ expression2: () throws -> [T: U], @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.notEqual, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if value1 != value2 {
            return .success
        } else {
            return .expectedFailure("(\"\(value1)\") is equal to (\"\(value2)\")")
        }
    }
}

public func XCTAssertNotEqualWithAccuracy<T: FloatingPoint>(@autoclosure _ expression1: () throws -> T, @autoclosure _ expression2: () throws -> T, _ accuracy: T, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.notEqualWithAccuracy, message: message, file: file, line: line) {
        let (value1, value2) = (try expression1(), try expression2())
        if abs(value1.distance(to: value2)) > abs(accuracy.distance(to: T(0))) {
            return .success
        } else {
            return .expectedFailure("(\"\(value1)\") is equal to (\"\(value2)\") +/- (\"\(accuracy)\")")
        }
    }
}

public func XCTAssertNotNil(@autoclosure _ expression: () throws -> Any?, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.notNil, message: message, file: file, line: line) {
        let value = try expression()
        if value != nil {
            return .success
        } else {
            return .expectedFailure(nil)
        }
    }
}

public func XCTAssertTrue(@autoclosure _ expression: () throws -> Boolean, @autoclosure _ message: () -> String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.`true`, message: message, file: file, line: line) {
        let value = try expression()
        if value.boolValue {
            return .success
        } else {
            return .expectedFailure(nil)
        }
    }
}

public func XCTFail(_ message: String = "", file: StaticString = #file, line: UInt = #line) {
    _XCTEvaluateAssertion(.fail, message: message, file: file, line: line) {
        return .expectedFailure(nil)
    }
}

public func XCTAssertThrowsError<T>(@autoclosure _ expression: () throws -> T, _ message: String = "", file: StaticString = #file, line: UInt = #line, _ errorHandler: (error: ErrorProtocol) -> Void = { _ in }) {
    _XCTEvaluateAssertion(.throwsError, message: message, file: file, line: line) {
        var caughtErrorOptional: ErrorProtocol?
        do {
            _ = try expression()
        } catch {
            caughtErrorOptional = error
        }

        if let caughtError = caughtErrorOptional {
            errorHandler(error: caughtError)
            return .success
        } else {
            return .expectedFailure("did not throw error")
        }
    }
}
