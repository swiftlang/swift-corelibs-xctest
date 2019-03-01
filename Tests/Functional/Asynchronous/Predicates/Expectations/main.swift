// RUN: %{swiftc} %s -o %T/Asynchronous-Predicates
// RUN: %T/Asynchronous-Predicates > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'PredicateExpectationsTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class PredicateExpectationsTestCase: XCTestCase {
    // CHECK: Test Case 'PredicateExpectationsTestCase.test_immediatelyTruePredicate_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: Test Case 'PredicateExpectationsTestCase.test_immediatelyTruePredicate_passes' passed \(\d+\.\d+ seconds\)
    func test_immediatelyTruePredicate_passes() {
        let predicate = NSPredicate(value: true)
        expectation(for: predicate)
        waitForExpectations(timeout: 0.1)
    }

    // CHECK: Test Case 'PredicateExpectationsTestCase.test_immediatelyTruePredicate_standalone_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: Test Case 'PredicateExpectationsTestCase.test_immediatelyTruePredicate_standalone_passes' passed \(\d+\.\d+ seconds\)
    func test_immediatelyTruePredicate_standalone_passes() {
        let predicate = NSPredicate(value: true)
        let expectation = XCTNSPredicateExpectation(predicate: predicate)
        wait(for: [expectation], timeout: 0.1)
    }

    // CHECK: Test Case 'PredicateExpectationsTestCase.test_immediatelyFalsePredicate_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Predicates[/\\]Expectations[/\\]main.swift:[[@LINE+5]]: error: PredicateExpectationsTestCase.test_immediatelyFalsePredicate_fails : Asynchronous wait failed - Exceeded timeout of 0.1 seconds, with unfulfilled expectations: Expect predicate `<NSPredicate: 0x[0-9A-Fa-f]{1,16}>`
    // CHECK: Test Case 'PredicateExpectationsTestCase.test_immediatelyFalsePredicate_fails' failed \(\d+\.\d+ seconds\)
    func test_immediatelyFalsePredicate_fails() {
        let predicate = NSPredicate(value: false)
        expectation(for: predicate)
        waitForExpectations(timeout: 0.1)
    }

    // CHECK: Test Case 'PredicateExpectationsTestCase.test_delayedTruePredicate_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: Test Case 'PredicateExpectationsTestCase.test_delayedTruePredicate_passes' passed \(\d+\.\d+ seconds\)
    func test_delayedTruePredicate_passes() {
        var didEvaluate = false
        let predicate = NSPredicate(block: { evaluatedObject, bindings in
            XCTAssertNil(evaluatedObject)
            defer { didEvaluate = true }
            return didEvaluate
        })
        expectation(for: predicate)
        waitForExpectations(timeout: 0.1)
        XCTAssertTrue(didEvaluate)
    }
    
    // CHECK: Test Case 'PredicateExpectationsTestCase.test_immediatelyTrueDelayedFalsePredicate_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: Test Case 'PredicateExpectationsTestCase.test_immediatelyTrueDelayedFalsePredicate_passes' passed \(\d+\.\d+ seconds\)
    func test_immediatelyTrueDelayedFalsePredicate_passes() {
        var didEvaluate = false
        let predicate = NSPredicate(block: { evaluatedObject, bindings in
            XCTAssertNil(evaluatedObject)
            defer { didEvaluate = true }
            return !didEvaluate
        })
        expectation(for: predicate)
        waitForExpectations(timeout: 0.1)
        XCTAssertTrue(didEvaluate)
    }

    // CHECK: Test Case 'PredicateExpectationsTestCase.test_blockPredicateWithNilObject_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: Test Case 'PredicateExpectationsTestCase.test_blockPredicateWithNilObject_passes' passed \(\d+\.\d+ seconds\)
    func test_blockPredicateWithNilObject_passes() {
        var flag = false
        let predicate = NSPredicate(block: { _, _ in
            return flag
        })
        expectation(for: predicate, evaluatedWith: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            flag = true
        }
        waitForExpectations(timeout: 1)
        XCTAssertTrue(flag)
    }

    // CHECK: Test Case 'PredicateExpectationsTestCase.test_blockPredicateWithObject_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: Test Case 'PredicateExpectationsTestCase.test_blockPredicateWithObject_passes' passed \(\d+\.\d+ seconds\)
    func test_blockPredicateWithObject_passes() {
        class Foo { var x = false }
        let foo = Foo()
        let predicate = NSPredicate(block: { evaluatedObject, _ in
            guard let object = evaluatedObject as? Foo else { return false }
            return object.x
        })
        expectation(for: predicate, evaluatedWith: foo)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            foo.x = true
        }
        waitForExpectations(timeout: 1)
        XCTAssertTrue(foo.x)
    }
    
    static var allTests = {
        return [
                   ("test_immediatelyTruePredicate_passes", test_immediatelyTruePredicate_passes),
                   ("test_immediatelyTruePredicate_standalone_passes", test_immediatelyTruePredicate_standalone_passes),
                   ("test_immediatelyFalsePredicate_fails", test_immediatelyFalsePredicate_fails),
                   ("test_delayedTruePredicate_passes", test_delayedTruePredicate_passes),
                   ("test_immediatelyTrueDelayedFalsePredicate_passes", test_immediatelyTrueDelayedFalsePredicate_passes),
                   ("test_blockPredicateWithNilObject_passes", test_blockPredicateWithNilObject_passes),
                   ("test_blockPredicateWithObject_passes", test_blockPredicateWithObject_passes),
        ]
    }()
}

// CHECK: Test Suite 'PredicateExpectationsTestCase' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 7 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
XCTMain([testCase(PredicateExpectationsTestCase.allTests)])

// CHECK: Test Suite '.*\.xctest' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 7 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 7 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
