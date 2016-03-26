// RUN: %{swiftc} %s -o %{built_tests_dir}/TestCaseLifecycle
// RUN: %{built_tests_dir}/TestCaseLifecycle > %t || true
// RUN: %{xctest_checker} %t %s

#if os(Linux) || os(FreeBSD)
    import XCTest
#else
    import SwiftXCTest
#endif

class SetUpTearDownTestCase: XCTestCase {
    static var allTests: [(String, SetUpTearDownTestCase -> () throws -> Void)] {
        return [("test_hasValueFromSetUp", test_hasValueFromSetUp)]
    }

    var value = 0

    override func setUp() {
        super.setUp()
        print("In \(#function)")
        value = 42
    }

    override func tearDown() {
        super.tearDown()
        print("In \(#function)")
    }

// CHECK: Test Case 'SetUpTearDownTestCase.test_hasValueFromSetUp' started.
// CHECK: In setUp\(\)
// CHECK: In test_hasValueFromSetUp\(\)
// CHECK: In tearDown\(\)
// CHECK: Test Case 'SetUpTearDownTestCase.test_hasValueFromSetUp' passed \(\d+\.\d+ seconds\).
    func test_hasValueFromSetUp() {
        print("In \(#function)")
        XCTAssertEqual(value, 42)
    }
}
// CHECK: Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds


class NewInstanceForEachTestTestCase: XCTestCase {
    static var allTests: [(String, NewInstanceForEachTestTestCase -> () throws -> Void)] {
        return [
            ("test_hasInitializedValue", test_hasInitializedValue),
            ("test_hasInitializedValueInAnotherTest", test_hasInitializedValueInAnotherTest)
        ]
    }

    var value = 1

// CHECK: Test Case 'NewInstanceForEachTestTestCase.test_hasInitializedValue' started.
// CHECK: Test Case 'NewInstanceForEachTestTestCase.test_hasInitializedValue' passed \(\d+\.\d+ seconds\).
    func test_hasInitializedValue() {
        XCTAssertEqual(value, 1)
        value += 1
    }

// CHECK: Test Case 'NewInstanceForEachTestTestCase.test_hasInitializedValueInAnotherTest' started.
// CHECK: Test Case 'NewInstanceForEachTestTestCase.test_hasInitializedValueInAnotherTest' passed \(\d+\.\d+ seconds\).
    func test_hasInitializedValueInAnotherTest() {
        XCTAssertEqual(value, 1)
    }
}
// CHECK: Executed 2 tests, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds


XCTMain([
    testCase(SetUpTearDownTestCase.allTests),
    testCase(NewInstanceForEachTestTestCase.allTests)
])

// CHECK: Total executed 3 tests, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
