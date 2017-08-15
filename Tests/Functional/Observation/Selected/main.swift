// RUN: %{swiftc} %s -o %T/Selected
// RUN: %T/Selected Selected.ExecutedTestCase/test_executed > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

// CHECK: Test Suite 'Selected tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

class Observer: XCTestObservation {
    var startedTestSuites = [XCTestSuite]()
    var finishedTestSuites = [XCTestSuite]()

    func testBundleWillStart(_ testBundle: Bundle) {}

    func testSuiteWillStart(_ testSuite: XCTestSuite) {
        startedTestSuites.append(testSuite)
    }

    func testCaseWillStart(_ testCase: XCTestCase) {}
    func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {}
    func testCaseDidFinish(_ testCase: XCTestCase) {}

    func testSuiteDidFinish(_ testSuite: XCTestSuite) {
        print("In \(#function): \(testSuite.name)")
    }

    func testBundleDidFinish(_ testBundle: Bundle) {}
}

let observer = Observer()
XCTestObservationCenter.shared.addTestObserver(observer)

class SkippedTestCase: XCTestCase {
    static var allTests = {
        return [
            ("test_skipped", test_skipped),
        ]
    }()

    func test_skipped() {
        XCTFail("This test case should not be executed.")
    }
}

// CHECK: Test Suite 'ExecutedTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class ExecutedTestCase: XCTestCase {
    static var allTests = {
        return [
            ("test_executed", test_executed),
            ("test_skipped", test_skipped),
        ]
    }()

// CHECK: Test Case 'ExecutedTestCase.test_executed' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ExecutedTestCase.test_executed' passed \(\d+\.\d+ seconds\)
    func test_executed() {
        let suiteNames = observer.startedTestSuites.map { $0.name }
        XCTAssertEqual(suiteNames, ["Selected tests", "ExecutedTestCase"])
    }

    func test_skipped() {
        XCTFail("This test case should not be executed.")
    }
}

// There's no guarantee as to the order in which these two observers will be
// called, so we match any order here.

// CHECK: (In testSuiteDidFinish: ExecutedTestCase)|(Test Suite 'ExecutedTestCase' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+|\t Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds)
// CHECK: (In testSuiteDidFinish: ExecutedTestCase)|(Test Suite 'ExecutedTestCase' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+|\t Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds)
// CHECK: (In testSuiteDidFinish: ExecutedTestCase)|(Test Suite 'ExecutedTestCase' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+|\t Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds)

XCTMain([
    testCase(SkippedTestCase.allTests),
    testCase(ExecutedTestCase.allTests),
])

// CHECK: (In testSuiteDidFinish: Selected tests|Test Suite 'Selected tests' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+)|(\t Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds)
// CHECK: (In testSuiteDidFinish: Selected tests|Test Suite 'Selected tests' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+)|(\t Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds)
// CHECK: (In testSuiteDidFinish: Selected tests|Test Suite 'Selected tests' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+)|(\t Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds)
