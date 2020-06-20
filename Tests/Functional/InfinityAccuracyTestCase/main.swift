// RUN: %{swiftc} %s -o %T/InfinityAccuracyTestCase
// RUN: %T/InfinityAccuracyTestCase > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

// Regression test for https://bugs.swift.org/browse/SR-13047

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'InfinityAccuracyTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class InfinityAccuracyTestCase: XCTestCase {
    static var allTests = {
        return [
            ("test_equalWithAccuracy_double_passes", test_equalWithAccuracy_double_passes),
            ("test_equalWithAccuracy_float_passes", test_equalWithAccuracy_float_passes),
            ("test_equalWithAccuracy_fails", test_equalWithAccuracy_fails),
            ("test_notEqualWithAccuracy_passes", test_notEqualWithAccuracy_passes),
            ("test_notEqualWithAccuracy_fails", test_notEqualWithAccuracy_fails),
        ]
    }()

// CHECK: Test Case 'InfinityAccuracyTestCase.test_equalWithAccuracy_double_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'InfinityAccuracyTestCase.test_equalWithAccuracy_double_passes' passed \(\d+\.\d+ seconds\)
    func test_equalWithAccuracy_double_passes() {
        XCTAssertEqual(-Double.infinity, -Double.infinity, accuracy: 1e-6)
        XCTAssertEqual(Double.infinity, Double.infinity, accuracy: 1e-6)
    }

// CHECK: Test Case 'InfinityAccuracyTestCase.test_equalWithAccuracy_float_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'InfinityAccuracyTestCase.test_equalWithAccuracy_float_passes' passed \(\d+\.\d+ seconds\)
    func test_equalWithAccuracy_float_passes() {
        XCTAssertEqual(-Float.infinity, -Float.infinity, accuracy: 1e-6)
        XCTAssertEqual(Float.infinity, Float.infinity, accuracy: 1e-6)
    }

// CHECK: Test Case 'InfinityAccuracyTestCase.test_equalWithAccuracy_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]InfinityAccuracyTestCase[/\\]main.swift:[[@LINE+3]]: error: InfinityAccuracyTestCase.test_equalWithAccuracy_fails : XCTAssertEqual failed: \(\"-inf\"\) is not equal to \(\"inf\"\) \+\/- \(\"1e-06"\) - $
// CHECK: Test Case 'InfinityAccuracyTestCase.test_equalWithAccuracy_fails' failed \(\d+\.\d+ seconds\)
    func test_equalWithAccuracy_fails() {
        XCTAssertEqual(-Double.infinity, Double.infinity, accuracy: 1e-6)
    }

// CHECK: Test Case 'InfinityAccuracyTestCase.test_notEqualWithAccuracy_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'InfinityAccuracyTestCase.test_notEqualWithAccuracy_passes' passed \(\d+\.\d+ seconds\)
    func test_notEqualWithAccuracy_passes() {
        XCTAssertNotEqual(-Double.infinity, Double.infinity, accuracy: 1e-6)
    }

// CHECK: Test Case 'InfinityAccuracyTestCase.test_notEqualWithAccuracy_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]InfinityAccuracyTestCase[/\\]main.swift:[[@LINE+3]]: error: InfinityAccuracyTestCase.test_notEqualWithAccuracy_fails : XCTAssertNotEqual failed: \("-inf"\) is equal to \("-inf"\) \+/- \("1e-06"\) - $
// CHECK: Test Case 'InfinityAccuracyTestCase.test_notEqualWithAccuracy_fails' failed \(\d+\.\d+ seconds\)
    func test_notEqualWithAccuracy_fails() {
        XCTAssertNotEqual(-Double.infinity, -Double.infinity, accuracy: 1e-6)
    }
}
// CHECK: Test Suite 'InfinityAccuracyTestCase' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed \d+ tests, with \d+ failures \(\d+ unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([testCase(InfinityAccuracyTestCase.allTests)])

// CHECK: Test Suite '.*\.xctest' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed \d+ tests, with \d+ failures \(\d+ unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed \d+ tests, with \d+ failures \(\d+ unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
