// This source file is part of the Swift.org open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  IgnoredErrors.swift
//

/// The user info key used by errors so that they are ignored by the XCTest library.
internal let XCTestErrorUserInfoKeyShouldIgnore = "XCTestErrorUserInfoKeyShouldIgnore"

/// The error type thrown by `XCTUnwrap` on assertion failure.
internal struct XCTestErrorWhileUnwrappingOptional: Error, CustomNSError {
    static var errorDomain: String = XCTestErrorDomain

    var errorCode: Int = 105

    var errorUserInfo: [String : Any] {
        return [XCTestErrorUserInfoKeyShouldIgnore: true]
    }
}
