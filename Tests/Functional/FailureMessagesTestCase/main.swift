// RUN: %{swiftc} %s -o %{built_tests_dir}/FailureMessagesTestCase
// RUN: %{built_tests_dir}/FailureMessagesTestCase > %t || true
// RUN: %{xctest_checker} %t %s

#if os(Linux) || os(FreeBSD)
    import XCTest
#else
    import SwiftXCTest
#endif

// Regression test for https://github.com/apple/swift-corelibs-xctest/pull/22
class FailureMessagesTestCase: XCTestCase {
    // CHECK: Test Case 'FailureMessagesTestCase.testAssert' started.
    // CHECK: test.swift:17: error: FailureMessagesTestCase.testAssert : XCTAssertTrue failed - message
    // CHECK: Test Case 'FailureMessagesTestCase.testAssert' failed \(\d+\.\d+ seconds\).
    func testAssert() {
        XCTAssert(false, "message", file: "test.swift")
    }

    // CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualOptionals' started.
    // CHECK: test.swift:24: error: FailureMessagesTestCase.testAssertEqualOptionals : XCTAssertEqual failed: \("Optional\(1\)"\) is not equal to \("Optional\(2\)"\) - message
    // CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualOptionals' failed \(\d+\.\d+ seconds\).
    func testAssertEqualOptionals() {
        XCTAssertEqual(1, 2, "message", file: "test.swift")
    }

    // CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualArraySlices' started.
    // CHECK: test.swift:31: error: FailureMessagesTestCase.testAssertEqualArraySlices : XCTAssertEqual failed: \("\[1\]"\) is not equal to \("\[2\]"\) - message
    // CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualArraySlices' failed \(\d+\.\d+ seconds\).
    func testAssertEqualArraySlices() {
        XCTAssertEqual([1][0..<1], [2][0..<1], "message", file: "test.swift")
    }

    // CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualContiguousArrays' started.
    // CHECK: test.swift:38: error: FailureMessagesTestCase.testAssertEqualContiguousArrays : XCTAssertEqual failed: \("\[1\]"\) is not equal to \("\[2\]"\) - message
    // CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualContiguousArrays' failed \(\d+\.\d+ seconds\).
    func testAssertEqualContiguousArrays() {
        XCTAssertEqual(ContiguousArray(arrayLiteral: 1), ContiguousArray(arrayLiteral: 2), "message", file: "test.swift")
    }

    // CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualArrays' started.
    // CHECK: test.swift:45: error: FailureMessagesTestCase.testAssertEqualArrays : XCTAssertEqual failed: \("\[1\]"\) is not equal to \("\[2\]"\) - message
    // CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualArrays' failed \(\d+\.\d+ seconds\).
    func testAssertEqualArrays() {
        XCTAssertEqual([1], [2], "message", file: "test.swift")
    }

    // CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualDictionaries' started.
    // CHECK: test.swift:52: error: FailureMessagesTestCase.testAssertEqualDictionaries : XCTAssertEqual failed: \("\[1: 2\]"\) is not equal to \("\[3: 4\]"\) - message
    // CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualDictionaries' failed \(\d+\.\d+ seconds\).
    func testAssertEqualDictionaries() {
        XCTAssertEqual([1:2], [3:4], "message", file: "test.swift")
    }

    // CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualWithAccuracy' started.
    // CHECK: test.swift:59: error: FailureMessagesTestCase.testAssertEqualWithAccuracy : XCTAssertEqualWithAccuracy failed: \("1\.0"\) is not equal to \("2\.0"\) \+/- \("0\.1"\) - message
    // CHECK: Test Case 'FailureMessagesTestCase.testAssertEqualWithAccuracy' failed \(\d+\.\d+ seconds\).
    func testAssertEqualWithAccuracy() {
        XCTAssertEqualWithAccuracy(1, 2, accuracy: 0.1, "message", file: "test.swift")
    }

    // CHECK: Test Case 'FailureMessagesTestCase.testAssertFalse' started.
    // CHECK: test.swift:66: error: FailureMessagesTestCase.testAssertFalse : XCTAssertFalse failed - message
    // CHECK: Test Case 'FailureMessagesTestCase.testAssertFalse' failed \(\d+\.\d+ seconds\).
    func testAssertFalse() {
        XCTAssertFalse(true, "message", file: "test.swift")
    }

    // CHECK: Test Case 'FailureMessagesTestCase.testAssertGreaterThan' started.
    // CHECK: test.swift:73: error: FailureMessagesTestCase.testAssertGreaterThan : XCTAssertGreaterThan failed: \("0"\) is not greater than \("0"\) - message
    // CHECK: Test Case 'FailureMessagesTestCase.testAssertGreaterThan' failed \(\d+\.\d+ seconds\).
    func testAssertGreaterThan() {
        XCTAssertGreaterThan(0, 0, "message", file: "test.swift")
    }

    // CHECK: Test Case 'FailureMessagesTestCase.testAssertGreaterThanOrEqual' started.
    // CHECK: test.swift:80: error: FailureMessagesTestCase.testAssertGreaterThanOrEqual : XCTAssertGreaterThanOrEqual failed: \("-1"\) is less than \("0"\) - message
    // CHECK: Test Case 'FailureMessagesTestCase.testAssertGreaterThanOrEqual' failed \(\d+\.\d+ seconds\).
    func testAssertGreaterThanOrEqual() {
        XCTAssertGreaterThanOrEqual(-1, 0, "message", file: "test.swift")
    }

    // CHECK: Test Case 'FailureMessagesTestCase.testAssertLessThan' started.
    // CHECK: test.swift:87: error: FailureMessagesTestCase.testAssertLessThan : XCTAssertLessThan failed: \("0"\) is not less than \("0"\) - message
    // CHECK: Test Case 'FailureMessagesTestCase.testAssertLessThan' failed \(\d+\.\d+ seconds\).
    func testAssertLessThan() {
        XCTAssertLessThan(0, 0, "message", file: "test.swift")
    }

