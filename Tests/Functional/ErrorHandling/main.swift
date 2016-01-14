// RUN: %{swiftc} %s -o %{built_tests_dir}/ErrorHandling
// RUN: %{built_tests_dir}/ErrorHandling > %t || true
// RUN: %{xctest_checker} %t %s
// CHECK: Test Case 'ErrorHandling.test_shouldButDoesNotThrowError' started.
// CHECK: .*/Tests/Functional/ErrorHandling/main.swift:\d+: error: ErrorHandling.test_shouldButDoesNotThrowError : XCTAssertThrowsError failed: did not throw error - 
// CHECK: Test Case 'ErrorHandling.test_shouldButDoesNotThrowError' failed \(\d+\.\d+ seconds\).
// CHECK: Test Case 'ErrorHandling.test_shouldThrowError' started.
// CHECK: Test Case 'ErrorHandling.test_shouldThrowError' passed \(\d+\.\d+ seconds\).
// CHECK: Test Case 'ErrorHandling.test_throwsButFailsWhenCheckingError' started.
// CHECK: .*/Tests/Functional/ErrorHandling/main.swift:\d+: error: ErrorHandling.test_throwsButFailsWhenCheckingError : XCTAssertEqual failed: \("Optional\("an error message"\)"\) is not equal to \("Optional\(""\)"\) - 
// CHECK: Test Case 'ErrorHandling.test_throwsButFailsWhenCheckingError' failed \(\d+\.\d+ seconds\).
// CHECK: Executed 3 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Total executed 3 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

#if os(Linux) || os(FreeBSD)
    import XCTest
#else
    import SwiftXCTest
#endif

class ErrorHandling: XCTestCase {
    var allTests: [(String, () -> ())] {
        return [
            ("test_shouldButDoesNotThrowError", test_shouldButDoesNotThrowError),
            ("test_shouldThrowError", test_shouldThrowError),
            ("test_throwsButFailsWhenCheckingError", test_throwsButFailsWhenCheckingError)
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
    
    func test_shouldButDoesNotThrowError() {
        XCTAssertThrowsError(try functionThatDoesNotThrowError())
    }
    
    func test_shouldThrowError() {
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
    
    func test_throwsButFailsWhenCheckingError() {
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
}

XCTMain([ErrorHandling()])
