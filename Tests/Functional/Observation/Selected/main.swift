// RUN: %{swiftc} %s -o %{built_tests_dir}/Selected
// RUN: %{built_tests_dir}/Selected Selected.ExecutedTestCase/test_executed > %t || true
// RUN: %{xctest_checker} %t %s

#if os(Linux) || os(FreeBSD)
    import XCTest
    import Foundation
#else
    import SwiftXCTest
    import SwiftFoundation
#endif

class Observer: XCTestObservation {
    var startedTestSuites = [XCTestSuite]()
    var finishedTestSuites = [XCTestSuite]()

    func testBundleWillStart(testBundle: NSBundle) {}

    func testSuiteWillStart(testSuite: XCTestSuite) {
        startedTestSuites.append(testSuite)
    }

    func testCaseWillStart(testCase: XCTestCase) {}
    func testCase(testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {}
    func testCaseDidFinish(testCase: XCTestCase) {}

    func testSuiteDidFinish(testSuite: XCTestSuite) {
        print("In \(#function): \(testSuite.name)")
    }

    func testBundleDidFinish(testBundle: NSBundle) {}
}

let observer = Observer()
XCTestObservationCenter.shared().addTestObserver(observer)

class SkippedTestCase: XCTestCase {
    static var allTests: [(String, SkippedTestCase -> () throws -> Void)] {
        return [
            ("test_skipped", test_skipped),
        ]
    }

    func test_skipped() {
        XCTFail("This test method should not be executed.")
    }
}

class ExecutedTestCase: XCTestCase {
    static var allTests: [(String, ExecutedTestCase -> () throws -> Void)] {
        return [
            ("test_executed", test_executed),
            ("test_skipped", test_skipped),
        ]
    }

// CHECK: Test Case 'ExecutedTestCase.test_executed' started.
// CHECK: Test Case 'ExecutedTestCase.test_executed' passed \(\d+\.\d+ seconds\).
    func test_executed() {
        let suiteNames = observer.startedTestSuites.map { $0.name }
        XCTAssertEqual(suiteNames, ["Selected tests", "ExecutedTestCase"])
    }

    func test_skipped() {
        XCTFail("This test method should not be executed.")
    }
}

XCTMain([
    testCase(SkippedTestCase.allTests),
    testCase(ExecutedTestCase.allTests),
])

// CHECK: Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: In testSuiteDidFinish: ExecutedTestCase
// CHECK: In testSuiteDidFinish: Selected tests
// CHECK: Total executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
