// RUN: %{swiftc} %s -o %{built_tests_dir}/SelectedTest
// RUN: %{built_tests_dir}/SelectedTest SelectedTest.ExecutedTestCase/test_foo > %T/one_test_method || true
// RUN: %{built_tests_dir}/SelectedTest SelectedTest.ExecutedTestCase > %T/one_test_case || true
// RUN: %{built_tests_dir}/SelectedTest > %T/all || true
// RUN: %{xctest_checker} -p "// CHECK-METHOD:" %T/one_test_method %s
// RUN: %{xctest_checker} -p "// CHECK-TESTCASE:" %T/one_test_case %s
// RUN: %{xctest_checker} -p "// CHECK-ALL:" %T/all %s

#if os(Linux) || os(FreeBSD)
    import XCTest
#else
    import SwiftXCTest
#endif

class ExecutedTestCase: XCTestCase {
    static var allTests: [(String, ExecutedTestCase -> () throws -> Void)] {
        return [
            ("test_bar", test_bar),
            ("test_foo", test_foo)
        ]
    }

// CHECK-METHOD:   Test Case 'ExecutedTestCase.test_foo' started.
// CHECK-METHOD:   Test Case 'ExecutedTestCase.test_foo' passed \(\d+\.\d+ seconds\).
// CHECK-TESTCASE: Test Case 'ExecutedTestCase.test_bar' started.
// CHECK-TESTCASE: Test Case 'ExecutedTestCase.test_bar' passed \(\d+\.\d+ seconds\).
// CHECK-ALL:      Test Case 'ExecutedTestCase.test_bar' started.
// CHECK-ALL:      Test Case 'ExecutedTestCase.test_bar' passed \(\d+\.\d+ seconds\).
    func test_bar() {
    }

// CHECK-TESTCASE: Test Case 'ExecutedTestCase.test_foo' started.
// CHECK-TESTCASE: Test Case 'ExecutedTestCase.test_foo' passed \(\d+\.\d+ seconds\).
// CHECK-ALL:      Test Case 'ExecutedTestCase.test_foo' started.
// CHECK-ALL:      Test Case 'ExecutedTestCase.test_foo' passed \(\d+\.\d+ seconds\).
    func test_foo() {
    }
}
// CHECK-METHOD:   Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK-TESTCASE: Executed 2 tests, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK-ALL:      Executed 2 tests, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

class SkippedTestCase: XCTestCase {
    static var allTests: [(String, SkippedTestCase -> () throws -> Void)] {
        return [("test_baz", test_baz)]
    }

// CHECK-ALL: Test Case 'SkippedTestCase.test_baz' started.
// CHECK-ALL: Test Case 'SkippedTestCase.test_baz' passed \(\d+\.\d+ seconds\).
    func test_baz() {
    }
}
// CHECK-ALL: Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([
    testCase(ExecutedTestCase.allTests),
    testCase(SkippedTestCase.allTests)
])

// CHECK-METHOD:   Total executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK-TESTCASE: Total executed 2 tests, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK-ALL:      Total executed 3 tests, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
