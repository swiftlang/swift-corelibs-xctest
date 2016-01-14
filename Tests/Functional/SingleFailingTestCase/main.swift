// RUN: %{swiftc} %s -o %{built_tests_dir}/SingleFailingTestCase
// RUN: %{built_tests_dir}/SingleFailingTestCase > %t || true
// RUN: %{xctest_checker} %t %s
// CHECK: Test Case 'SingleFailingTestCase.test_fails' started.
// CHECK: .*/Tests/Functional/SingleFailingTestCase/main.swift:24: error: SingleFailingTestCase.test_fails : XCTAssertTrue failed - 
// CHECK: Test Case 'SingleFailingTestCase.test_fails' failed \(\d+\.\d+ seconds\).
// CHECK: Executed 1 test, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Total executed 1 test, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

#if os(Linux) || os(FreeBSD)
    import XCTest
#else
    import SwiftXCTest
#endif

class SingleFailingTestCase: XCTestCase {
    var allTests: [(String, () throws -> ())] {
        return [
            ("test_fails", test_fails),
        ]
    }

    func test_fails() {
        XCTAssert(false)
    }
}

XCTMain([SingleFailingTestCase()])
