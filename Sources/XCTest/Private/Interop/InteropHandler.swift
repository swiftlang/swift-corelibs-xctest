// This source file is part of the Swift.org open source project
//
// Copyright (c) 2026 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  InteropHandler.swift
//

enum Interop {}

extension Interop {
    /// Interop is an experimental feature, so users must manually opt-in.
    enum Config {}
}
extension Interop.Config {
    static let optInEnvName = "XCT_EXPERIMENTAL_ENABLE_INTEROP"
    static let isEnabledAtRuntime = {
        ProcessInfo.processInfo.environment[optInEnvName] == "1"
    }()
    static let debugPrint = {
        ProcessInfo.processInfo.environment["XCT_EXPERIMENTAL_ENABLE_INTEROP_DEBUG"] == "1"
    }()
}

extension Interop {
    /// Utilities for installing and getting the fallback event handler. The
    /// handler is stored in the `_TestingInterop` library, and all test
    /// libraries that participate in interop dynamically link it at runtime so
    /// that they share the same fallback handler.
    enum Handler {}
}

extension Interop.Handler {
    static func debugPrint(_ message: String) {
        if Interop.Config.debugPrint {
            print(message)
        }
    }

    /// Install XCTest's fallback event handler. This should only be called
    /// if the current process is running XCTest test cases.
    ///
    /// Install can only be performed once per process, and subsequent attempts
    /// will fail.
    static func install() {
#if XCT_BUILD_WITH_INTEROP
        guard Interop.Config.isEnabledAtRuntime else {
            debugPrint("Interop: disabled because \(Interop.Config.optInEnvName) not set")
            return
        }

        debugPrint("Interop: installing XCTest's interop handler")
        let ok = installer(handler)
        debugPrint("Interop: install \(ok ? "succeeded" : "failed! Interop is disabled")")
#else
        debugPrint("Interop: disabled because this was built without XCT_BUILD_WITH_INTEROP")
#endif
    }
}

#if XCT_BUILD_WITH_INTEROP

extension Interop.Handler {

    /// XCTest's fallback event handler, which is used to handle issues reported by other test libraries.
    static let handler: FallbackEventHandler = {
        recordJSONSchemaVersionNumber, recordJSONBaseAddress, recordJSONByteCount, reserved in
        // Not implemented yet
        debugPrint("Interop: handler called")
    }

    /// The currently installed fallback event handler, which is provided by the
    /// testing library that is hosting tests.
    ///
    /// For example, when XCTAssert is called in a Swift Testing test, Swift
    /// Testing installs a handler, and XCTest will store its address in
    /// `_installedHandler`.
    private static var _installedHandler: FallbackEventHandler? = getter()
}

/// A fallback event handler is called by a testing library when it wants to
/// record an event, but the current test is being run by a different testing
/// library.
///
/// For example, when `XCTAssertEqual` fails in a Swift Testing test, it cannot
/// directly record the `XCTIssue`. Instead, the `XCTest` library gets the
/// current fallback handler, serializes the `XCTIssue`, and passes the result
/// to the fallback handler.
///
/// - Parameters:
///     - recordJSONSchemaVersionNumber: the schema version for the JSON event.
///     - recordJSONBaseAddress: the start of the JSON event buffer.
///     - recordJSONByteCount: the size of the JSON event buffer.
///     - reserved: do not use.
typealias FallbackEventHandler =
    @Sendable @convention(c) (
        _ recordJSONSchemaVersionNumber: UnsafePointer<CChar>,
        _ recordJSONBaseAddress: UnsafeRawPointer,
        _ recordJSONByteCount: Int,
        _ reserved: UnsafeRawPointer?
    ) -> Void

extension Interop.Handler {
    @_extern(c, "_swift_testing_installFallbackEventHandler")
    static func installer(_ handler: FallbackEventHandler) -> CBool

    @_extern(c, "_swift_testing_getFallbackEventHandler")
    static func getter() -> FallbackEventHandler?
}

#endif
