// RUN: %{swiftc} %s -o %{built_tests_dir}/NegativeAccuracyTestCase
// RUN: %{built_tests_dir}/NegativeAccuracyTestCase > %t || true
// RUN: %{xctest_checker} %t %s
// CHECK: Test Case 'NegativeAccuracyTestCase.test_equalWithAccuracy_passes' started.
// CHECK: Test Case 'NegativeAccuracyTestCase.test_equalWithAccuracy_passes' passed \(\d+\.\d+ seconds\).
// CHECK: Test Case 'NegativeAccuracyTestCase.test_equalWithAccuracy_fails' started.
// CHECK: .*/Tests/Functional/NegativeAccuracyTestCase/main.swift:39: error: NegativeAccuracyTestCase.test_equalWithAccuracy_fails : XCTAssertEqualWithAccuracy failed: \(\"0\.0\"\) is not equal to \(\"0\.2\"\) \+\/- \(\"-0\.1\"\) - $
// CHECK: Test Case 'NegativeAccuracyTestCase.test_equalWithAccuracy_fails' failed \(\d+\.\d+ seconds\).
// CHECK: Test Case 'NegativeAccuracyTestCase.test_notEqualWithAccuracy_passes' started.
// CHECK: Test Case 'NegativeAccuracyTestCase.test_notEqualWithAccuracy_passes' passed \(\d+\.\d+ seconds\).
// CHECK: Test Case 'NegativeAccuracyTestCase.test_notEqualWithAccuracy_fails' started.
// CHECK: .*/Tests/Functional/NegativeAccuracyTestCase/main.swift:47: error: NegativeAccuracyTestCase.test_notEqualWithAccuracy_fails : XCTAssertNotEqualWithAccuracy failed: \("1\.0"\) is equal to \("2\.0"\) \+/- \("-1\.0"\) - $
// CHECK: Test Case 'NegativeAccuracyTestCase.test_notEqualWithAccuracy_fails' failed \(\d+\.\d+ seconds\).
// CHECK: Executed 4 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Total executed 4 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

#if os(Linux) || os(FreeBSD)
    import XCTest
#else
    import SwiftXCTest
#endif

// Regression test for https://github.com/apple/swift-corelibs-xctest/pull/7
class NegativeAccuracyTestCase: XCTestCase {
    var allTests: [(String, () -> ())] {
        return [
            ("test_equalWithAccuracy_passes", test_equalWithAccuracy_passes),
            ("test_equalWithAccuracy_fails", test_equalWithAccuracy_fails),
            ("test_notEqualWithAccuracy_passes", test_notEqualWithAccuracy_passes),
            ("test_notEqualWithAccuracy_fails", test_notEqualWithAccuracy_fails),
        ]
    }

    func test_equalWithAccuracy_passes() {
        XCTAssertEqualWithAccuracy(0, 0.1, accuracy: -0.1)
    }

    func test_equalWithAccuracy_fails() {
        XCTAssertEqualWithAccuracy(0, 0.2, accuracy: -0.1)
    }

    func test_notEqualWithAccuracy_passes() {
        XCTAssertNotEqualWithAccuracy(1, 2, -0.5)
    }

    func test_notEqualWithAccuracy_fails() {
        XCTAssertNotEqualWithAccuracy(1, 2, -1)
    }
}

XCTMain([NegativeAccuracyTestCase()])
