// RUN: %{swiftc} %s -o %{built_tests_dir}/Observation
// RUN: %{built_tests_dir}/Observation > %t || true
// RUN: %{xctest_checker} %t %s

#if os(Linux) || os(FreeBSD)
    import XCTest
#else
    import SwiftXCTest
#endif

class Observer: XCTestObservation {
    var startedTestCaseNames = [String]()
    var failureDescriptions = [String]()
    var finishedTestCaseNames = [String]()

    func testCaseWillStart(testCase: XCTestCase) {
        startedTestCaseNames.append(testCase.name)
    }

    func testCase(testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
        failureDescriptions.append(description)
    }

    func testCaseDidFinish(testCase: XCTestCase) {
        finishedTestCaseNames.append(testCase.name)
    }
}

let observer = Observer()

class Observation: XCTestCase {
    static var allTests: [(String, Observation -> () throws -> Void)] {
        return [
            ("test_one", test_one),
            ("test_two", test_two),
            ("test_three", test_three),
        ]
    }

// CHECK: Test Case 'Observation.test_one' started.
// CHECK: Test Case 'Observation.test_one' passed \(\d+\.\d+ seconds\).
    func test_one() {
        XCTAssertEqual(observer.startedTestCaseNames, [])
        XCTAssertEqual(observer.failureDescriptions, [])
        XCTAssertEqual(observer.finishedTestCaseNames, [])

        XCTestObservationCenter.sharedTestObservationCenter().addTestObserver(observer)
    }

// CHECK: Test Case 'Observation.test_two' started.
// CHECK: .*/Observation/main.swift:\d+: error: Observation.test_two : failed - fail!
// CHECK: Test Case 'Observation.test_two' failed \(\d+\.\d+ seconds\).
    func test_two() {
        XCTAssertEqual(observer.startedTestCaseNames, ["Observation.test_two"])
        XCTAssertEqual(observer.finishedTestCaseNames,["Observation.test_one"])

        XCTFail("fail!")
        XCTAssertEqual(observer.failureDescriptions, ["failed - fail!"])

        XCTestObservationCenter.sharedTestObservationCenter().removeTestObserver(observer)
    }

// CHECK: Test Case 'Observation.test_three' started.
// CHECK: Test Case 'Observation.test_three' passed \(\d+\.\d+ seconds\).
    func test_three() {
        XCTAssertEqual(observer.startedTestCaseNames, ["Observation.test_two"])
        XCTAssertEqual(observer.finishedTestCaseNames,["Observation.test_one"])
    }
}

XCTMain([testCase(Observation.allTests)])

// CHECK: Executed 3 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Total executed 3 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
