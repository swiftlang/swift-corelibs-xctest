// RUN: %{swiftc} %s -o %T/EqualityWithAccuracy
// RUN: %T/EqualityWithAccuracy > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

// Regression test for https://github.com/apple/swift-corelibs-xctest/pull/7
// and https://github.com/apple/swift-corelibs-xctest/pull/294

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'EqualityWithAccuracyTests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class EqualityWithAccuracyTests: XCTestCase {
    static var allTests = {
        return [
            ("test_equalWithAccuracy_passes", test_equalWithAccuracy_passes),
            ("test_equalWithAccuracy_fails", test_equalWithAccuracy_fails),
            ("test_notEqualWithAccuracy_passes", test_notEqualWithAccuracy_passes),
            ("test_notEqualWithAccuracy_fails", test_notEqualWithAccuracy_fails),
            ("test_equalWithAccuracy_int_passes", test_equalWithAccuracy_int_passes),
            ("test_equalWithAccuracy_int_fails", test_equalWithAccuracy_int_fails),
            ("test_notEqualWithAccuracy_int_passes", test_notEqualWithAccuracy_int_passes),
            ("test_notEqualWithAccuracy_int_fails", test_notEqualWithAccuracy_int_fails),
            ("test_equalWithAccuracy_infinity_fails", test_equalWithAccuracy_infinity_fails),
            ("test_notEqualWithAccuracy_infinity_fails", test_notEqualWithAccuracy_infinity_fails),
            ("test_equalWithAccuracy_nan_fails", test_equalWithAccuracy_nan_fails),
        ]
    }()

// CHECK: Test Case 'EqualityWithAccuracyTests.test_equalWithAccuracy_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'EqualityWithAccuracyTests.test_equalWithAccuracy_passes' passed \(\d+\.\d+ seconds\)
    func test_equalWithAccuracy_passes() {
        XCTAssertEqual(0, 0.1, accuracy: -0.1)
        XCTAssertEqual(1, 1, accuracy: 0)
        XCTAssertEqual(0, 0, accuracy: 0)
        XCTAssertEqual(0, 1, accuracy: 1)
        XCTAssertEqual(0, 1, accuracy: 1.01)
        XCTAssertEqual(1, 1.09, accuracy: 0.1)
        XCTAssertEqual(1 as Float, 1.09, accuracy: 0.1)
        XCTAssertEqual(1 as Float32, 1.09, accuracy: 0.1)
        XCTAssertEqual(1 as Float64, 1.09, accuracy: 0.1)
        XCTAssertEqual(1 as CGFloat, 1.09, accuracy: 0.1)
        XCTAssertEqual(1 as Double, 1.09, accuracy: 0.1)
        XCTAssertEqual(1 as Int, 2, accuracy: 5)
        XCTAssertEqual(1 as UInt, 4, accuracy: 5)
        XCTAssertEqual(1, -1, accuracy: 2)
        XCTAssertEqual(-2, -4, accuracy: 2)
        XCTAssertEqual(Double.infinity, .infinity, accuracy: 0)
        XCTAssertEqual(Double.infinity, .infinity, accuracy: 1)
        XCTAssertEqual(Double.infinity, .infinity, accuracy: 1e-6)
        XCTAssertEqual(-Double.infinity, -.infinity, accuracy: 1)
        XCTAssertEqual(Double.infinity, .infinity, accuracy: 1e-6)
        XCTAssertEqual(Double.infinity, .infinity, accuracy: 1e6)
        XCTAssertEqual(Double.infinity, .infinity, accuracy: .infinity)
        XCTAssertEqual(Double.infinity, -.infinity, accuracy: .infinity)
        XCTAssertEqual(Float.infinity, .infinity, accuracy: 1e-6)
        XCTAssertEqual(Double.infinity, .infinity - 1, accuracy: 0)
    }

