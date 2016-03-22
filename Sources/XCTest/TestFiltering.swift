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
//  This provides utilities for executing only a subset of the tests provided to XCTMain
//

internal typealias TestFilter = (XCTestCase.Type, String) -> Bool

internal struct TestFiltering {
    private let selectedTestName: String?

    init(selectedTestName: String? = ArgumentParser().selectedTestName) {
        self.selectedTestName = selectedTestName
    }

    var selectedTestFilter: TestFilter {
        if let selectedTestName = selectedTestName {
            if let selectedTest = SelectedTest(selectedTestName: selectedTestName) {
                return selectedTest.matches
            } else {
                return excludeAllFilter()
            }
        } else {
            return includeAllFilter()
        }
    }

    private func excludeAllFilter() -> TestFilter {
        return { _ in false }
    }

    private func includeAllFilter() -> TestFilter {
        return { _ in true }
    }

    static func filterTests(entries: [XCTestCaseEntry], filter: TestFilter) -> [XCTestCaseEntry] {
        return entries
            .map({ testCase, tests in
                return (testCase, tests.filter({ filter(testCase, $0.0) }))
            })
            .filter({ testCase, tests in
                return !tests.isEmpty
            })
    }
}

/// A selected test can be an entire test case, or a single test method
/// within a test case.
private struct SelectedTest {
    let testCaseName: String
    let testName: String?
}

private extension SelectedTest {
    init?(selectedTestName: String) {
        let components = selectedTestName.characters.split(separator: "/").map(String.init)
        switch components.count {
        case 1:
            testCaseName = components[0]
            testName = nil
        case 2:
            testCaseName = components[0]
            testName = components[1]
        default:
            return nil
        }
    }

    func matches(testCase testCase: XCTestCase.Type, testName: String) -> Bool {
        return String(reflecting: testCase) == testCaseName && (self.testName == nil || testName == self.testName)
    }
}
