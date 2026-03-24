// This source file is part of the Swift.org open source project
//
// Copyright (c) 2026 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  InteropRecord.swift
//

extension Interop {
    struct OutputRecord: Codable {
        var payload: Event
        var version = "6.3"
        var kind = "event"
    }

    /// An event that appears in the event stream.
    ///
    /// The event format captures test events in a somewhat test framework
    /// agnostic manner. This means you can transform a `XCTIssue` into a JSON
    /// event, receive it with the Swift Testing event handler, and report it
    /// alongside the test results.
    ///
    /// Replicates Swift Testing's event record JSON format:
    /// https://github.com/swiftlang/swift-testing/blob/main/Documentation/ABI/JSON.md
    struct Event: Codable {
        struct Instant: Codable {
            var absolute: Double
            var since1970: Double
        }

        struct Attachment: Codable, Equatable {
            var path: String
        }

        struct Issue: Codable, Equatable {
            struct SourceLocation: Codable, Equatable {
                var fileID: String
                var filePath: String
                var line: Int
                var column: Int
            }

            var isKnown: Bool
            var sourceLocation: SourceLocation?
        }

        struct Message: Codable, Equatable {
            var symbol: String
            var text: String
        }

        var kind: String
        var instant: Instant
        var issue: Issue?
        var attachment: Attachment?
        var messages: [Message]
        var testId: String?
    }
}
