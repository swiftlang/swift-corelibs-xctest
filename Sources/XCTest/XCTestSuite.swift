// This source file is part of the Swift.org open source project
//
// Copyright (c) 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTestSuite.swift
//  A collection of test cases.
//

/// A concrete subclass of XCTest, XCTestSuite is a collection of test cases.
/// Suites are usually managed by the IDE, but XCTestSuite also provides API
/// for dynamic test and suite management:
///
///     let suite = XCTestSuite(name: "My tests")
///     suite.addTest(MathTest(selector: #selector(testAdd)))
///     suite.addTest(MathTest(selector: #selector(testDivideByZero)))
///
/// Alternatively, a test suite can extract the tests to be run automatically.
/// To do so, pass the class of your test case class to the suite's constructor:
///
///     let suite = XCTestSuite(forTestCaseClass: MathTest.self)
///
/// This creates a suite with all the methods starting with "test" that take no
/// arguments. Also, a test suite of all the test cases found in the runtime
/// can be created automatically:
///
///     let suite = XCTestSuite.defaultTestSuite()
///
/// This creates a suite of suites with all the XCTestCase subclasses methods
/// that start with "test" and take no arguments.
public class XCTestSuite: XCTest {
    public private(set) var tests = [XCTest]()

    /// The name of this test suite.
    override public var name: String {
        return _name
    }
    private let _name: String

    /// The number of test cases in this suite.
    public override var testCaseCount: UInt {
        return UInt(tests.count)
    }

    public init(name: String) {
        _name = name
    }

    /// Adds a test (either an `XCTestSuite` or an `XCTestCase` to this
    /// collection.
    public func addTest(test: XCTest) {
        tests.append(test)
    }
}