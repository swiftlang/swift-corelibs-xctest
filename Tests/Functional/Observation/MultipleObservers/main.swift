// RUN: %{swiftc} %s -o %T/MultipleObservers
// RUN: %T/MultipleObservers > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

class Observer: XCTestObservation {
    var startedBundlePaths = [String]()
    var startedTestSuites = [XCTestSuite]()
    var startedTestCaseNames = [String]()
    var failureDescriptions = [String]()
    var finishedTestCaseNames = [String]()
    var finishedTestSuites = [XCTestSuite]()
    var finishedBundlePaths = [String]()

    func testBundleWillStart(_ testBundle: Bundle) {
        startedBundlePaths.append(testBundle.bundlePath)
    }

    func testSuiteWillStart(_ testSuite: XCTestSuite) {
        startedTestSuites.append(testSuite)
    }

    func testCaseWillStart(_ testCase: XCTestCase) {
        startedTestCaseNames.append(testCase.name)
    }

    func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        failureDescriptions.append(description)
    }

    func testCaseDidFinish(_ testCase: XCTestCase) {
        finishedTestCaseNames.append(testCase.name)
    }

    func testSuiteDidFinish(_ testSuite: XCTestSuite) {
        print("In \(#function): \(testSuite.name)")
    }

    func testBundleDidFinish(_ testBundle: Bundle) {
        print("In \(#function)")
    }
}

let observer1 = Observer()
let observer2 = Observer()

class Observation: XCTestCase {
    static var allTests = {
        return [
            ("test_one", test_one),
            ("test_two", test_two),
            ("test_three", test_three),
        ]
    }()

    func test_one() {
        XCTAssertEqual(observer1.startedBundlePaths.count, 1)
        XCTAssertEqual(observer2.startedBundlePaths.count, 1)
        XCTAssertEqual(
            observer1.startedTestSuites.count, 3,
            "Three test suites should have started: 'All tests', 'tmp.xctest', and 'Observation'.")
        XCTAssertEqual(
            observer2.startedTestSuites.count, 3,
            "Three test suites should have started: 'All tests', 'tmp.xctest', and 'Observation'.")
        XCTAssertEqual(observer1.startedTestCaseNames, ["Observation.test_one"])
        XCTAssertEqual(observer2.startedTestCaseNames, ["Observation.test_one"])
        XCTAssertEqual(observer1.failureDescriptions, [])
        XCTAssertEqual(observer2.failureDescriptions, [])
        XCTAssertEqual(observer1.finishedTestCaseNames, [])
        XCTAssertEqual(observer2.finishedTestCaseNames, [])
        XCTAssertEqual(observer1.finishedBundlePaths.count, 0)
        XCTAssertEqual(observer2.finishedBundlePaths.count, 0)

        XCTFail("fail!")
        XCTAssertEqual(observer1.failureDescriptions, ["failed - fail!"])
        XCTAssertEqual(observer2.failureDescriptions, ["failed - fail!"])
    }

    func test_two() {
        XCTAssertEqual(observer1.startedBundlePaths.count, 1)
        XCTAssertEqual(observer2.startedBundlePaths.count, 1)
        XCTAssertEqual(
            observer1.startedTestSuites.count, 3,
            "Three test suites should have started: 'All tests', 'tmp.xctest', and 'Observation'.")
        XCTAssertEqual(
            observer2.startedTestSuites.count, 3,
            "Three test suites should have started: 'All tests', 'tmp.xctest', and 'Observation'.")
        XCTAssertEqual(observer1.startedTestCaseNames, ["Observation.test_one", "Observation.test_two"])
        XCTAssertEqual(observer2.startedTestCaseNames, ["Observation.test_one", "Observation.test_two"])
        XCTAssertEqual(observer1.finishedTestCaseNames,["Observation.test_one"])
        XCTAssertEqual(observer2.finishedTestCaseNames,["Observation.test_one"])
        XCTAssertEqual(observer1.finishedBundlePaths.count, 0)
        XCTAssertEqual(observer2.finishedBundlePaths.count, 0)

        XCTestObservationCenter.shared.removeTestObserver(observer1)
        XCTestObservationCenter.shared.removeTestObserver(observer2)
    }

    func test_three() {
        XCTAssertEqual(observer1.startedBundlePaths.count, 1)
        XCTAssertEqual(observer2.startedBundlePaths.count, 1)
        XCTAssertEqual(observer1.startedTestCaseNames, ["Observation.test_one", "Observation.test_two"])
        XCTAssertEqual(observer2.startedTestCaseNames, ["Observation.test_one", "Observation.test_two"])
        XCTAssertEqual(observer1.finishedTestCaseNames,["Observation.test_one"])
        XCTAssertEqual(observer2.finishedTestCaseNames,["Observation.test_one"])
        XCTAssertEqual(observer1.finishedBundlePaths.count, 0)
        XCTAssertEqual(observer2.finishedBundlePaths.count, 0)

        XCTestObservationCenter.shared.addTestObserver(observer1)
        XCTestObservationCenter.shared.addTestObserver(observer2)
    }
}

// There's no guarantee as to the order in which these two observers will be
// called, so we match any order here.

// CHECK: In testSuiteDidFinish\(_:\): Observation
// CHECK: In testSuiteDidFinish\(_:\): Observation

XCTMain(
    [testCase(Observation.allTests)],
    arguments: CommandLine.arguments,
    observers: [observer1, observer2]
)

// CHECK: In testSuiteDidFinish\(_:\): .*\.xctest
// CHECK: In testSuiteDidFinish\(_:\): .*\.xctest

// CHECK: In testSuiteDidFinish\(_:\): All tests
// CHECK: In testSuiteDidFinish\(_:\): All tests

// CHECK: In testBundleDidFinish\(_:\)
// CHECK: In testBundleDidFinish\(_:\)
