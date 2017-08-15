// This source file is part of the Swift.org open source project
//
// Copyright (c) 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTestFiltering.swift
//  This provides utilities for executing only a subset of the tests provided to `XCTMain`
//

internal typealias TestFilter = (XCTestCase.Type, String) -> Bool

internal struct TestFiltering {
    private let selectedTestName: String?

    init(selectedTestName: String?) {
        self.selectedTestName = selectedTestName
    }

    var selectedTestFilter: TestFilter {
        guard let selectedTestName = selectedTestName else { return includeAllFilter() }
        guard let selectedTest = SelectedTest(selectedTestName: selectedTestName) else { return excludeAllFilter() }

        return selectedTest.matches
    }

    private func excludeAllFilter() -> TestFilter {
        return { _,_ in false }
    }

    private func includeAllFilter() -> TestFilter {
        return { _,_ in true }
    }

    static func filterTests(_ entries: [XCTestCaseEntry], filter: TestFilter) -> [XCTestCaseEntry] {
        return entries
            .map { testCaseClass, testCaseMethods in
                return (testCaseClass, testCaseMethods.filter { filter(testCaseClass, $0.0) } )
            }
            .filter { _, testCaseMethods in
                return !testCaseMethods.isEmpty
            }
    }
}

/// A selected test can be a single test case, or an entire class of test cases
private struct SelectedTest {
    let testCaseClassName: String
    let testCaseMethodName: String?
}

private extension SelectedTest {
    init?(selectedTestName: String) {
        let components = selectedTestName.split(separator: "/").map(String.init)
        switch components.count {
        case 1:
            testCaseClassName = components[0]
            testCaseMethodName = nil
        case 2:
            testCaseClassName = components[0]
            testCaseMethodName = components[1]
        default:
            return nil
        }
    }

    func matches(testCaseClass: XCTestCase.Type, testCaseMethodName: String) -> Bool {
        return String(reflecting: testCaseClass) == testCaseClassName && (self.testCaseMethodName == nil || testCaseMethodName == self.testCaseMethodName)
    }
}
