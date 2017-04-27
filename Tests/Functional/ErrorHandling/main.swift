// RUN: %{swiftc} %s -o %T/ErrorHandling
// RUN: %T/ErrorHandling > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'ErrorHandling' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class ErrorHandling: XCTestCase {
    static var allTests = {
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

            // Tests for XCTAssertNoThrow
            ("test_shouldNotThrowErrorDefiningSuccess", test_shouldNotThrowErrorDefiningSuccess),
            ("test_shouldThrowErrorDefiningFailure", test_shouldThrowErrorDefiningFailure),
        ]
    }()
    
    func functionThatDoesNotThrowError() throws {
    }
    
    enum SomeError: Swift.Error {
        case anError(String)
    }
    
    func functionThatDoesThrowError() throws {
        throw SomeError.anError("an error message")
    }

// CHECK: Test Case 'ErrorHandling.test_shouldButDoesNotThrowErrorInAssertion' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*/ErrorHandling/main.swift:[[@LINE+3]]: error: ErrorHandling.test_shouldButDoesNotThrowErrorInAssertion : XCTAssertThrowsError failed: did not throw error -
// CHECK: Test Case 'ErrorHandling.test_shouldButDoesNotThrowErrorInAssertion' failed \(\d+\.\d+ seconds\)
    func test_shouldButDoesNotThrowErrorInAssertion() {
        XCTAssertThrowsError(try functionThatDoesNotThrowError())
    }
    
// CHECK: Test Case 'ErrorHandling.test_shouldThrowErrorInAssertion' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ErrorHandling.test_shouldThrowErrorInAssertion' passed \(\d+\.\d+ seconds\)
    func test_shouldThrowErrorInAssertion() {
        XCTAssertThrowsError(try functionThatDoesThrowError()) { error in
            guard let thrownError = error as? SomeError else {
                XCTFail("Threw the wrong type of error")
                return
            }
            
            switch thrownError {
            case .anError(let message):
                XCTAssertEqual(message, "an error message")
            }
        }
    }
    
// CHECK: Test Case 'ErrorHandling.test_throwsErrorInAssertionButFailsWhenCheckingError' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*/ErrorHandling/main.swift:[[@LINE+11]]: error: ErrorHandling.test_throwsErrorInAssertionButFailsWhenCheckingError : XCTAssertEqual failed: \("an error message"\) is not equal to \(""\) -
// CHECK: Test Case 'ErrorHandling.test_throwsErrorInAssertionButFailsWhenCheckingError' failed \(\d+\.\d+ seconds\)
    func test_throwsErrorInAssertionButFailsWhenCheckingError() {
        XCTAssertThrowsError(try functionThatDoesThrowError()) { error in
            guard let thrownError = error as? SomeError else {
                XCTFail("Threw the wrong type of error")
                return
            }
            
            switch thrownError {
            case .anError(let message):
                XCTAssertEqual(message, "")
            }
        }
    }

// CHECK: Test Case 'ErrorHandling.test_canAndDoesThrowErrorFromTestMethod' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \<EXPR\>:0: error: ErrorHandling.test_canAndDoesThrowErrorFromTestMethod : threw error "anError\("an error message"\)"
// CHECK: Test Case 'ErrorHandling.test_canAndDoesThrowErrorFromTestMethod' failed \(\d+\.\d+ seconds\)
    func test_canAndDoesThrowErrorFromTestMethod() throws {
        try functionThatDoesThrowError()
    }
    
// CHECK: Test Case 'ErrorHandling.test_canButDoesNotThrowErrorFromTestMethod' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ErrorHandling.test_canButDoesNotThrowErrorFromTestMethod' passed \(\d+\.\d+ seconds\)
    func test_canButDoesNotThrowErrorFromTestMethod() throws {
        try functionThatDoesNotThrowError()
    }
    
    func functionThatShouldReturnButThrows() throws -> Int {
        throw SomeError.anError("did not actually return")
    }

// CHECK: Test Case 'ErrorHandling.test_assertionExpressionCanThrow' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*/ErrorHandling/main.swift:[[@LINE+3]]: error: ErrorHandling.test_assertionExpressionCanThrow : XCTAssertEqual threw error "anError\("did not actually return"\)" -
// CHECK: Test Case 'ErrorHandling.test_assertionExpressionCanThrow' failed \(\d+\.\d+ seconds\)
    func test_assertionExpressionCanThrow() {
        XCTAssertEqual(try functionThatShouldReturnButThrows(), 1)
    }


// CHECK: Test Case 'ErrorHandling.test_shouldNotThrowErrorDefiningSuccess' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ErrorHandling.test_shouldNotThrowErrorDefiningSuccess' passed \(\d+\.\d+ seconds\)
    func test_shouldNotThrowErrorDefiningSuccess() {
        XCTAssertNoThrow(try functionThatDoesNotThrowError())
    }

// CHECK: Test Case 'ErrorHandling.test_shouldThrowErrorDefiningFailure' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*/ErrorHandling/main.swift:[[@LINE+3]]: error: ErrorHandling.test_shouldThrowErrorDefiningFailure : XCTAssertNoThrow failed: threw error "anError\("an error message"\)" -
// CHECK: Test Case 'ErrorHandling.test_shouldThrowErrorDefiningFailure' failed \(\d+\.\d+ seconds\)
    func test_shouldThrowErrorDefiningFailure() {
        XCTAssertNoThrow(try functionThatDoesThrowError())
    }
}

// CHECK: Test Suite 'ErrorHandling' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed \d+ tests, with \d+ failures \(2 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([testCase(ErrorHandling.allTests)])

// CHECK: Test Suite '.*\.xctest' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed \d+ tests, with \d+ failures \(2 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed \d+ tests, with \d+ failures \(2 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
