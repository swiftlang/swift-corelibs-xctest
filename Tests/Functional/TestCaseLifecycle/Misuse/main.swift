// RUN: %{swiftc} %s -g -o %T/TestCaseLifecycleMisuse
// RUN: env SWIFT_BACKTRACE=enable=no %T/TestCaseLifecycleMisuse > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'TeardownBlocksMisuseTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class TeardownBlocksMisuseTestCase: XCTestCase {

    // CHECK: Test Case 'TeardownBlocksMisuseTestCase.test_addingATeardownBlockLate_crashes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    func test_addingATeardownBlockLate_crashes() {
        addTeardownBlock { [weak self] in
            guard let self = self else {
                XCTFail("self should still exist at this point")
                return
            }
            // The following line should crash and nothing more will be printed
            self.addTeardownBlock {
                print("This should not be printed")
            }
        }
    }

    static var allTests = {
      return [
          ("test_addingATeardownBlockLate_crashes", test_addingATeardownBlockLate_crashes),
      ]
    }()
}

XCTMain([
    testCase(TeardownBlocksMisuseTestCase.allTests),
])
