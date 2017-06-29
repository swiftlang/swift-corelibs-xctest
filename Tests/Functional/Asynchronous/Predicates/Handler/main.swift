// RUN: %{swiftc} %s -o %T/Asynchronous-Predicates-Handler
// RUN: %T/Asynchronous-Predicates-Handler > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'PredicateHandlerTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class PredicateHandlerTestCase: XCTestCase {
    // CHECK: Test Case 'PredicateHandlerTestCase.test_predicateIsTrue_handlerReturnsTrue_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: Test Case 'PredicateHandlerTestCase.test_predicateIsTrue_handlerReturnsTrue_passes' passed \(\d+\.\d+ seconds\)
    func test_predicateIsTrue_handlerReturnsTrue_passes() {
        let predicate = NSPredicate(value: true)
        let object = NSObject()
        self.expectation(for: predicate, evaluatedWith: object, handler: {
            return true
        })
        waitForExpectations(timeout: 0.1)
    }
    // CHECK: Test Case 'PredicateHandlerTestCase.test_predicateIsTrue_handlerReturnsFalse_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: .*/Tests/Functional/Asynchronous/Predicates/Handler/main.swift:[[@LINE+8]]: error: PredicateHandlerTestCase.test_predicateIsTrue_handlerReturnsFalse_fails : Asynchronous wait failed - Exceeded timeout of 0.1 seconds, with unfulfilled expectations: Expect `<NSPredicate: 0x[0-9a-fA-F]{1,16}>` for object <NSObject: 0x[0-9a-fA-F]{1,16}>
    // CHECK: Test Case 'PredicateHandlerTestCase.test_predicateIsTrue_handlerReturnsFalse_fails' failed \(\d+\.\d+ seconds\)
    func test_predicateIsTrue_handlerReturnsFalse_fails() {
        let predicate = NSPredicate(value: true)
        let object = NSObject()
        self.expectation(for: predicate, evaluatedWith: object, handler: {
            return false
        })
        waitForExpectations(timeout: 0.1)
    }
    
    // CHECK: Test Case 'PredicateHandlerTestCase.test_predicateIsTrueAfterTimeout_handlerIsNotCalled_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: .*/Tests/Functional/Asynchronous/Predicates/Handler/main.swift:[[@LINE+14]]: error: PredicateHandlerTestCase.test_predicateIsTrueAfterTimeout_handlerIsNotCalled_fails : Asynchronous wait failed - Exceeded timeout of 0.1 seconds, with unfulfilled expectations: Expect `<NSPredicate: 0x[0-9a-fA-F]{1,16}>` for object \d{4}-\d{2}-\d{2} \d+:\d+:\d+ \+\d+
    // CHECK: Test Case 'PredicateHandlerTestCase.test_predicateIsTrueAfterTimeout_handlerIsNotCalled_fails' failed \(\d+\.\d+ seconds\)
    func test_predicateIsTrueAfterTimeout_handlerIsNotCalled_fails() {
        let halfSecLaterDate = NSDate(timeIntervalSinceNow: 0.2)
        let predicate = NSPredicate(block: { evaluatedObject, bindings in
            if let evaluatedDate = evaluatedObject as? NSDate {
                return evaluatedDate.compare(Date()) == ComparisonResult.orderedAscending
            }
            return false
        })
        expectation(for: predicate, evaluatedWith: halfSecLaterDate, handler: {
            XCTFail("Should not call the predicate expectation handler")
            return true
        })
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    static var allTests = {
        return [
                   ("test_predicateIsTrue_handlerReturnsTrue_passes", test_predicateIsTrue_handlerReturnsTrue_passes),
                   ("test_predicateIsTrue_handlerReturnsFalse_fails", test_predicateIsTrue_handlerReturnsFalse_fails),
                   ("test_predicateIsTrueAfterTimeout_handlerIsNotCalled_fails", test_predicateIsTrueAfterTimeout_handlerIsNotCalled_fails),
        ]
    }()
}

// CHECK: Test Suite 'PredicateHandlerTestCase' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 3 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
XCTMain([testCase(PredicateHandlerTestCase.allTests)])

// CHECK: Test Suite '.*\.xctest' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 3 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 3 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
