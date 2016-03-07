// RUN: %{swiftc} %s -o %{built_tests_dir}/ErrorHandling
// RUN: %{built_tests_dir}/ErrorHandling > %t || true
// RUN: %{xctest_checker} %t %s

#if os(Linux) || os(FreeBSD)
    import XCTest
#else
    import SwiftXCTest
#endif

class ErrorHandling: XCTestCase {
    static var allTests: [(String, ErrorHandling -> () throws -> Void)] {
        return [
            // Tests for XCTAssertThrowsError
            ("test_shouldButDoesNotThrowErrorInAssertion", test_shouldButDoesNotThrowErrorInAssertion),
            ("test_shouldThrowErrorInAssertion", test_shouldThrowErrorInAssertion),
            ("test_throwsErrorInAssertionButFailsWhenCheckingError", test_throwsErrorInAssertionButFailsWhenCheckingError),
            
            // Tests for "testFoo() throws"
            ("test_canAndDoesThrowErrorFromTestMethod", test_canAndDoesThrowErrorFromTestMethod),
            ("test_canButDoesNotThrowErrorFromTestMethod", test_canButDoesNotThrowErrorFromTestMethod),
            
            // Tests for throwing assertion expressions
            ("test_assertionExpressionCanThrow", test_assertionExpressionCanThrow),
        ]
    }
    
    func functionThatDoesNotThrowError() throws {
    }
    
    enum SomeError: ErrorType {
        case AnError(String)
    }
    
    func functionThatDoesThrowError() throws {
        throw SomeError.AnError("an error message")
    }

// CHECK: Test Case 'ErrorHandling.test_shouldButDoesNotThrowErrorInAssertion' started.
// CHECK: .*/ErrorHandling/main.swift:\d+: error: ErrorHandling.test_shouldButDoesNotThrowErrorInAssertion : XCTAssertThrowsError failed: did not throw error - 
// CHECK: Test Case 'ErrorHandling.test_shouldButDoesNotThrowErrorInAssertion' failed \(\d+\.\d+ seconds\).
    func test_shouldButDoesNotThrowErrorInAssertion() {
        XCTAssertThrowsError(try functionThatDoesNotThrowError())
    }
    
// CHECK: Test Case 'ErrorHandling.test_shouldThrowErrorInAssertion' started.
// CHECK: Test Case 'ErrorHandling.test_shouldThrowErrorInAssertion' passed \(\d+\.\d+ seconds\).
    func test_shouldThrowErrorInAssertion() {
        XCTAssertThrowsError(try functionThatDoesThrowError()) { error in
            guard let thrownError = error as? SomeError else {
                XCTFail("Threw the wrong type of error")
                return
            }
            
            switch thrownError {
            case .AnError(let message):
                XCTAssertEqual(message, "an error message")
            }
        }
    }
    
// CHECK: Test Case 'ErrorHandling.test_throwsErrorInAssertionButFailsWhenCheckingError' started.
// CHECK: .*/ErrorHandling/main.swift:\d+: error: ErrorHandling.test_throwsErrorInAssertionButFailsWhenCheckingError : XCTAssertEqual failed: \("Optional\("an error message"\)"\) is not equal to \("Optional\(""\)"\) - 
// CHECK: Test Case 'ErrorHandling.test_throwsErrorInAssertionButFailsWhenCheckingError' failed \(\d+\.\d+ seconds\).
    func test_throwsErrorInAssertionButFailsWhenCheckingError() {
        XCTAssertThrowsError(try functionThatDoesThrowError()) { error in
            guard let thrownError = error as? SomeError else {
                XCTFail("Threw the wrong type of error")
                return
            }
            
            switch thrownError {
            case .AnError(let message):
                XCTAssertEqual(message, "")
            }
        }
    }
    
// CHECK: Test Case 'ErrorHandling.test_canAndDoesThrowErrorFromTestMethod' started.
// CHECK: \<EXPR\>:0: unexpected error: ErrorHandling.test_canAndDoesThrowErrorFromTestMethod : threw error "AnError\("an error message"\)" - 
// CHECK: Test Case 'ErrorHandling.test_canAndDoesThrowErrorFromTestMethod' failed \(\d+\.\d+ seconds\).
    func test_canAndDoesThrowErrorFromTestMethod() throws {
        try functionThatDoesThrowError()
    }
    
// CHECK: Test Case 'ErrorHandling.test_canButDoesNotThrowErrorFromTestMethod' started.
// CHECK: Test Case 'ErrorHandling.test_canButDoesNotThrowErrorFromTestMethod' passed \(\d+\.\d+ seconds\).
    func test_canButDoesNotThrowErrorFromTestMethod() throws {
        try functionThatDoesNotThrowError()
    }
    
    func functionThatShouldReturnButThrows() throws -> Int {
        throw SomeError.AnError("did not actually return")
    }
    
// CHECK: Test Case 'ErrorHandling.test_assertionExpressionCanThrow' started.
// CHECK: .*/ErrorHandling/main.swift:\d+: unexpected error: ErrorHandling.test_assertionExpressionCanThrow : XCTAssertEqual threw error "AnError\("did not actually return"\)" - 
// CHECK: Test Case 'ErrorHandling.test_assertionExpressionCanThrow' failed \(\d+\.\d+ seconds\).
    func test_assertionExpressionCanThrow() {
        XCTAssertEqual(try functionThatShouldReturnButThrows(), 1)
    }
}

XCTMain([testCase(ErrorHandling.allTests)])

// CHECK: Executed 6 tests, with 4 failures \(2 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Total executed 6 tests, with 4 failures \(2 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
