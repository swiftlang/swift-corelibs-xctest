// RUN: %{swiftc} %s -o %{built_tests_dir}/ErrorHandling
// RUN: %{built_tests_dir}/ErrorHandling > %t || true
// RUN: %{xctest_checker} %t %s
// CHECK: Test Case 'ErrorHandling.test_shouldButDoesNotThrowErrorInAssertion' started.
// CHECK: .*/Tests/Functional/ErrorHandling/main.swift:\d+: error: ErrorHandling.test_shouldButDoesNotThrowErrorInAssertion : XCTAssertThrowsError failed: did not throw error - 
// CHECK: Test Case 'ErrorHandling.test_shouldButDoesNotThrowErrorInAssertion' failed \(\d+\.\d+ seconds\).
// CHECK: Test Case 'ErrorHandling.test_shouldThrowErrorInAssertion' started.
// CHECK: Test Case 'ErrorHandling.test_shouldThrowErrorInAssertion' passed \(\d+\.\d+ seconds\).
// CHECK: Test Case 'ErrorHandling.test_throwsErrorInAssertionButFailsWhenCheckingError' started.
// CHECK: .*/Tests/Functional/ErrorHandling/main.swift:\d+: error: ErrorHandling.test_throwsErrorInAssertionButFailsWhenCheckingError : XCTAssertEqual failed: \("Optional\("an error message"\)"\) is not equal to \("Optional\(""\)"\) - 
// CHECK: Test Case 'ErrorHandling.test_throwsErrorInAssertionButFailsWhenCheckingError' failed \(\d+\.\d+ seconds\).
// CHECK: Test Case 'ErrorHandling.test_canAndDoesThrowErrorFromTestMethod' started.
// CHECK: \<EXPR\>:0: unexpected error: ErrorHandling.test_canAndDoesThrowErrorFromTestMethod : threw error "AnError\("an error message"\)" - 
// CHECK: Test Case 'ErrorHandling.test_canAndDoesThrowErrorFromTestMethod' failed \(\d+\.\d+ seconds\).
// CHECK: Test Case 'ErrorHandling.test_canButDoesNotThrowErrorFromTestMethod' started.
// CHECK: Test Case 'ErrorHandling.test_canButDoesNotThrowErrorFromTestMethod' passed \(\d+\.\d+ seconds\).
// CHECK: Executed 5 tests, with 3 failures \(1 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Total executed 5 tests, with 3 failures \(1 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

#if os(Linux) || os(FreeBSD)
    import XCTest
#else
    import SwiftXCTest
#endif

class ErrorHandling: XCTestCase {
    var allTests: [(String, () throws -> ())] {
        return [
            // Tests for XCTAssertThrowsError
            ("test_shouldButDoesNotThrowErrorInAssertion", test_shouldButDoesNotThrowErrorInAssertion),
            ("test_shouldThrowErrorInAssertion", test_shouldThrowErrorInAssertion),
            ("test_throwsErrorInAssertionButFailsWhenCheckingError", test_throwsErrorInAssertionButFailsWhenCheckingError),
            
            // Tests for "testFoo() throws"
            ("test_canAndDoesThrowErrorFromTestMethod", test_canAndDoesThrowErrorFromTestMethod),
            ("test_canButDoesNotThrowErrorFromTestMethod", test_canButDoesNotThrowErrorFromTestMethod),
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
    
    func test_shouldButDoesNotThrowErrorInAssertion() {
        XCTAssertThrowsError(try functionThatDoesNotThrowError())
    }
    
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
    
    func test_canAndDoesThrowErrorFromTestMethod() throws {
        try functionThatDoesThrowError()
    }
    
    func test_canButDoesNotThrowErrorFromTestMethod() throws {
        try functionThatDoesNotThrowError()
    }
}

XCTMain([ErrorHandling()])
