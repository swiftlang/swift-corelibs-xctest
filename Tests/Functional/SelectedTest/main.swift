// RUN: %{swiftc} %s -o %T/SelectedTest
// RUN: %T/SelectedTest SelectedTest.ExecutedTestCase/test_foo > %T/one_test_case || true
// RUN: %T/SelectedTest SelectedTest.ExecutedTestCase > %T/one_test_case_class || true
// RUN: %T/SelectedTest > %T/all || true
// RUN: %{xctest_checker} -p "// CHECK-METHOD:" %T/one_test_case %s
// RUN: %{xctest_checker} -p "// CHECK-CLASS:" %T/one_test_case_class %s
// RUN: %{xctest_checker} -p "// CHECK-ALL:" %T/all %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

// CHECK-METHOD: Test Suite 'Selected tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-CLASS: Test Suite 'Selected tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-ALL: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-ALL: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

class ExecutedTestCase: XCTestCase {
    static var allTests = {
        return [
            ("test_bar", test_bar),
            ("test_foo", test_foo),
        ]
    }()

// CHECK-METHOD:   Test Suite 'ExecutedTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-METHOD:   Test Case 'ExecutedTestCase.test_foo' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-METHOD:   Test Case 'ExecutedTestCase.test_foo' passed \(\d+\.\d+ seconds\)
// CHECK-CLASS: Test Suite 'ExecutedTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-CLASS: Test Case 'ExecutedTestCase.test_bar' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-CLASS: Test Case 'ExecutedTestCase.test_bar' passed \(\d+\.\d+ seconds\)
// CHECK-ALL:      Test Suite 'ExecutedTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-ALL:      Test Case 'ExecutedTestCase.test_bar' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-ALL:      Test Case 'ExecutedTestCase.test_bar' passed \(\d+\.\d+ seconds\)
    func test_bar() {}

// CHECK-CLASS: Test Case 'ExecutedTestCase.test_foo' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-CLASS: Test Case 'ExecutedTestCase.test_foo' passed \(\d+\.\d+ seconds\)
// CHECK-ALL:      Test Case 'ExecutedTestCase.test_foo' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-ALL:      Test Case 'ExecutedTestCase.test_foo' passed \(\d+\.\d+ seconds\)
    func test_foo() {}
}
// CHECK-METHOD:   Test Suite 'ExecutedTestCase' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-METHOD:   \t Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK-CLASS: Test Suite 'ExecutedTestCase' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-CLASS: \t Executed 2 tests, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK-ALL:      Test Suite 'ExecutedTestCase' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-ALL:      \t Executed 2 tests, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds


// CHECK-ALL: Test Suite 'SkippedTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class SkippedTestCase: XCTestCase {
    static var allTests = {
        return [("test_baz", test_baz)]
    }()

// CHECK-ALL: Test Case 'SkippedTestCase.test_baz' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-ALL: Test Case 'SkippedTestCase.test_baz' passed \(\d+\.\d+ seconds\)
    func test_baz() {}
}
// CHECK-ALL: Test Suite 'SkippedTestCase' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-ALL: \t Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([
    testCase(ExecutedTestCase.allTests),
    testCase(SkippedTestCase.allTests),
])

// CHECK-METHOD:   Test Suite 'Selected tests' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-METHOD:   \t Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK-CLASS: Test Suite 'Selected tests' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-CLASS: \t Executed 2 tests, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK-ALL:      Test Suite '.*\.xctest' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-ALL:      \t Executed 3 tests, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK-ALL:      Test Suite 'All tests' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK-ALL:      \t Executed 3 tests, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
