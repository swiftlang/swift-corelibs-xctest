// RUN: %{swiftc} %s -o %{built_tests_dir}/Observation
// RUN: %{built_tests_dir}/Observation > %t || true
// RUN: %{xctest_checker} %t %s

#if os(Linux) || os(FreeBSD)
    import XCTest
    import Foundation
#else
    import SwiftXCTest
    import SwiftFoundation
#endif

class Observer: XCTestObservation {
    var startedBundlePaths: [String] = []
    var startedTestCaseNames: [String] = []
    var failureDescriptions: [String] = []
    var finishedTestCaseNames: [String] = []
    var finishedBundlePaths: [String] = []

    func testBundleWillStart(testBundle: NSBundle) {
        startedBundlePaths.append(testBundle.bundlePath)
    }

    func testCaseWillStart(testCase: XCTestCase) {
        startedTestCaseNames.append(testCase.name)
    }

    func testCase(testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
        failureDescriptions.append(description)
    }

    func testCaseDidFinish(testCase: XCTestCase) {
        finishedTestCaseNames.append(testCase.name)
    }

    func testBundleDidFinish(testBundle: NSBundle) {
        print("In \(#function)")
    }
}

let observer = Observer()
XCTestObservationCenter.shared().addTestObserver(observer)

class Observation: XCTestCase {
    static var allTests: [(String, Observation -> () throws -> Void)] {
        return [
            ("test_one", test_one),
            ("test_two", test_two),
            ("test_three", test_three)
        ]
    }

// CHECK: Test Case 'Observation.test_one' started.
// CHECK: .*/Observation/main.swift:\d+: error: Observation.test_one : failed - fail!
// CHECK: Test Case 'Observation.test_one' failed \(\d+\.\d+ seconds\).
    func test_one() {
        XCTAssertEqual(observer.startedBundlePaths.count, 1)
        XCTAssertEqual(observer.startedTestCaseNames, ["Observation.test_one"])
        XCTAssertEqual(observer.failureDescriptions, [])
        XCTAssertEqual(observer.finishedTestCaseNames, [])
        XCTAssertEqual(observer.finishedBundlePaths.count, 0)

        XCTFail("fail!")
        XCTAssertEqual(observer.failureDescriptions, ["failed - fail!"])
    }

// CHECK: Test Case 'Observation.test_two' started.
// CHECK: Test Case 'Observation.test_two' passed \(\d+\.\d+ seconds\).
    func test_two() {
        XCTAssertEqual(observer.startedBundlePaths.count, 1)
        XCTAssertEqual(observer.startedTestCaseNames, ["Observation.test_one", "Observation.test_two"])
        XCTAssertEqual(observer.finishedTestCaseNames,["Observation.test_one"])
        XCTAssertEqual(observer.finishedBundlePaths.count, 0)

        XCTestObservationCenter.shared().removeTestObserver(observer)
    }

// CHECK: Test Case 'Observation.test_three' started.
// CHECK: Test Case 'Observation.test_three' passed \(\d+\.\d+ seconds\).
    func test_three() {
        XCTAssertEqual(observer.startedBundlePaths.count, 1)
        XCTAssertEqual(observer.startedTestCaseNames, ["Observation.test_one", "Observation.test_two"])
        XCTAssertEqual(observer.finishedTestCaseNames,["Observation.test_one"])
        XCTAssertEqual(observer.finishedBundlePaths.count, 0)

        XCTestObservationCenter.shared().addTestObserver(observer)
    }
}

XCTMain([testCase(Observation.allTests)])

// CHECK: Executed 3 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Total executed 3 tests, with 1 failure \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: In testBundleDidFinish
