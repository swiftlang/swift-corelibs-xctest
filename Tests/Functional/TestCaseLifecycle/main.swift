// RUN: %{swiftc} %s -o %{built_tests_dir}/TestCaseLifecycle
// RUN: %{built_tests_dir}/TestCaseLifecycle > %t || true
// RUN: %{xctest_checker} %t %s
// CHECK: Test Case 'SetUpTearDownTestCase.test_hasValueFromSetUp' started.
// CHECK: In setUp\(\)
// CHECK: In test_hasValueFromSetUp\(\)
// CHECK: In tearDown\(\)
// CHECK: Test Case 'SetUpTearDownTestCase.test_hasValueFromSetUp' passed \(\d+\.\d+ seconds\).
// CHECK: Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Total executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

#if os(Linux) || os(FreeBSD)
    import XCTest
#else
    import SwiftXCTest
#endif

class SetUpTearDownTestCase: XCTestCase {
    var allTests: [(String, () throws -> Void)] {
        return [
            ("test_hasValueFromSetUp", test_hasValueFromSetUp),
        ]
    }

    var value = 0

    override func setUp() {
        super.setUp()
        print("In \(__FUNCTION__)")
        value = 42
    }

    override func tearDown() {
        super.tearDown()
        print("In \(__FUNCTION__)")
    }

    func test_hasValueFromSetUp() {
        print("In \(__FUNCTION__)")
        XCTAssertEqual(value, 42)
    }
}

XCTMain([SetUpTearDownTestCase()])
