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

#if os(macOS)
    #if USE_FOUNDATION_FRAMEWORK
    import Foundation
    #else
    import SwiftFoundation
    #endif
#else
    import Foundation
#endif

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
    static let isDebugPrintEnabled = {
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
    /// Print the message if debug printing is enabled for interop.
    fileprivate static func debugPrint(_ message: String) {
        if Interop.Config.isDebugPrintEnabled {
            print(message)
        }
    }

    /// Install XCTest's fallback event handler. This should only be called
    /// if the current process is running XCTest test cases.
    ///
    /// Install can only be performed once per process, and subsequent attempts
    /// will fail.
    ///
    /// - Returns: Whether the handler was successfully installed.
    static func installFallbackEventHandler() -> Bool {
        _installFallbackEventHandler
    }

    private static let _installFallbackEventHandler: Bool = {
        #if XCT_BUILD_WITH_INTEROP
        guard Interop.Config.isEnabledAtRuntime else {
            debugPrint("Interop: disabled because \(Interop.Config.optInEnvName) not set")
            return false
        }

        debugPrint("Interop: installing XCTest's interop handler")
        let ok = installer(ourFallbackEventHandler)
        debugPrint("Interop: install \(ok ? "succeeded" : "failed! Interop is disabled")")
        return ok
        #else
        debugPrint("Interop: disabled because this was built without XCT_BUILD_WITH_INTEROP")
        return false
        #endif
    }()

    /// The currently installed fallback event handler, which is provided by the
    /// testing library that is hosting tests.
    ///
    /// For example, when XCTAssert is called in a Swift Testing test, Swift
    /// Testing installs a handler, and XCTest will store its address in
    /// `activeFallbackEventHandler`.
    static var activeFallbackEventHandler: FallbackEventHandler? = {
        #if XCT_BUILD_WITH_INTEROP
        getter()
        #else
        nil
        #endif
    }()
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

#if XCT_BUILD_WITH_INTEROP

extension Interop.Handler {
    /// XCTest's fallback event handler, which is used to handle issues reported by other test libraries.
    /// It can only report test issues if there is an active XCTest test case.
    fileprivate static let ourFallbackEventHandler: FallbackEventHandler = {
        recordJSONSchemaVersionNumber, recordJSONBaseAddress, recordJSONByteCount, _ in
        guard let schemaVersion = String(validatingCString: recordJSONSchemaVersionNumber),
                schemaVersion == "6.3" else {
            debugPrint("Not handling event because of unsupported schema version")
            return
        }

        // Memory is managed by the caller of the fallback event handler, so do
        // not attempt to deallocate when done.
        let jsonData = Data(
            bytesNoCopy: .init(mutating: recordJSONBaseAddress),
            count: recordJSONByteCount,
            deallocator: .none)

        do {
            guard let currentTestCase = XCTCurrentTestCase else {
                debugPrint("Called without current test case")
                return
            }
            let outputRecord = try JSONDecoder().decode(Interop.OutputRecord.self, from: jsonData)
            currentTestCase.recordFailure(event: outputRecord.payload)
        } catch {
            debugPrint("Unable to convert json event into an output record: \(error)")
        }
    }

    @_extern(c, "_swift_testing_installFallbackEventHandler")
    static func installer(_ handler: FallbackEventHandler) -> CBool

    @_extern(c, "_swift_testing_getFallbackEventHandler")
    static func getter() -> FallbackEventHandler?
}

#endif

extension XCTestCase {
    /// Records a failure created by another test library in the execution of
    /// the test for this test run.
    ///
    /// Note that some detail will be lost in the conversion. For example, this
    /// records all issues as "expected" failures even if they were the result
    /// of thrown errors.
    ///
    /// Must be called *after* the test run has started and *before* it has
    /// stopped.
    ///
    /// - Parameter event: The event record representing a failure. This is
    ///   typically populated by a foreign test library.
    fileprivate func recordFailure(event: Interop.Event) {
        guard event.kind == "issueRecorded", let eventIssue = event.issue else {
            Interop.Handler.debugPrint("Skipping interop for event kind \(event.kind)")
            return
        }

        let description = {
            let messages = event.messages.map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
            guard let firstMessage = messages.first, !firstMessage.isEmpty else {
                return "Unknown issue"
            }

            if messages.count > 1 {
                let remainingMessages = String(messages[1...].joined(separator: "\n"))
                return "\(firstMessage): \(remainingMessages)"
            } else {
                return firstMessage
            }
        }()

        let sourceLocation = eventIssue.sourceLocation
        let filePath = sourceLocation?.filePath ?? "<unknown file>"
        let line = sourceLocation?.line ?? 0

        self.recordFailure(
            withDescription: description,
            inFile: filePath,
            atLine: line,
            // This is not the case for thrown errors, but this information
            // isn't available in the encoded event at this time.
            expected: true)
    }
}
