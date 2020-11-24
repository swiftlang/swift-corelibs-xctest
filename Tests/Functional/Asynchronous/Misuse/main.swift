// RUN: %{swiftc} %s -o %T/Misuse
// RUN: %T/Misuse > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'MisuseTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class MisuseTestCase: XCTestCase {
// CHECK: Test Case 'MisuseTestCase.test_whenExpectationsAreMade_butNotWaitedFor_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Misuse[/\\]main.swift:[[@LINE+3]]: error: MisuseTestCase.test_whenExpectationsAreMade_butNotWaitedFor_fails : Failed due to unwaited expectations 'the first expectation \(the file and line number for this one are included in the failure message\)', 'the second expectation'
// CHECK: Test Case 'MisuseTestCase.test_whenExpectationsAreMade_butNotWaitedFor_fails' failed \(\d+\.\d+ seconds\)
    func test_whenExpectationsAreMade_butNotWaitedFor_fails() {
        self.expectation(description: "the first expectation (the file and line number for this one are included in the failure message)")
        self.expectation(description: "the second expectation")
    }

// CHECK: Test Case 'MisuseTestCase.test_whenNoExpectationsAreMade_butTheyAreWaitedFor_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]Tests[/\\]Functional[/\\]Asynchronous[/\\]Misuse[/\\]main.swift:[[@LINE+3]]: error: MisuseTestCase.test_whenNoExpectationsAreMade_butTheyAreWaitedFor_fails : API violation - call made to wait without any expectations having been set.
// CHECK: Test Case 'MisuseTestCase.test_whenNoExpectationsAreMade_butTheyAreWaitedFor_fails' failed \(\d+\.\d+ seconds\)
    func test_whenNoExpectationsAreMade_butTheyAreWaitedFor_fails() {
        self.waitForExpectations(timeout: 0.1)
    }

    static var allTests = {
        return [
            ("test_whenExpectationsAreMade_butNotWaitedFor_fails", test_whenExpectationsAreMade_butNotWaitedFor_fails),
            ("test_whenNoExpectationsAreMade_butTheyAreWaitedFor_fails", test_whenNoExpectationsAreMade_butTheyAreWaitedFor_fails),
        ]
    }()
}
// CHECK: Test Suite 'MisuseTestCase' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 2 tests, with 2 failures \(2 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([testCase(MisuseTestCase.allTests)])

// CHECK: Test Suite '.*\.xctest' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 2 tests, with 2 failures \(2 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 2 tests, with 2 failures \(2 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
