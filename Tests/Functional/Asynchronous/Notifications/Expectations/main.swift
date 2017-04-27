// RUN: %{swiftc} %s -o %T/Asynchronous-Notifications
// RUN: %T/Asynchronous-Notifications > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'NotificationExpectationsTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class NotificationExpectationsTestCase: XCTestCase {
// CHECK: Test Case 'NotificationExpectationsTestCase.test_observeNotificationWithName_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'NotificationExpectationsTestCase.test_observeNotificationWithName_passes' passed \(\d+\.\d+ seconds\)
    func test_observeNotificationWithName_passes() {
        let notificationName = "notificationWithNameTest"
        expectation(forNotification: notificationName, object:nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: nil)
        waitForExpectations(timeout: 0.0)
    }
    
// CHECK: Test Case 'NotificationExpectationsTestCase.test_observeNotificationWithNameAndObject_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'NotificationExpectationsTestCase.test_observeNotificationWithNameAndObject_passes' passed \(\d+\.\d+ seconds\)
    func test_observeNotificationWithNameAndObject_passes() {
        let notificationName = "notificationWithNameAndObjectTest"
        let dummyObject = NSObject()
        expectation(forNotification: notificationName, object:dummyObject)
        NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: dummyObject)
        waitForExpectations(timeout: 0.0)
    }
    
// CHECK: Test Case 'NotificationExpectationsTestCase.test_observeNotificationWithNameAndObject_butExpectingNoObject_passes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'NotificationExpectationsTestCase.test_observeNotificationWithNameAndObject_butExpectingNoObject_passes' passed \(\d+\.\d+ seconds\)
    func test_observeNotificationWithNameAndObject_butExpectingNoObject_passes() {
        let notificationName = "notificationWithNameAndObject_expectNoObjectTest"
        expectation(forNotification: notificationName, object:nil)
        let dummyObject = NSObject()
        NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: dummyObject)
        waitForExpectations(timeout: 0.0)
    }
    
// CHECK: Test Case 'NotificationExpectationsTestCase.test_observeNotificationWithIncorrectName_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*/Tests/Functional/Asynchronous/Notifications/Expectations/main.swift:[[@LINE+5]]: error: NotificationExpectationsTestCase.test_observeNotificationWithIncorrectName_fails : Asynchronous wait failed - Exceeded timeout of 0.1 seconds, with unfulfilled expectations: Expect notification 'expectedName' from any object
// CHECK: Test Case 'NotificationExpectationsTestCase.test_observeNotificationWithIncorrectName_fails' failed \(\d+\.\d+ seconds\)
    func test_observeNotificationWithIncorrectName_fails() {
        expectation(forNotification: "expectedName", object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "actualName"), object: nil)
        waitForExpectations(timeout: 0.1)
    }
    
// CHECK: Test Case 'NotificationExpectationsTestCase.test_observeNotificationWithIncorrectObject_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*/Tests/Functional/Asynchronous/Notifications/Expectations/main.swift:[[@LINE+8]]: error: NotificationExpectationsTestCase.test_observeNotificationWithIncorrectObject_fails : Asynchronous wait failed - Exceeded timeout of 0.1 seconds, with unfulfilled expectations: Expect notification 'notificationWithIncorrectObjectTest' from dummyObject
// CHECK: Test Case 'NotificationExpectationsTestCase.test_observeNotificationWithIncorrectObject_fails' failed \(\d+\.\d+ seconds\)
    func test_observeNotificationWithIncorrectObject_fails() {
        let notificationName = "notificationWithIncorrectObjectTest"
        let dummyObject: NSString = "dummyObject"
        let anotherDummyObject = NSObject()
        expectation(forNotification: notificationName, object: dummyObject)
        NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object:anotherDummyObject)
        waitForExpectations(timeout: 0.1)
    }
    
    static var allTests = {
        return [
                   ("test_observeNotificationWithName_passes", test_observeNotificationWithName_passes),
                   ("test_observeNotificationWithNameAndObject_passes", test_observeNotificationWithNameAndObject_passes),
                   ("test_observeNotificationWithNameAndObject_butExpectingNoObject_passes", test_observeNotificationWithNameAndObject_butExpectingNoObject_passes),
                   ("test_observeNotificationWithIncorrectName_fails", test_observeNotificationWithIncorrectName_fails),
                   ("test_observeNotificationWithIncorrectObject_fails", test_observeNotificationWithIncorrectObject_fails),
        ]
    }()
}
// CHECK: Test Suite 'NotificationExpectationsTestCase' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 5 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([testCase(NotificationExpectationsTestCase.allTests)])

// CHECK: Test Suite '.*\.xctest' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 5 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 5 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
