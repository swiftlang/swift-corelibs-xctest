// Test Case 'SingleFailingTestCase.test_fails' started.
// %file:22: error: SingleFailingTestCase.test_fails : 
// Test Case 'SingleFailingTestCase.test_fails' failed (%ignored-time-duration seconds).
// Executed 1 test, with 1 failure (0 unexpected) in %ignored-time-duration (%ignored-time-duration) seconds
// Total executed 1 test, with 1 failure (0 unexpected) in %ignored-time-duration (%ignored-time-duration) seconds
// %exit-status: 1

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
