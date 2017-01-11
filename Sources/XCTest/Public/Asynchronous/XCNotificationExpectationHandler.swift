// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCNotificationExpectationHandler.swift
//  A closure invoked by XCTestCase when a notification for the expectation is
//  observed.
//

/// A block to be invoked when a notification specified by the expectation is
/// observed.
///
/// - Parameter notification: The notification that the expectation was 
///   observing. 
public typealias XCNotificationExpectationHandler = (Notification) -> (Bool)
