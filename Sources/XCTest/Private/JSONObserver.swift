// This source file is part of the Swift.org open source project
//
// Copyright (c) 2026 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
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

@available(macOS 13, *)
internal final class JSONObserver: XCTestObservation {
    private let _file: FileHandle
    private let _schemaVersion: String

    private func _now() -> [String: Double] {
        [
            "absolute": (SuspendingClock().now - SuspendingClock().systemEpoch) / .seconds(1),
            "since1970": Date.now.timeIntervalSince1970,
        ]
    }

    private func _write(_ jsonObject: [String: Any]) {
        if let json = try? JSONSerialization.data(withJSONObject: jsonObject, options: []) {
            try? _file.write(contentsOf: json)
        }
    }

    init(writingToFileAtPath filePath: String, schemaVersion: String) throws {
        _file = try FileHandle(forWritingTo: URL(filePath: filePath, directoryHint: .notDirectory))
        _schemaVersion = schemaVersion
    }

    func testBundleWillStart(_ testBundle: Bundle) {
        let jsonObject: [String: Any] = [
            "version": _schemaVersion,
            "kind": "event",
            "payload": [
                "kind": "runStarted",
                "instant": _now(),
            ]
        ]
        _write(jsonObject)
    }

    func testSuiteWillStart(_ testSuite: XCTestSuite) {
        let jsonObject: [String: Any] = [
            "version": _schemaVersion,
            "kind": "event",
            "payload": [
                "kind": "runStarted",
                "instant": _now(),
            ]
        ]
        _write(jsonObject)
    }

    func testCaseWillStart(_ testCase: XCTestCase) {
        let jsonObject: [String: Any] = [
            "version": _schemaVersion,
            "kind": "event",
            "payload": [
                "kind": "testStarted",
                "instant": _now(),
                "testID": testCase.id,
            ]
        ]
        _write(jsonObject)
    }

    func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        let jsonObject: [String: Any] = [
            "version": _schemaVersion,
            "kind": "event",
            "payload": [
                "kind": "issueRecorded",
                "instant": _now(),
                "testID": testCase.id,
                "issue": [
                    "severity": "error",
                    "isFailure": true,
                ],
                "_comments": [
                    description,
                ],
            ]
        ]
        _write(jsonObject)
    }

    func testCaseDidFinish(_ testCase: XCTestCase) {
        let jsonObject: [String: Any] = [
            "version": _schemaVersion,
            "kind": "event",
            "payload": [
                "kind": "testEnded",
                "instant": _now(),
                "testID": testCase.id,
            ]
        ]
        _write(jsonObject)
    }

    func testSuiteDidFinish(_ testSuite: XCTestSuite) {
    }

    func testBundleDidFinish(_ testBundle: Bundle) {
        let jsonObject: [String: Any] = [
            "version": _schemaVersion,
            "kind": "event",
            "payload": [
                "kind": "runEnded",
                "instant": _now(),
            ]
        ]
        _write(jsonObject)
    }
}

@available(macOS 13, *)
extension JSONObserver: XCTestInternalObservation {
    func testCaseWasDiscovered(_ testCase: XCTestCase) {
        let jsonObject: [String: Any] = [
            "version": _schemaVersion,
            "kind": "test",
            "payload": [
                "kind": "function",
                "name": testCase.name,
                "sourceLocation": [
                    "fileID": "<unknown>/<unknown>",
                    "filePath": "<unknown>",
                    "line": 1,
                    "column": 1,
                ],
                "id": testCase.id,
                "isParameterized": false,
            ]
        ]
        _write(jsonObject)
    }

    func testCase(_ testCase: XCTestCase, wasSkippedWithDescription description: String, at sourceLocation: SourceLocation?) {
        let jsonObject: [String: Any] = [
            "version": _schemaVersion,
            "kind": "event",
            "payload": [
                "kind": "testCancelled",
                "instant": _now(),
                "testID": testCase.id,
            ]
        ]
        _write(jsonObject)
    }
}
