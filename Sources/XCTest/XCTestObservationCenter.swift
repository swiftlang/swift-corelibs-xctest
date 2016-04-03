// This source file is part of the Swift.org open source project
//
// Copyright (c) 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTestObservationCenter.swift
//  Notification center for test run progress events.
//

#if os(Linux) || os(FreeBSD)
    import Foundation
#else
    import SwiftFoundation
#endif

/// Provides a registry for objects wishing to be informed about progress
/// during the course of a test run. Observers must implement the
/// `XCTestObservation` protocol
/// - seealso: `XCTestObservation`
public class XCTestObservationCenter {

    private static var center = XCTestObservationCenter()
    private var observers = Set<ObjectWrapper<XCTestObservation>>()

    /// Registration should be performed on this shared instance
    public class func shared() -> XCTestObservationCenter {
        return center
    }

    /// Register an observer to receive future events during a test run. The order
    /// in which individual observers are notified about events is undefined.
    public func addTestObserver(testObserver: XCTestObservation) {
        observers.insert(testObserver.wrapper)
    }

    /// Remove a previously-registered observer so that it will no longer receive
    /// event callbacks.
    public func removeTestObserver(testObserver: XCTestObservation) {
        observers.remove(testObserver.wrapper)
    }

    internal func testBundleWillStart(testBundle: NSBundle) {
        forEachObserver { $0.testBundleWillStart(testBundle) }
    }

    internal func testSuiteWillStart(testSuite: XCTestSuite) {
        forEachObserver { $0.testSuiteWillStart(testSuite) }
    }

    internal func testCaseWillStart(testCase: XCTestCase) {
        forEachObserver { $0.testCaseWillStart(testCase) }
    }

    internal func testCase(testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
        forEachObserver { $0.testCase(testCase, didFailWithDescription: description, inFile: filePath, atLine: lineNumber) }
    }

    internal func testCaseDidFinish(testCase: XCTestCase) {
        forEachObserver { $0.testCaseDidFinish(testCase) }
    }

    internal func testSuiteDidFinish(testSuite: XCTestSuite) {
        forEachObserver { $0.testSuiteDidFinish(testSuite) }
    }

    internal func testBundleDidFinish(testBundle: NSBundle) {
        forEachObserver { $0.testBundleDidFinish(testBundle) }
    }

    private func forEachObserver(@noescape body: XCTestObservation -> Void) {
        for observer in observers {
            body(observer.object)
        }
    }
}

private extension XCTestObservation {
    var wrapper: ObjectWrapper<XCTestObservation> {
        return ObjectWrapper(object: self, objectIdentifier: ObjectIdentifier(self))
    }
}
