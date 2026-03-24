// RUN: %{swiftc} %s -o %T/InteropXCTestInSWT -enable-experimental-feature Extern
// RUN: env XCT_EXPERIMENTAL_ENABLE_INTEROP=1 %T/InteropXCTestInSWT > %t 2>&1 || true
// RUN: %{xctest_checker} %t %s

// Test that XCTFail called without an active XCTestCase forwards the failure
// to the installed fallback event handler (the XCTest → Swift Testing direction).
//
// Ideally we'd just call XCTFail within an @Test function and call it a day,
// but running Swift Testing tests directly through lit is tricky!
//
// Instead, we do the next best thing and install a fallback event handler
// before invoking XCTest to masquerade as a foreign test library.

import Foundation

#if os(macOS)
import SwiftXCTest
#else
import XCTest
#endif

typealias FallbackEventHandler =
    @Sendable @convention(c) (
        _ recordJSONSchemaVersionNumber: UnsafePointer<CChar>,
        _ recordJSONBaseAddress: UnsafeRawPointer,
        _ recordJSONByteCount: Int,
        _ reserved: UnsafeRawPointer?
    ) -> Void

@_extern(c, "_swift_testing_installFallbackEventHandler")
func installer(_ handler: FallbackEventHandler) -> CBool

/// Our custom fallback handler captures the fallback events
/// that Swift Testing would normally receive.
///
/// Prints the message text from the event if found.
let customHandler: FallbackEventHandler = { _, jsonBase, count, _ in
    let jsonData = Data(bytes: jsonBase, count: count)
    if let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
        let payload = json["payload"] as? [String: Any],
        let messages = payload["messages"] as? [[String: Any]],
        let text = messages.first?["text"] as? String
    {
        print("<HANDLER RECEIVED>: \(text)")
    } else {
        print("<HANDLER FAILURE> <failed to decode>")
    }
}

// Take over the installed fallback event handler by installing before running XCTestMain
let installed = installer(customHandler)
precondition(installed, "Failed to install fallback event handler")

// This is triggered outside of a test case, so the failure is forwarded
// to the installed fallback handler (masquerading as Swift Testing).
// CHECK: <HANDLER RECEIVED>: failed - XCTest failure forwarded to Swift Testing
XCTFail("XCTest failure forwarded to Swift Testing")
