// RUN: %{swiftc} %s -o %T/TestCaseLifecycle
// RUN: %T/TestCaseLifecycle > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'SetUpTearDownTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class SetUpTearDownTestCase: XCTestCase {
    static var allTests = {
        return [
            ("test_hasValueFromSetUp", test_hasValueFromSetUp),
        ]
    }()

    var value = 0

    // CHECK: In class setUp\(\)
    override class func setUp() {
        super.setUp()
        print("In class \(#function)")
        XCTAssert(Thread.isMainThread, "Expected to be ran on the main thread, but wasn't.")
    }

    override func setUp() {
        super.setUp()
        print("In \(#function)")
        value = 42
        XCTAssert(Thread.isMainThread, "Expected to be ran on the main thread, but wasn't.")
    }

    override func tearDown() {
        super.tearDown()
        print("In \(#function)")
        XCTAssert(Thread.isMainThread, "Expected to be ran on the main thread, but wasn't.")
    }

// CHECK: Test Case 'SetUpTearDownTestCase.test_hasValueFromSetUp' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: In setUp\(\)
// CHECK: In test_hasValueFromSetUp\(\)
// CHECK: In tearDown\(\)
// CHECK: Test Case 'SetUpTearDownTestCase.test_hasValueFromSetUp' passed \(\d+\.\d+ seconds\)
    func test_hasValueFromSetUp() {
        print("In \(#function)")
        XCTAssertEqual(value, 42)
    }

    // CHECK: In class tearDown\(\)
    override class func tearDown() {
        super.tearDown()
        print("In class \(#function)")
        XCTAssert(Thread.isMainThread, "Expected to be ran on the main thread, but wasn't.")
    }
}
// CHECK: Test Suite 'SetUpTearDownTestCase' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 1 test, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds


// CHECK: Test Suite 'NewInstanceForEachTestTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class NewInstanceForEachTestTestCase: XCTestCase {
    static var allTests = {
        return [
            ("test_hasInitializedValue", test_hasInitializedValue),
            ("test_hasInitializedValueInAnotherTest", test_hasInitializedValueInAnotherTest),
        ]
    }()

    var value = 1

// CHECK: Test Case 'NewInstanceForEachTestTestCase.test_hasInitializedValue' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'NewInstanceForEachTestTestCase.test_hasInitializedValue' passed \(\d+\.\d+ seconds\)
    func test_hasInitializedValue() {
        XCTAssertEqual(value, 1)
        value += 1
    }

// CHECK: Test Case 'NewInstanceForEachTestTestCase.test_hasInitializedValueInAnotherTest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'NewInstanceForEachTestTestCase.test_hasInitializedValueInAnotherTest' passed \(\d+\.\d+ seconds\)
    func test_hasInitializedValueInAnotherTest() {
        XCTAssertEqual(value, 1)
    }
}
// CHECK: Test Suite 'NewInstanceForEachTestTestCase' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 2 tests, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds


// CHECK: Test Suite 'TeardownBlocksTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class TeardownBlocksTestCase: XCTestCase {
    static var allTests = {
        return [
            ("test_withoutTeardownBlocks", test_withoutTeardownBlocks),
            ("test_withATeardownBlock", test_withATeardownBlock),
            ("test_withSeveralTeardownBlocks", test_withSeveralTeardownBlocks),
        ]
    }()
    
    override func setUp() {
        XCTAssert(Thread.isMainThread, "Expected to be ran on the main thread, but wasn't.")
    }

    override func tearDown() {
        print("In tearDown function")
        XCTAssert(Thread.isMainThread, "Expected to be ran on the main thread, but wasn't.")
    }

    // CHECK: Test Case 'TeardownBlocksTestCase.test_withoutTeardownBlocks' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: In tearDown function
    // CHECK: Test Case 'TeardownBlocksTestCase.test_withoutTeardownBlocks' passed \(\d+\.\d+ seconds\)
    func test_withoutTeardownBlocks() {
        XCTAssert(Thread.isMainThread, "Expected to be ran on the main thread, but wasn't.")
    }

    // CHECK: Test Case 'TeardownBlocksTestCase.test_withATeardownBlock' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: In teardown block A
    // CHECK: In tearDown function
    // CHECK: Test Case 'TeardownBlocksTestCase.test_withATeardownBlock' passed \(\d+\.\d+ seconds\)
    func test_withATeardownBlock() {
        addTeardownBlock {
            print("In teardown block A")
            XCTAssert(Thread.isMainThread, "Expected to be ran on the main thread, but wasn't.")
        }
    }

    // CHECK: Test Case 'TeardownBlocksTestCase.test_withSeveralTeardownBlocks' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: In teardown block C
    // CHECK: In teardown block B
    // CHECK: In tearDown function
    // CHECK: Test Case 'TeardownBlocksTestCase.test_withSeveralTeardownBlocks' passed \(\d+\.\d+ seconds\)
    func test_withSeveralTeardownBlocks() {
        addTeardownBlock {
            print("In teardown block B")
            XCTAssert(Thread.isMainThread, "Expected to be ran on the main thread, but wasn't.")
        }
        addTeardownBlock {
            print("In teardown block C")
            XCTAssert(Thread.isMainThread, "Expected to be ran on the main thread, but wasn't.")
        }
    }
}
// CHECK: Test Suite 'TeardownBlocksTestCase' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 3 tests, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds


XCTMain([
    testCase(SetUpTearDownTestCase.allTests),
    testCase(NewInstanceForEachTestTestCase.allTests),
    testCase(TeardownBlocksTestCase.allTests),
])

// CHECK: Test Suite '.*\.xctest' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 6 tests, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' passed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 6 tests, with 0 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
