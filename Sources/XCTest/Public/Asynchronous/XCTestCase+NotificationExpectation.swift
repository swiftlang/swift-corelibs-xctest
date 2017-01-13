// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTestCase+NotificationExpectation.swift
//

public extension XCTestCase {
    /// Creates and returns an expectation for a notification.
    ///
    /// - Parameter notificationName: The name of the notification the
    ///   expectation observes.
    /// - Parameter object: The object whose notifications the expectation will
    ///   receive; that is, only notifications with this object are observed by
    ///   the test case. If you pass nil, the expectation doesn't use
    ///   a notification's object to decide whether it is fulfilled.
    /// - Parameter handler: If provided, the handler will be invoked when the
    ///   notification is observed. It will not be invoked on timeout. Use the
    ///   handler to further investigate if the notification fulfills the
    ///   expectation.
    @discardableResult func expectation(forNotification notificationName: String, object objectToObserve: AnyObject?, handler: XCNotificationExpectationHandler? = nil) -> XCTestExpectation {
        let objectDescription = objectToObserve == nil ? "any object" : "\(objectToObserve!)"
        let expectation = self.expectation(description: "Expect notification '\(notificationName)' from " + objectDescription)
        // Start observing the notification with specified name and object.
        var observer: NSObjectProtocol? = nil
        func removeObserver() {
            if let observer = observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }

        weak var weakExpectation = expectation
        observer = NotificationCenter
            .default
            .addObserver(forName: Notification.Name(rawValue: notificationName),
                         object: objectToObserve,
                         queue: nil) {
                            notification in
                            guard let expectation = weakExpectation else {
                                removeObserver()
                                return
                            }

                            // If the handler is invoked, the test will
                            // only pass if true is returned.
                            if let handler = handler {
                                if handler(notification) {
                                    expectation.fulfill()
                                    removeObserver()
                                }
                            } else {
                                expectation.fulfill()
                                removeObserver()
                            }
                        }

        return expectation
    }
}
