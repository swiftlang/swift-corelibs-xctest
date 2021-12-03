// RUN: %{swiftc} %s -o %T/Use
// RUN: %T/Use > %t || true
// RUN: %{xctest_checker} %t %s
// REQUIRES: concurrency_runtime

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

actor TestActor {
    
    enum Errors: String, Error {
        case example
    }
    
    private(set) var counter: Int = 0
    
    func increment() async {
        counter += 1
    }
    
    func decrement() async {
        counter -= 1
    }
    
    func alwaysThrows() async throws {
        throw TestActor.Errors.example
    }
    
    func neverThrows() async throws {}
}

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'AsyncAwaitTests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

class AsyncAwaitTests: XCTestCase {
    
    lazy var subject = TestActor()
    
    static let allTests = {
        return [
            ("test_explicitFailures_withinAsyncTests_areReported",        asyncTest(test_explicitFailures_withinAsyncTests_areReported)),
            ("test_asyncAnnotatedFunctionsCanPass",                       asyncTest(test_asyncAnnotatedFunctionsCanPass)),
            ("test_actorsAreSupported",                                   asyncTest(test_actorsAreSupported)),
            ("test_asyncErrors_withinTestMethods_areReported",            asyncTest(test_asyncErrors_withinTestMethods_areReported)),
            ("test_asyncAwaitCalls_withinTeardownBlocks_areSupported",    asyncTest(test_asyncAwaitCalls_withinTeardownBlocks_areSupported)),
            ("test_asyncErrors_withinTeardownBlocks_areReported",         asyncTest(test_asyncErrors_withinTeardownBlocks_areReported)),
            ("test_somethingAsyncWithDelay",                              asyncTest(test_somethingAsyncWithDelay)),
            ("test_syncWithinClassWithAsyncTestMethods",                  test_syncWithinClassWithAsyncTestMethods),
        ]
    }()
    
    override func setUp() async throws {}
    
    override func tearDown() async throws {}

    // CHECK: Test Case 'AsyncAwaitTests.test_explicitFailures_withinAsyncTests_areReported' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: .*[/\\]Asynchronous[/\\]Use[/\\]main.swift:[[@LINE+3]]: error: AsyncAwaitTests.test_explicitFailures_withinAsyncTests_areReported : XCTAssertTrue failed -
    // CHECK: Test Case 'AsyncAwaitTests.test_explicitFailures_withinAsyncTests_areReported' failed \(\d+\.\d+ seconds\)
    func test_explicitFailures_withinAsyncTests_areReported() async throws {
        XCTAssert(false)
    }
    
    // CHECK: Test Case 'AsyncAwaitTests.test_asyncAnnotatedFunctionsCanPass' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: Test Case 'AsyncAwaitTests.test_asyncAnnotatedFunctionsCanPass' passed \(\d+\.\d+ seconds\)
    func test_asyncAnnotatedFunctionsCanPass() async throws {
        let value = await makeString()
        XCTAssertNotEqual(value, "")
    }
    
    // CHECK: Test Case 'AsyncAwaitTests.test_actorsAreSupported' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: Test Case 'AsyncAwaitTests.test_actorsAreSupported' passed \(\d+\.\d+ seconds\)
    func test_actorsAreSupported() async throws {
        let initialCounterValue = await subject.counter
        XCTAssertEqual(initialCounterValue, 0)
        
        await subject.increment()
        await subject.increment()
        
        let secondCounterValue = await subject.counter
        XCTAssertEqual(secondCounterValue, 2)

        await subject.decrement()
        let thirdCounterValue = await subject.counter
        XCTAssertEqual(thirdCounterValue, 1)
    }
    
    // CHECK: Test Case 'AsyncAwaitTests.test_asyncErrors_withinTestMethods_areReported' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: \<EXPR\>:0: error: AsyncAwaitTests.test_asyncErrors_withinTestMethods_areReported : threw error "example"
    // CHECK: Test Case 'AsyncAwaitTests.test_asyncErrors_withinTestMethods_areReported' failed \(\d+\.\d+ seconds\)
    func test_asyncErrors_withinTestMethods_areReported() async throws {
        try await subject.alwaysThrows()
    }
    
    // CHECK: Test Case 'AsyncAwaitTests.test_asyncAwaitCalls_withinTeardownBlocks_areSupported' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: In teardown block\n
    // CHECK: \<EXPR\>:0: error: AsyncAwaitTests.test_asyncAwaitCalls_withinTeardownBlocks_areSupported : threw error "example"
    // CHECK: Test Case 'AsyncAwaitTests.test_asyncAwaitCalls_withinTeardownBlocks_areSupported' failed \(\d+\.\d+ seconds\)
    func test_asyncAwaitCalls_withinTeardownBlocks_areSupported() async throws {
        addTeardownBlock {
            print("In teardown block")
            try await self.subject.alwaysThrows()
        }
    }
    
    // CHECK: Test Case 'AsyncAwaitTests.test_asyncErrors_withinTeardownBlocks_areReported' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+\
    // CHECK: <EXPR>:0: error: AsyncAwaitTests.test_asyncErrors_withinTeardownBlocks_areReported : threw error "example"\n
    // CHECK: Test Case 'AsyncAwaitTests.test_asyncErrors_withinTeardownBlocks_areReported' failed \(\d+\.\d+ seconds\)
    func test_asyncErrors_withinTeardownBlocks_areReported() throws {
        let issueRecordedExpectation = XCTestExpectation(description: "Asynchronous error recorded in: \(#function)")

        addTeardownBlock {
            // Use addTeardownBlock here because the `addTeardownBlock` below intentionally throws an error so we can't `wait` after that in the same scope
            self.wait(for: [issueRecordedExpectation], timeout: 1)
        }

        addTeardownBlock {
            do {
                try await self.subject.alwaysThrows()
            } catch {
                issueRecordedExpectation.fulfill()
                throw error
            }
        }
    }
    
    // CHECK: Test Case 'AsyncAwaitTests.test_somethingAsyncWithDelay' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: Test Case 'AsyncAwaitTests.test_somethingAsyncWithDelay' passed \(\d+\.\d+ seconds\)
    func test_somethingAsyncWithDelay() async throws {
        try await doSomethingWithDelay()
    }

    // CHECK: Test Case 'AsyncAwaitTests.test_syncWithinClassWithAsyncTestMethods' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: Test Case 'AsyncAwaitTests.test_syncWithinClassWithAsyncTestMethods' passed \(\d+\.\d+ seconds\)
    func test_syncWithinClassWithAsyncTestMethods() /* intentionally non-async */ throws {
        XCTAssert(Thread.isMainThread, "Expected to be ran on the main thread, but wasn't.")
    }
}

private extension AsyncAwaitTests {
    
    func makeString() async -> String {
        """
        Some arbitrary text.
        Nothing to see here, folx.
        """
    }
    
    func doSomethingWithDelay() async throws {
        func doSomethingWithDelay(completion: @escaping (Error?) -> Void) {
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(10)) {
                completion(nil)
            }
        }
        
        try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Void, Error>) in
            doSomethingWithDelay { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}

// CHECK: Test Suite 'AsyncAwaitTests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 8 tests, with 4 failures \(3 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite '.*\.xctest' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 8 tests, with 4 failures \(3 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([testCase(AsyncAwaitTests.allTests)])

// CHECK: Test Suite 'All tests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed 8 tests, with 4 failures \(3 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

