// RUN: %S/../../Products/SingleFailingTestCase > %t.out || true
// RUN: FileCheck %s < %t.out
// RUN: rm %t.out

// CHECK: Test Case 'SingleFailingTestCase.test_fails' started.
// CHECK: {{.*}}/Tests/Functional/Sources/SingleFailingTestCase/main.swift:25: error: SingleFailingTestCase.test_fails :
// CHECK: Test Case 'SingleFailingTestCase.test_fails' failed ({{[0-9]+\.[0-9]+}} seconds).
// CHECK: Executed 1 test, with 1 failure (0 unexpected) in {{[0-9]+\.[0-9]+}} ({{[0-9]+\.[0-9]+}}) seconds
// CHECK: Total executed 1 test, with 1 failure (0 unexpected) in {{[0-9]+\.[0-9]+}} ({{[0-9]+\.[0-9]+}}) seconds

#if os(Linux)
    import XCTest
#else
    import SwiftXCTest
#endif

class SingleFailingTestCase: XCTestCase {
    var allTests: [(String, () -> ())] {
        return [
            ("test_fails", test_fails),
        ]
    }

    func test_fails() {
        XCTAssert(false)
    }
}

XCTMain([SingleFailingTestCase()])