// CHECK: Test Case 'EqualityWithAccuracyTests.test_equalWithAccuracy_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]EqualityWithAccuracy[/\\]main.swift:[[@LINE+3]]: error: EqualityWithAccuracyTests.test_equalWithAccuracy_fails : XCTAssertEqual failed: \("0\.0"\) is not equal to \("0\.2"\) \+\/- \("-0\.1"\) - $
// CHECK: Test Case 'EqualityWithAccuracyTests.test_equalWithAccuracy_fails' failed \(\d+\.\d+ seconds\)
    func test_equalWithAccuracy_fails() {
        XCTAssertEqual(0, 0.2, accuracy: -0.1)
    }

// CHECK: Test Case 'EqualityWithAccuracyTests.test_notEqualWithAccuracy_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'EqualityWithAccuracyTests.test_notEqualWithAccuracy_passes' passed \(\d+\.\d+ seconds\)
    func test_notEqualWithAccuracy_passes() {
        XCTAssertNotEqual(1.0, 2.0, accuracy: -0.5)
        XCTAssertNotEqual(0, 1, accuracy: 0.1)
        XCTAssertNotEqual(1, 1.11, accuracy: 0.1)
        XCTAssertNotEqual(1 as Float, 1.11, accuracy: 0.1)
        XCTAssertNotEqual(1 as Float32, 1.11, accuracy: 0.1)
        XCTAssertNotEqual(1 as Float64, 1.11, accuracy: 0.1)
        XCTAssertNotEqual(1 as CGFloat, 1.11, accuracy: 0.1)
        XCTAssertNotEqual(1 as Double, 1.11, accuracy: 0.1)
        XCTAssertNotEqual(1 as Int, 10, accuracy: 5)
        XCTAssertNotEqual(1 as UInt, 10, accuracy: 5)
        XCTAssertNotEqual(1, -1, accuracy: 1)
        XCTAssertNotEqual(-2, -4, accuracy: 1)
        XCTAssertNotEqual(Double.nan, Double.nan, accuracy: 0)
        XCTAssertNotEqual(1, Double.nan, accuracy: 0)
        XCTAssertNotEqual(Double.nan, 1, accuracy: 0)
        XCTAssertNotEqual(Double.nan, 1, accuracy: .nan)
        XCTAssertNotEqual(Double.infinity, -.infinity, accuracy: 0)
        XCTAssertNotEqual(Double.infinity, -.infinity, accuracy: 1)
        XCTAssertNotEqual(Double.infinity, -.infinity, accuracy: 1e-6)
        XCTAssertNotEqual(Double.infinity, -.infinity, accuracy: 1e6)
    }

// CHECK: Test Case 'EqualityWithAccuracyTests.test_notEqualWithAccuracy_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]EqualityWithAccuracy[/\\]main.swift:[[@LINE+3]]: error: EqualityWithAccuracyTests.test_notEqualWithAccuracy_fails : XCTAssertNotEqual failed: \("1\.0"\) is equal to \("2\.0"\) \+/- \("-1\.0"\) - $
// CHECK: Test Case 'EqualityWithAccuracyTests.test_notEqualWithAccuracy_fails' failed \(\d+\.\d+ seconds\)
    func test_notEqualWithAccuracy_fails() {
        XCTAssertNotEqual(1.0, 2.0, accuracy: -1.0)
    }

// CHECK: Test Case 'EqualityWithAccuracyTests.test_equalWithAccuracy_int_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'EqualityWithAccuracyTests.test_equalWithAccuracy_int_passes' passed \(\d+\.\d+ seconds\)
    func test_equalWithAccuracy_int_passes() {
        XCTAssertEqual(10, 11, accuracy: 1)
    }

