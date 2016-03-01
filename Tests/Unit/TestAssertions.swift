// This source file is part of the Swift.org open source project
//
// Copyright (c) 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

class TestAssertions: XCTestCase {
    var allTests: [(String, () throws -> Void)] {
        return [
            ("test_passingAssertionDoesNotCallFailureHandler", test_passingAssertionDoesNotCallFailureHandler),
            ("test_failedAssertionCallsFailureHandlerWithCorrectFailure", test_failedAssertionCallsFailureHandlerWithCorrectFailure),
        ]
    }

    func test_passingAssertionDoesNotCallFailureHandler() {
        let failures = captureFailures {
            XCTAssert(true)
        }

        XCTAssertTrue(failures.isEmpty)
    }

    func test_failedAssertionCallsFailureHandlerWithCorrectFailure() {
        let failures = captureFailures {
            XCTAssert(false, "This should fail")
        }

        XCTAssertEqual(failures.count, 1)

        let failure = failures.first
        XCTAssertEqual(failure?.message, "This should fail")
        XCTAssertEqual(failure?.failureDescription, "XCTAssertTrue failed")
        XCTAssertTrue(failure?.expected ?? false)

        let baseFileName = failure?.file.stringValue.characters.split("/").map(String.init).last
        XCTAssertEqual(baseFileName, "TestAssertions.swift")
    }

    private func captureFailures(closure: () -> Void) -> [XCTFailure] {
        var failures = [XCTFailure]()

        let oldHandler = XCTFailureHandler
        XCTFailureHandler = { failures.append($0) }
        closure()
        XCTFailureHandler = oldHandler

        return failures
    }
}