    // CHECK: Test Case 'FailureMessagesTestCase.testAssertLessThanOrEqual' started.
    // CHECK: test.swift:94: error: FailureMessagesTestCase.testAssertLessThanOrEqual : XCTAssertLessThanOrEqual failed: \("1"\) is greater than \("0"\) - message
    // CHECK: Test Case 'FailureMessagesTestCase.testAssertLessThanOrEqual' failed \(\d+\.\d+ seconds\).
    func testAssertLessThanOrEqual() {
        XCTAssertLessThanOrEqual(1, 0, "message", file: "test.swift")
    }

    // CHECK: Test Case 'FailureMessagesTestCase.testAssertNil' started.
    // CHECK: test.swift:101: error: FailureMessagesTestCase.testAssertNil : XCTAssertNil failed: "helloworld" - message
    // CHECK: Test Case 'FailureMessagesTestCase.testAssertNil' failed \(\d+\.\d+ seconds\).
    func testAssertNil() {
        XCTAssertNil("helloworld", "message", file: "test.swift")
    }

    // CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualOptionals' started.
    // CHECK: test.swift:108: error: FailureMessagesTestCase.testAssertNotEqualOptionals : XCTAssertNotEqual failed: \("Optional\(1\)"\) is equal to \("Optional\(1\)"\) - message
    // CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualOptionals' failed \(\d+\.\d+ seconds\).
    func testAssertNotEqualOptionals() {
        XCTAssertNotEqual(1, 1, "message", file: "test.swift")
    }

    // CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualArraySlices' started.
    // CHECK: test.swift:115: error: FailureMessagesTestCase.testAssertNotEqualArraySlices : XCTAssertNotEqual failed: \("\[1\]"\) is equal to \("\[1\]"\) - message
    // CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualArraySlices' failed \(\d+\.\d+ seconds\).
    func testAssertNotEqualArraySlices() {
        XCTAssertNotEqual([1][0..<1], [1][0..<1], "message", file: "test.swift")
    }

    // CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualContiguousArrays' started.
    // CHECK: test.swift:122: error: FailureMessagesTestCase.testAssertNotEqualContiguousArrays : XCTAssertNotEqual failed: \("\[1\]"\) is equal to \("\[1\]"\) - message
    // CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualContiguousArrays' failed \(\d+\.\d+ seconds\).
    func testAssertNotEqualContiguousArrays() {
        XCTAssertNotEqual(ContiguousArray(arrayLiteral: 1), ContiguousArray(arrayLiteral: 1), "message", file: "test.swift")
    }

    // CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualArrays' started.
    // CHECK: test.swift:129: error: FailureMessagesTestCase.testAssertNotEqualArrays : XCTAssertNotEqual failed: \("\[1\]"\) is equal to \("\[1\]"\) - message
    // CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualArrays' failed \(\d+\.\d+ seconds\).
    func testAssertNotEqualArrays() {
        XCTAssertNotEqual([1], [1], "message", file: "test.swift")
    }

    // CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualDictionaries' started.
    // CHECK: test.swift:136: error: FailureMessagesTestCase.testAssertNotEqualDictionaries : XCTAssertNotEqual failed: \("\[1: 1\]"\) is equal to \("\[1: 1\]"\) - message
    // CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualDictionaries' failed \(\d+\.\d+ seconds\).
    func testAssertNotEqualDictionaries() {
        XCTAssertNotEqual([1:1], [1:1], "message", file: "test.swift")
    }

    // CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualWithAccuracy' started.
    // CHECK: test.swift:143: error: FailureMessagesTestCase.testAssertNotEqualWithAccuracy : XCTAssertNotEqualWithAccuracy failed: \("1\.0"\) is equal to \("1\.0"\) \+/- \("0\.1"\) - message
    // CHECK: Test Case 'FailureMessagesTestCase.testAssertNotEqualWithAccuracy' failed \(\d+\.\d+ seconds\).
    func testAssertNotEqualWithAccuracy() {
        XCTAssertNotEqualWithAccuracy(1, 1, 0.1, "message", file: "test.swift")
    }

    // CHECK: Test Case 'FailureMessagesTestCase.testAssertNotNil' started.
    // CHECK: test.swift:150: error: FailureMessagesTestCase.testAssertNotNil : XCTAssertNotNil failed - message
    // CHECK: Test Case 'FailureMessagesTestCase.testAssertNotNil' failed \(\d+\.\d+ seconds\).
    func testAssertNotNil() {
        XCTAssertNotNil(nil, "message", file: "test.swift")
    }

    // CHECK: Test Case 'FailureMessagesTestCase.testAssertTrue' started.
    // CHECK: test.swift:157: error: FailureMessagesTestCase.testAssertTrue : XCTAssertTrue failed - message
    // CHECK: Test Case 'FailureMessagesTestCase.testAssertTrue' failed \(\d+\.\d+ seconds\).
    func testAssertTrue() {
        XCTAssertTrue(false, "message", file: "test.swift")
    }

    // CHECK: Test Case 'FailureMessagesTestCase.testFail' started.
    // CHECK: test.swift:164: error: FailureMessagesTestCase.testFail : failed - message
    // CHECK: Test Case 'FailureMessagesTestCase.testFail' failed \(\d+\.\d+ seconds\).
    func testFail() {
        XCTFail("message", file: "test.swift")
    }

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
} // CHECK: Executed 22 tests, with 22 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

// CHECK: Total executed 22 tests, with 22 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
XCTMain([testCase(FailureMessagesTestCase.allTests)])
