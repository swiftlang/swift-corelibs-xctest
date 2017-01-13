// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCWaitCompletionHandler.swift
//  A closure invoked by XCTestCase when a wait for expectations to be
//  fulfilled times out.
//

/// A block to be invoked when a call to wait times out or has had all
/// associated expectations fulfilled.
///
/// - Parameter error: If the wait timed out or a failure was raised while
///   waiting, the error's code will specify the type of failure. Otherwise
///   error will be nil.
public typealias XCWaitCompletionHandler = (NSError?) -> ()
