// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTestCaseProvider.swift
//  Protocol for classes that can provide test cases
//

public protocol XCTestCaseProvider {
    // In the Objective-C version of XCTest, it is possible to discover all tests when the test is executed by asking the runtime for all methods and looking for the string "test". In Swift, we ask test providers to tell us the list of tests by implementing this property.
    var allTests : [(String, () throws -> Void)] { get }
}

