// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTestCase+PredicateExpectation.swift
//

public extension XCTestCase {
    /// Creates and returns an expectation that is fulfilled if the predicate
    /// returns true when evaluated with the given object. The expectation
    /// periodically evaluates the predicate and also may use notifications or
    /// other events to optimistically re-evaluate.
    ///
    /// - Parameter predicate: The predicate that will be used to evaluate the
    ///   object.
    /// - Parameter object: The object that is evaluated against the conditions
    ///   specified by the predicate.
    /// - Parameter file: The file name to use in the error message if
    ///   this expectation is not waited for. Default is the file
    ///   containing the call to this method. It is rare to provide this
    ///   parameter when calling this method.
    /// - Parameter line: The line number to use in the error message if the
    ///   this expectation is not waited for. Default is the line
    ///   number of the call to this method in the calling file. It is rare to
    ///   provide this parameter when calling this method.
    /// - Parameter handler: A block to be invoked when evaluating the predicate
    ///   against the object returns true. If the block is not provided the
    ///   first successful evaluation will fulfill the expectation. If provided,
    ///   the handler can override that behavior which leaves the caller
    ///   responsible for fulfilling the expectation.
    @discardableResult func expectation(for predicate: NSPredicate, evaluatedWith object: AnyObject, file: StaticString = #file, line: Int = #line, handler: XCPredicateExpectationHandler? = nil) -> XCTestExpectation {
        let expectation = XCPredicateExpectation(
            predicate: predicate,
            object: object,
            description: "Expect `\(predicate)` for object \(object)",
            file: file,
            line: line,
            testCase: self,
            handler: handler)
        _allExpectations.append(expectation)
        expectation.considerFulfilling()
        return expectation
    }
}
