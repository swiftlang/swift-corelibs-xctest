// RUN: %{swiftc} %s -o %{built_tests_dir}/FailureMessagesTestCase
// RUN: %{built_tests_dir}/FailureMessagesTestCase > %t || true
// RUN: %{xctest_checker} %t %s

#if os(Linux) || os(FreeBSD)
    import XCTest
#else
    import SwiftXCTest
#endif

// Regression test for https://github.com/apple/swift-corelibs-xctest/pull/22

// CHECK: Test Suite 'All tests' started at \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'FailureMessagesTestCase' started at \d+:\d+:\d+\.\d+
class FailureMessagesTestCase: XCTestCase {
    static var allTests: [(String, FailureMessagesTestCase -> () throws -> Void)] {
        return [
            ("testAssert", testAssert),
            ("testAssertEqualOptionals", testAssertEqualOptionals),
            ("testAssertEqualArraySlices", testAssertEqualArraySlices),
            ("testAssertEqualContiguousArrays", testAssertEqualContiguousArrays),
            ("testAssertEqualArrays", testAssertEqualArrays),
            ("testAssertEqualDictionaries", testAssertEqualDictionaries),
            ("testAssertEqualWithAccuracy", testAssertEqualWithAccuracy),
            ("testAssertFalse", testAssertFalse),
            ("testAssertGreaterThan", testAssertGreaterThan),
            ("testAssertGreaterThanOrEqual", testAssertGreaterThanOrEqual),
            ("testAssertLessThan", testAssertLessThan),
            ("testAssertLessThanOrEqual", testAssertLessThanOrEqual),
            ("testAssertNil", testAssertNil),
            ("testAssertNotEqualOptionals", testAssertNotEqualOptionals),
            ("testAssertNotEqualArraySlices", testAssertNotEqualArraySlices),
            ("testAssertNotEqualContiguousArrays", testAssertNotEqualContiguousArrays),
            ("testAssertNotEqualArrays", testAssertNotEqualArrays),
            ("testAssertNotEqualDictionaries", testAssertNotEqualDictionaries),
            ("testAssertNotEqualWithAccuracy", testAssertNotEqualWithAccuracy),
            ("testAssertNotNil", testAssertNotNil),
            ("testAssertTrue", testAssertTrue),
            ("testFail", testFail),
        ]
    }

// CHECK: Test Case 'FailureMessagesTestCase.testAssert' started at \d+:\d+:\d+\.\d+
// CHECK: test.swift:49: error: FailureMessagesTestCase.testAssert : XCTAssertTrue failed - message
// CHECK: Test Case 'FailureMessagesTestCase.testAssert' failed \(\d+\.\d+ seconds\).
    func testAssert() {
        XCTAssert(false, "message", file: "test.swift")
    }

// CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualOptionals' started at \d+:\d+:\d+\.\d+
// CHECK: test.swift:56: error: FailureMessagesTestCase.testAssertEqualOptionals : XCTAssertEqual failed: \("Optional\(1\)"\) is not equal to \("Optional\(2\)"\) - message
// CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualOptionals' failed \(\d+\.\d+ seconds\).
    func testAssertEqualOptionals() {
        XCTAssertEqual(1, 2, "message", file: "test.swift")
    }

// CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualArraySlices' started at \d+:\d+:\d+\.\d+
// CHECK: test.swift:63: error: FailureMessagesTestCase.testAssertEqualArraySlices : XCTAssertEqual failed: \("\[1\]"\) is not equal to \("\[2\]"\) - message
// CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualArraySlices' failed \(\d+\.\d+ seconds\).
    func testAssertEqualArraySlices() {
        XCTAssertEqual([1][0..<1], [2][0..<1], "message", file: "test.swift")
    }

// CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualContiguousArrays' started at \d+:\d+:\d+\.\d+
// CHECK: test.swift:70: error: FailureMessagesTestCase.testAssertEqualContiguousArrays : XCTAssertEqual failed: \("\[1\]"\) is not equal to \("\[2\]"\) - message
// CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualContiguousArrays' failed \(\d+\.\d+ seconds\).
    func testAssertEqualContiguousArrays() {
        XCTAssertEqual(ContiguousArray(arrayLiteral: 1), ContiguousArray(arrayLiteral: 2), "message", file: "test.swift")
    }

// CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualArrays' started at \d+:\d+:\d+\.\d+
// CHECK: test.swift:77: error: FailureMessagesTestCase.testAssertEqualArrays : XCTAssertEqual failed: \("\[1\]"\) is not equal to \("\[2\]"\) - message
// CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualArrays' failed \(\d+\.\d+ seconds\).
    func testAssertEqualArrays() {
        XCTAssertEqual([1], [2], "message", file: "test.swift")
    }

// CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualDictionaries' started at \d+:\d+:\d+\.\d+
// CHECK: test.swift:84: error: FailureMessagesTestCase.testAssertEqualDictionaries : XCTAssertEqual failed: \("\[1: 2\]"\) is not equal to \("\[3: 4\]"\) - message
// CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualDictionaries' failed \(\d+\.\d+ seconds\).
    func testAssertEqualDictionaries() {
        XCTAssertEqual([1:2], [3:4], "message", file: "test.swift")
    }

// CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualWithAccuracy' started at \d+:\d+:\d+\.\d+
// CHECK: test.swift:91: error: FailureMessagesTestCase.testAssertEqualWithAccuracy : XCTAssertEqualWithAccuracy failed: \("1\.0"\) is not equal to \("2\.0"\) \+/- \("0\.1"\) - message
// CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualWithAccuracy' failed \(\d+\.\d+ seconds\).
    func testAssertEqualWithAccuracy() {
        XCTAssertEqualWithAccuracy(1, 2, accuracy: 0.1, "message", file: "test.swift")
    }

// CHECK: Test Case 'FailureMessagesTestCase.testAssertFalse' started at \d+:\d+:\d+\.\d+
// CHECK: test.swift:98: error: FailureMessagesTestCase.testAssertFalse : XCTAssertFalse failed - message
// CHECK: Test Case 'FailureMessagesTestCase.testAssertFalse' failed \(\d+\.\d+ seconds\).
    func testAssertFalse() {
        XCTAssertFalse(true, "message", file: "test.swift")
    }

// CHECK: Test Case 'FailureMessagesTestCase.testAssertGreaterThan' started at \d+:\d+:\d+\.\d+
// CHECK: test.swift:105: error: FailureMessagesTestCase.testAssertGreaterThan : XCTAssertGreaterThan failed: \("0"\) is not greater than \("0"\) - message
// CHECK: Test Case 'FailureMessagesTestCase.testAssertGreaterThan' failed \(\d+\.\d+ seconds\).
    func testAssertGreaterThan() {
        XCTAssertGreaterThan(0, 0, "message", file: "test.swift")
    }

// CHECK: Test Case 'FailureMessagesTestCase.testAssertGreaterThanOrEqual' started at \d+:\d+:\d+\.\d+
// CHECK: test.swift:112: error: FailureMessagesTestCase.testAssertGreaterThanOrEqual : XCTAssertGreaterThanOrEqual failed: \("-1"\) is less than \("0"\) - message
// CHECK: Test Case 'FailureMessagesTestCase.testAssertGreaterThanOrEqual' failed \(\d+\.\d+ seconds\).
    func testAssertGreaterThanOrEqual() {
        XCTAssertGreaterThanOrEqual(-1, 0, "message", file: "test.swift")
    }

// CHECK: Test Case 'FailureMessagesTestCase.testAssertLessThan' started at \d+:\d+:\d+\.\d+
// CHECK: test.swift:119: error: FailureMessagesTestCase.testAssertLessThan : XCTAssertLessThan failed: \("0"\) is not less than \("0"\) - message
// CHECK: Test Case 'FailureMessagesTestCase.testAssertLessThan' failed \(\d+\.\d+ seconds\).
    func testAssertLessThan() {
        XCTAssertLessThan(0, 0, "message", file: "test.swift")
    }

// CHECK: Test Case 'FailureMessagesTestCase.testAssertLessThanOrEqual' started at \d+:\d+:\d+\.\d+
// CHECK: test.swift:126: error: FailureMessagesTestCase.testAssertLessThanOrEqual : XCTAssertLessThanOrEqual failed: \("1"\) is greater than \("0"\) - message
// CHECK: Test Case 'FailureMessagesTestCase.testAssertLessThanOrEqual' failed \(\d+\.\d+ seconds\).
    func testAssertLessThanOrEqual() {
        XCTAssertLessThanOrEqual(1, 0, "message", file: "test.swift")
    }

// CHECK: Test Case 'FailureMessagesTestCase.testAssertNil' started at \d+:\d+:\d+\.\d+
// CHECK: test.swift:133: error: FailureMessagesTestCase.testAssertNil : XCTAssertNil failed: "helloworld" - message
// CHECK: Test Case 'FailureMessagesTestCase.testAssertNil' failed \(\d+\.\d+ seconds\).
    func testAssertNil() {
        XCTAssertNil("helloworld", "message", file: "test.swift")
    }

// CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualOptionals' started at \d+:\d+:\d+\.\d+
// CHECK: test.swift:140: error: FailureMessagesTestCase.testAssertNotEqualOptionals : XCTAssertNotEqual failed: \("Optional\(1\)"\) is equal to \("Optional\(1\)"\) - message
// CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualOptionals' failed \(\d+\.\d+ seconds\).
    func testAssertNotEqualOptionals() {
        XCTAssertNotEqual(1, 1, "message", file: "test.swift")
    }

// CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualArraySlices' started at \d+:\d+:\d+\.\d+
// CHECK: test.swift:147: error: FailureMessagesTestCase.testAssertNotEqualArraySlices : XCTAssertNotEqual failed: \("\[1\]"\) is equal to \("\[1\]"\) - message
// CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualArraySlices' failed \(\d+\.\d+ seconds\).
    func testAssertNotEqualArraySlices() {
        XCTAssertNotEqual([1][0..<1], [1][0..<1], "message", file: "test.swift")
    }

// CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualContiguousArrays' started at \d+:\d+:\d+\.\d+
// CHECK: test.swift:154: error: FailureMessagesTestCase.testAssertNotEqualContiguousArrays : XCTAssertNotEqual failed: \("\[1\]"\) is equal to \("\[1\]"\) - message
// CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualContiguousArrays' failed \(\d+\.\d+ seconds\).
    func testAssertNotEqualContiguousArrays() {
        XCTAssertNotEqual(ContiguousArray(arrayLiteral: 1), ContiguousArray(arrayLiteral: 1), "message", file: "test.swift")
    }

// CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualArrays' started at \d+:\d+:\d+\.\d+
// CHECK: test.swift:161: error: FailureMessagesTestCase.testAssertNotEqualArrays : XCTAssertNotEqual failed: \("\[1\]"\) is equal to \("\[1\]"\) - message
// CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualArrays' failed \(\d+\.\d+ seconds\).
    func testAssertNotEqualArrays() {
        XCTAssertNotEqual([1], [1], "message", file: "test.swift")
    }

// CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualDictionaries' started at \d+:\d+:\d+\.\d+
// CHECK: test.swift:168: error: FailureMessagesTestCase.testAssertNotEqualDictionaries : XCTAssertNotEqual failed: \("\[1: 1\]"\) is equal to \("\[1: 1\]"\) - message
// CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualDictionaries' failed \(\d+\.\d+ seconds\).
    func testAssertNotEqualDictionaries() {
        XCTAssertNotEqual([1:1], [1:1], "message", file: "test.swift")
    }

// CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualWithAccuracy' started at \d+:\d+:\d+\.\d+
// CHECK: test.swift:175: error: FailureMessagesTestCase.testAssertNotEqualWithAccuracy : XCTAssertNotEqualWithAccuracy failed: \("1\.0"\) is equal to \("1\.0"\) \+/- \("0\.1"\) - message
// CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualWithAccuracy' failed \(\d+\.\d+ seconds\).
    func testAssertNotEqualWithAccuracy() {
        XCTAssertNotEqualWithAccuracy(1, 1, 0.1, "message", file: "test.swift")
    }

// CHECK: Test Case 'FailureMessagesTestCase.testAssertNotNil' started at \d+:\d+:\d+\.\d+
// CHECK: test.swift:182: error: FailureMessagesTestCase.testAssertNotNil : XCTAssertNotNil failed - message
// CHECK: Test Case 'FailureMessagesTestCase.testAssertNotNil' failed \(\d+\.\d+ seconds\).
    func testAssertNotNil() {
        XCTAssertNotNil(nil, "message", file: "test.swift")
    }

// CHECK: Test Case 'FailureMessagesTestCase.testAssertTrue' started at \d+:\d+:\d+\.\d+
// CHECK: test.swift:189: error: FailureMessagesTestCase.testAssertTrue : XCTAssertTrue failed - message
// CHECK: Test Case 'FailureMessagesTestCase.testAssertTrue' failed \(\d+\.\d+ seconds\).
    func testAssertTrue() {
        XCTAssertTrue(false, "message", file: "test.swift")
    }

// CHECK: Test Case 'FailureMessagesTestCase.testFail' started at \d+:\d+:\d+\.\d+
// CHECK: test.swift:196: error: FailureMessagesTestCase.testFail : failed - message
// CHECK: Test Case 'FailureMessagesTestCase.testFail' failed \(\d+\.\d+ seconds\).
    func testFail() {
        XCTFail("message", file: "test.swift")
    }
}
// CHECK: Test Suite 'FailureMessagesTestCase' failed at \d+:\d+:\d+\.\d+
// CHECK: \t Executed 22 tests, with 22 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([testCase(FailureMessagesTestCase.allTests)])

// CHECK: Test Suite '.*\.xctest' failed at \d+:\d+:\d+\.\d+
// CHECK: \t Executed 22 tests, with 22 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+:\d+:\d+\.\d+
// CHECK: \t Executed 22 tests, with 22 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