// CHECK: Test Case 'EqualityWithAccuracyTests.test_equalWithAccuracy_int_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]EqualityWithAccuracy[/\\]main.swift:[[@LINE+3]]: error: EqualityWithAccuracyTests.test_equalWithAccuracy_int_fails : XCTAssertEqual failed: \("10"\) is not equal to \("8"\) \+\/- \("1"\) - $
// CHECK: Test Case 'EqualityWithAccuracyTests.test_equalWithAccuracy_int_fails' failed \(\d+\.\d+ seconds\)
    func test_equalWithAccuracy_int_fails() {
        XCTAssertEqual(10, 8, accuracy: 1)
    }

// CHECK: Test Case 'EqualityWithAccuracyTests.test_notEqualWithAccuracy_int_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'EqualityWithAccuracyTests.test_notEqualWithAccuracy_int_passes' passed \(\d+\.\d+ seconds\)
    func test_notEqualWithAccuracy_int_passes() {
        XCTAssertNotEqual(-1, 5, accuracy: 5)
    }

// CHECK: Test Case 'EqualityWithAccuracyTests.test_notEqualWithAccuracy_int_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]EqualityWithAccuracy[/\\]main.swift:[[@LINE+3]]: error: EqualityWithAccuracyTests.test_notEqualWithAccuracy_int_fails : XCTAssertNotEqual failed: \("0"\) is equal to \("5"\) \+/- \("5"\) - $
// CHECK: Test Case 'EqualityWithAccuracyTests.test_notEqualWithAccuracy_int_fails' failed \(\d+\.\d+ seconds\)
    func test_notEqualWithAccuracy_int_fails() {
        XCTAssertNotEqual(0, 5, accuracy: 5)
    }

// CHECK: Test Case 'EqualityWithAccuracyTests.test_equalWithAccuracy_infinity_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]EqualityWithAccuracy[/\\]main.swift:[[@LINE+3]]: error: EqualityWithAccuracyTests.test_equalWithAccuracy_infinity_fails : XCTAssertEqual failed: \(\"-inf\"\) is not equal to \(\"inf\"\) \+\/- \(\"1e-06"\) - $
// CHECK: Test Case 'EqualityWithAccuracyTests.test_equalWithAccuracy_infinity_fails' failed \(\d+\.\d+ seconds\)
    func test_equalWithAccuracy_infinity_fails() {
         XCTAssertEqual(-Double.infinity, .infinity, accuracy: 1e-6)
     }

// CHECK: Test Case 'EqualityWithAccuracyTests.test_notEqualWithAccuracy_infinity_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]EqualityWithAccuracy[/\\]main.swift:[[@LINE+3]]: error: EqualityWithAccuracyTests.test_notEqualWithAccuracy_infinity_fails : XCTAssertNotEqual failed: \("-inf"\) is equal to \("-inf"\) \+/- \("1e-06"\) - $
// CHECK: Test Case 'EqualityWithAccuracyTests.test_notEqualWithAccuracy_infinity_fails' failed \(\d+\.\d+ seconds\)
    func test_notEqualWithAccuracy_infinity_fails() {
        XCTAssertNotEqual(-Double.infinity, -.infinity, accuracy: 1e-6)
    }

// CHECK: Test Case 'EqualityWithAccuracyTests.test_equalWithAccuracy_nan_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]EqualityWithAccuracy[/\\]main.swift:[[@LINE+3]]: error: EqualityWithAccuracyTests.test_equalWithAccuracy_nan_fails : XCTAssertEqual failed: \("nan"\) is not equal to \("nan"\) \+/- \("0.0"\) - $
// CHECK: Test Case 'EqualityWithAccuracyTests.test_equalWithAccuracy_nan_fails' failed \(\d+\.\d+ seconds\)
    func test_equalWithAccuracy_nan_fails() {
        XCTAssertEqual(Double.nan, Double.nan, accuracy: 0)
    }

}
// CHECK: Test Suite 'EqualityWithAccuracyTests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 11 tests, with 7 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([testCase(EqualityWithAccuracyTests.allTests)])

// CHECK: Test Suite '.*\.xctest' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 11 tests, with 7 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 11 tests, with 7 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
