// This source file is part of the Swift.org open source project
//
// Copyright (c) 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  TestListing.swift
//  Implementation of the mode for printing the list of tests.
//

internal struct TestListing {
    private let testSuite: XCTestSuite

    init(testSuite: XCTestSuite) {
        self.testSuite = testSuite
    }

    func printTests() {
        for line in testSuite.list() {
            print(line)
        }
    }
}

protocol Listable {
    func list() -> [String]
}

private func moduleName(value: Any) -> String {
    let moduleAndType = String(reflecting: value.dynamicType)
    return String(moduleAndType.characters.split(separator: ".").first!)
}

extension XCTestSuite: Listable {
    private var listables: [Listable] {
        return tests
            .flatMap({ ($0 as? Listable) })
    }

    private var suiteListEntry: [String] {
        if let testCase = tests.first as? XCTestCase {
            return ["\(moduleName(value: testCase)).\(name)"]
        } else {
            return []
        }
    }

    func list() -> [String] {
        return suiteListEntry + listables.flatMap({ $0.list() })
    }
}

extension XCTestCase: Listable {
    func list() -> [String] {
        let adjustedName = name.characters
            .split(separator: ".")
            .map(String.init)
            .joined(separator: "/")
        return ["  \(moduleName(value: self)).\(adjustedName)"]
    }
}
