// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCPredicateExpectationHandler.swift
//  A closure invoked by XCTestCase when a predicate for the expectation is
//  evaluated with a given object.
//

/// A block to be invoked when evaluating the predicate against the object 
/// returns true. If the block is not provided the first successful evaluation 
/// will fulfill the expectation. If provided, the handler can override that 
/// behavior which leaves the caller responsible for fulfilling the expectation.
public typealias XCPredicateExpectationHandler = () -> (Bool)
