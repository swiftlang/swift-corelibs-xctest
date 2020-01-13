// RUN: %{swiftc} %s -o %T/NegativeAccuracyTestCase
// RUN: %T/NegativeAccuracyTestCase > %t || true
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

// CHECK: Test Suite 'NegativeAccuracyTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class NegativeAccuracyTestCase: XCTestCase {
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
        ]
    }()

// CHECK: Test Case 'NegativeAccuracyTestCase.test_equalWithAccuracy_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'NegativeAccuracyTestCase.test_equalWithAccuracy_passes' passed \(\d+\.\d+ seconds\)
    func test_equalWithAccuracy_passes() {
        XCTAssertEqual(0, 0.1, accuracy: -0.1)
    }

// CHECK: Test Case 'NegativeAccuracyTestCase.test_equalWithAccuracy_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]NegativeAccuracyTestCase[/\\]main.swift:[[@LINE+3]]: error: NegativeAccuracyTestCase.test_equalWithAccuracy_fails : XCTAssertEqual failed: \("0\.0"\) is not equal to \("0\.2"\) \+\/- \("-0\.1"\) - $
// CHECK: Test Case 'NegativeAccuracyTestCase.test_equalWithAccuracy_fails' failed \(\d+\.\d+ seconds\)
    func test_equalWithAccuracy_fails() {
        XCTAssertEqual(0, 0.2, accuracy: -0.1)
    }

// CHECK: Test Case 'NegativeAccuracyTestCase.test_notEqualWithAccuracy_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'NegativeAccuracyTestCase.test_notEqualWithAccuracy_passes' passed \(\d+\.\d+ seconds\)
    func test_notEqualWithAccuracy_passes() {
        XCTAssertNotEqual(1.0, 2.0, accuracy: -0.5)
    }

// CHECK: Test Case 'NegativeAccuracyTestCase.test_notEqualWithAccuracy_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]NegativeAccuracyTestCase[/\\]main.swift:[[@LINE+3]]: error: NegativeAccuracyTestCase.test_notEqualWithAccuracy_fails : XCTAssertNotEqual failed: \("1\.0"\) is equal to \("2\.0"\) \+/- \("-1\.0"\) - $
// CHECK: Test Case 'NegativeAccuracyTestCase.test_notEqualWithAccuracy_fails' failed \(\d+\.\d+ seconds\)
    func test_notEqualWithAccuracy_fails() {
        XCTAssertNotEqual(1.0, 2.0, accuracy: -1.0)
    }

// CHECK: Test Case 'NegativeAccuracyTestCase.test_equalWithAccuracy_int_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'NegativeAccuracyTestCase.test_equalWithAccuracy_int_passes' passed \(\d+\.\d+ seconds\)
    func test_equalWithAccuracy_int_passes() {
        XCTAssertEqual(10, 11, accuracy: 1)
    }

// CHECK: Test Case 'NegativeAccuracyTestCase.test_equalWithAccuracy_int_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]NegativeAccuracyTestCase[/\\]main.swift:[[@LINE+3]]: error: NegativeAccuracyTestCase.test_equalWithAccuracy_int_fails : XCTAssertEqual failed: \("10"\) is not equal to \("8"\) \+\/- \("1"\) - $
// CHECK: Test Case 'NegativeAccuracyTestCase.test_equalWithAccuracy_int_fails' failed \(\d+\.\d+ seconds\)
    func test_equalWithAccuracy_int_fails() {
        XCTAssertEqual(10, 8, accuracy: 1)
    }

// CHECK: Test Case 'NegativeAccuracyTestCase.test_notEqualWithAccuracy_int_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'NegativeAccuracyTestCase.test_notEqualWithAccuracy_int_passes' passed \(\d+\.\d+ seconds\)
    func test_notEqualWithAccuracy_int_passes() {
        XCTAssertNotEqual(-1, 5, accuracy: 5)
    }

// CHECK: Test Case 'NegativeAccuracyTestCase.test_notEqualWithAccuracy_int_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]NegativeAccuracyTestCase[/\\]main.swift:[[@LINE+3]]: error: NegativeAccuracyTestCase.test_notEqualWithAccuracy_int_fails : XCTAssertNotEqual failed: \("0"\) is equal to \("5"\) \+/- \("5"\) - $
// CHECK: Test Case 'NegativeAccuracyTestCase.test_notEqualWithAccuracy_int_fails' failed \(\d+\.\d+ seconds\)
    func test_notEqualWithAccuracy_int_fails() {
        XCTAssertNotEqual(0, 5, accuracy: 5)
    }

}
// CHECK: Test Suite 'NegativeAccuracyTestCase' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 8 tests, with 4 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([testCase(NegativeAccuracyTestCase.allTests)])

// CHECK: Test Suite '.*\.xctest' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 8 tests, with 4 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 8 tests, with 4 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
