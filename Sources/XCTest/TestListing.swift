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

#if os(Linux) || os(FreeBSD)
    import Foundation
#else
    import SwiftFoundation
#endif

internal struct TestListing {
    private let testSuite: XCTestSuite

    init(testSuite: XCTestSuite) {
        self.testSuite = testSuite
    }

    /// Prints a flat list of the tests in the suite, in the format used to
    /// specify a test by name when running tests.
    func printTestList() {
        for entry in testSuite.list() {
            print(entry)
        }
    }

    /// Prints a JSON representation of the tests in the suite, mirring the internal
    /// tree representation of test suites and test cases. This output is intended
    /// to be consumed by other tools.
    func printTestJSON() {
        let json = try! NSJSONSerialization.data(withJSONObject: testSuite.dictionaryRepresentation())
        print(NSString(data: json, encoding: NSUTF8StringEncoding)!)
    }
}

protocol Listable {
    func list() -> [String]
    func dictionaryRepresentation() -> NSDictionary
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

    private var listingName: String {
        if let childTestCase = tests.first as? XCTestCase where name == String(childTestCase.dynamicType) {
            return "\(moduleName(value: childTestCase)).\(name)"
        } else {
            return name
        }
    }

    func list() -> [String] {
        return listables.flatMap({ $0.list() })
    }

    func dictionaryRepresentation() -> NSDictionary {
        let listedTests = tests.flatMap({ ($0 as? Listable)?.dictionaryRepresentation() })
        return [
                   "name": listingName.bridge(),
                   "tests": listedTests.bridge()
            ].bridge()
    }
}

extension XCTestCase: Listable {
    func list() -> [String] {
        let adjustedName = name.characters
            .split(separator: ".")
            .map(String.init)
            .joined(separator: "/")
        return ["\(moduleName(value: self)).\(adjustedName)"]
    }

    func dictionaryRepresentation() -> NSDictionary {
        let methodName = String(name.characters.split(separator: ".").last!)
        return ["name": methodName].bridge()
    }
}
