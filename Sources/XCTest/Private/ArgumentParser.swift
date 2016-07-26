// This source file is part of the Swift.org open source project
//
// Copyright (c) 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  ArgumentParser.swift
//  Tools for parsing test execution configuration from command line arguments.
//

/// Utility for converting command line arguments into a strongly-typed
/// representation of the passed-in options
internal struct ArgumentParser {

    /// The basic operations that can be performed by an XCTest runner executable
    enum ExecutionMode {
        /// Run a test or test suite, printing results to stdout and exiting with
        /// a non-0 return code if any tests failed. The name of a test or class
        /// may be provided to only run a subset of test cases.
        case run(selectedTestName: String?)

        /// The different ways that the tests can be represented when they are listed
        enum ListType {
            /// A flat list of the tests that can be run. The lines in this
            /// output are valid test names for the `run` mode.
            case humanReadable

            /// A JSON representation of the test suite, intended for consumption
            /// by other tools
            case json
        }

        /// Print a list of all the tests in the suite.
        case list(type: ListType)

        var selectedTestName: String? {
            if case .run(let name) = self {
                return name
            } else {
                return nil
            }
        }
    }

    private let arguments: [String]

    init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    var executionMode: ExecutionMode {
        if arguments.count <= 1 {
            return .run(selectedTestName: nil)
        } else if arguments[1] == "--list-tests" || arguments[1] == "-l" {
            return .list(type: .humanReadable)
        } else if arguments[1] == "--dump-tests-json" {
            return .list(type: .json)
        } else {
            return .run(selectedTestName: arguments[1])
        }
    }
}
