// This source file is part of the Swift.org open source project
//
// Copyright (c) 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCAbstractTest.swift
//  An abstract base class that XCTestCase and XCTestSuite inherit from.
//  The purpose of this class is to mirror the design of Apple XCTest.
//

/// An abstract base class for testing. `XCTestCase` and `XCTestSuite` extend
/// `XCTest` to provide for creating, managing, and executing tests. Most
/// developers will not need to subclass `XCTest` directly.
public class XCTest {
    /// Test's name. Must be overridden by subclasses.
    public var name: String {
        fatalError("Must be overridden by subclasses.")
    }

    /// Number of test cases. Must be overridden by subclasses.
    public var testCaseCount: UInt {
        fatalError("Must be overridden by subclasses.")
    }

    /// Setup method called before the invocation of each test method in the
    /// class.
    public func setUp() {}

    /// Teardown method called after the invocation of each test method in the
    /// class.
    public func tearDown() {}
}