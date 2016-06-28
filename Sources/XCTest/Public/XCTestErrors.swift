// This source file is part of the Swift.org open source project
//
// Copyright (c) 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTestErrors.swift
//  Constants used in errors produced by the XCTest library.
//

/// The domain used by errors produced by the XCTest library.
public let XCTestErrorDomain = "org.swift.XCTestErrorDomain"

/// Error codes for errors in the XCTestErrorDomain.
public enum XCTestErrorCode : Int {
    /// Indicates that one or more expectations failed to be fulfilled in time
    /// during a call to `waitForExpectations(timeout:handler:)`
    case timeoutWhileWaiting

    /// Indicates that a test assertion failed while waiting for expectations
    /// during a call to `waitForExpectations(timeout:handler:)`
    /// FIXME: swift-corelibs-xctest does not currently produce this error code.
    case failureWhileWaiting
}
