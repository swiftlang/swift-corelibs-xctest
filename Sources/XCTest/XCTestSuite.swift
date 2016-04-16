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
///     XCTestSuite *suite = [XCTestSuite testSuiteWithName:@"My tests"];
///     [suite addTest:[MathTest testCaseWithSelector:@selector(testAdd)]];
///     [suite addTest:[MathTest testCaseWithSelector:@selector(testDivideByZero)]];
///
/// Alternatively, a test suite can extract the tests to be run automatically.
/// To do so, pass the class of your test case class to the suite's constructor:
///
///     XCTestSuite *suite = [XCTestSuite testSuiteForTestCaseClass:[MathTest class]];
///
/// This creates a suite with all the methods starting with "test" that take no
/// arguments. Also, a test suite of all the test cases found in the runtime
/// can be created automatically:
///
///     XCTestSuite *suite = [XCTestSuite defaultTestSuite];
///
/// This creates a suite of suites with all the XCTestCase subclasses methods
/// that start with "test" and take no arguments.
public class XCTestSuite: XCTest {
    public private(set) var tests = [XCTest]()

    /// The name of this test suite.
    override public var name: String {
        return _name
    }
    /// A private setter for the name of this test suite.
    /// - Note: FIXME: This property should be readonly, but currently has to
    ///   be publicly settable due to a Swift compiler bug on Linux. To ensure
    ///   compatibility of tests between swift-corelibs-xctest and Apple XCTest,
    ///   this property should not be modified. See
    ///   https://bugs.swift.org/browse/SR-1129 for details.
    public let _name: String

    /// The number of test cases in this suite.
    public override var testCaseCount: UInt {
        return tests.reduce(0) { $0 + $1.testCaseCount }
    }

    public override var testRunClass: AnyClass? {
        return XCTestSuiteRun.self
    }

    public override func perform(_ run: XCTestRun) {
        guard let testRun = run as? XCTestSuiteRun else {
            fatalError("Wrong XCTestRun class.")
        }

        run.start()
        setUp()
        for test in tests {
            test.run()
            testRun.addTestRun(test.testRun!)
        }
        tearDown()
        run.stop()
    }

    public init(name: String) {
        _name = name
    }

    /// Adds a test (either an `XCTestSuite` or an `XCTestCase` to this
    /// collection.
    public func addTest(_ test: XCTest) {
        tests.append(test)
    }
}
