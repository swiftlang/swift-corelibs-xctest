// RUN: %{swiftc} %s -o %T/SkippingTestCase
// RUN: %T/SkippingTestCase > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'SkippingTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class SkippingTestCase: XCTestCase {
    static var allTests = {
        return [
            ("testSkip", testSkip),
            ("testSkip_withMessage", testSkip_withMessage),
            ("testSkip_viaSetUpWithError", testSkip_viaSetUpWithError),
            ("testSkipIf_pass", testSkipIf_pass),
            ("testSkipUnless_pass", testSkipUnless_pass),
            ("testSkipIf_fail", testSkipIf_fail),
            ("testSkipUnless_fail", testSkipUnless_fail),
            ("testSkipIf_fail_withMessage", testSkipIf_fail_withMessage),
            ("testSkipUnless_fail_withMessage", testSkipUnless_fail_withMessage),
            ("testSkipIf_fail_errorThrown", testSkipIf_fail_errorThrown),
        ]
    }()

    override func setUpWithError() throws {
        if name == "SkippingTestCase.testSkip_viaSetUpWithError" {
            throw XCTSkip("via setUpWithError")
        }
    }

    // CHECK: Test Case 'SkippingTestCase.testSkip' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: .*[/\\]SkippingTestCase[/\\]main.swift:[[@LINE+3]]: SkippingTestCase.testSkip : Test skipped
    // CHECK: Test Case 'SkippingTestCase.testSkip' skipped \(\d+\.\d+ seconds\)
    func testSkip() throws {
        throw XCTSkip()
    }

    // CHECK: Test Case 'SkippingTestCase.testSkip_withMessage' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: .*[/\\]SkippingTestCase[/\\]main.swift:[[@LINE+3]]: SkippingTestCase.testSkip_withMessage : Test skipped - some reason
    // CHECK: Test Case 'SkippingTestCase.testSkip_withMessage' skipped \(\d+\.\d+ seconds\)
    func testSkip_withMessage() throws {
        throw XCTSkip("some reason")
    }

    // CHECK: Test Case 'SkippingTestCase.testSkip_viaSetUpWithError' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: .*[/\\]SkippingTestCase[/\\]main.swift:[[@LINE-19]]: SkippingTestCase.testSkip_viaSetUpWithError : Test skipped - via setUpWithError
    // CHECK: Test Case 'SkippingTestCase.testSkip_viaSetUpWithError' skipped \(\d+\.\d+ seconds\)
    func testSkip_viaSetUpWithError() {
        XCTFail("should not happen due to XCTSkip in setUpWithError()")
    }

    // CHECK: Test Case 'SkippingTestCase.testSkipIf_pass' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: Test Case 'SkippingTestCase.testSkipIf_pass' passed \(\d+\.\d+ seconds\)
    func testSkipIf_pass() throws {
        let expectation = self.expectation(description: "foo")

        try XCTSkipIf(false)

        expectation.fulfill()
        wait(for: [expectation], timeout: 0)
    }

    // CHECK: Test Case 'SkippingTestCase.testSkipUnless_pass' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: Test Case 'SkippingTestCase.testSkipUnless_pass' passed \(\d+\.\d+ seconds\)
    func testSkipUnless_pass() throws {
        let expectation = self.expectation(description: "foo")

        try XCTSkipUnless(true)

        expectation.fulfill()
        wait(for: [expectation], timeout: 0)
    }

    // CHECK: Test Case 'SkippingTestCase.testSkipIf_fail' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: .*[/\\]SkippingTestCase[/\\]main.swift:[[@LINE+3]]: SkippingTestCase.testSkipIf_fail : Test skipped: required true value but got false
    // CHECK: Test Case 'SkippingTestCase.testSkipIf_fail' skipped \(\d+\.\d+ seconds\)
    func testSkipIf_fail() throws {
        try XCTSkipIf(true)
    }

    // CHECK: Test Case 'SkippingTestCase.testSkipUnless_fail' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: .*[/\\]SkippingTestCase[/\\]main.swift:[[@LINE+3]]: SkippingTestCase.testSkipUnless_fail : Test skipped: required false value but got true
    // CHECK: Test Case 'SkippingTestCase.testSkipUnless_fail' skipped \(\d+\.\d+ seconds\)
    func testSkipUnless_fail() throws {
        try XCTSkipUnless(false)
    }

    // CHECK: Test Case 'SkippingTestCase.testSkipIf_fail_withMessage' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: .*[/\\]SkippingTestCase[/\\]main.swift:[[@LINE+3]]: SkippingTestCase.testSkipIf_fail_withMessage : Test skipped: required true value but got false - some reason
    // CHECK: Test Case 'SkippingTestCase.testSkipIf_fail_withMessage' skipped \(\d+\.\d+ seconds\)
    func testSkipIf_fail_withMessage() throws {
        try XCTSkipIf(true, "some reason")
    }

    // CHECK: Test Case 'SkippingTestCase.testSkipUnless_fail_withMessage' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: .*[/\\]SkippingTestCase[/\\]main.swift:[[@LINE+3]]: SkippingTestCase.testSkipUnless_fail_withMessage : Test skipped: required false value but got true - some reason
    // CHECK: Test Case 'SkippingTestCase.testSkipUnless_fail_withMessage' skipped \(\d+\.\d+ seconds\)
    func testSkipUnless_fail_withMessage() throws {
        try XCTSkipUnless(false, "some reason")
    }

    // CHECK: Test Case 'SkippingTestCase.testSkipIf_fail_errorThrown' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: .*[/\\]SkippingTestCase[/\\]main.swift:[[@LINE+7]]: SkippingTestCase.testSkipIf_fail_errorThrown : Test skipped: threw error "ContrivedError\(message: "foo"\)" - some reason
    // CHECK: Test Case 'SkippingTestCase.testSkipIf_fail_errorThrown' skipped \(\d+\.\d+ seconds\)
    func testSkipIf_fail_errorThrown() throws {
        func someCondition() throws -> Bool {
            throw ContrivedError(message: "foo")
        }

        try XCTSkipIf(someCondition(), "some reason")
    }
}
// CHECK: Test Suite 'SkippingTestCase' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 10 tests, with 8 tests skipped and 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([testCase(SkippingTestCase.allTests)])

// CHECK: Test Suite '.*\.xctest' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 10 tests, with 8 tests skipped and 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 10 tests, with 8 tests skipped and 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

private struct ContrivedError: Error {
    let message: String
}
