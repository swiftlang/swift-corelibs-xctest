// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTestCase.swift
//  Base class for test cases
//

/// A block with the test code to be invoked when the test runs.
///
/// - Parameter testCase: the test case associated with the current test code.
public typealias XCTestCaseClosure = (XCTestCase) throws -> Void

/// This is a compound type used by `XCTMain` to represent tests to run. It combines an
/// `XCTestCase` subclass type with the list of test case methods to invoke on the class.
/// This type is intended to be produced by the `testCase` helper function.
/// - seealso: `testCase`
/// - seealso: `XCTMain`
public typealias XCTestCaseEntry = (testCaseClass: XCTestCase.Type, allTests: [(String, XCTestCaseClosure)])

// A global pointer to the currently running test case. This is required in
// order for XCTAssert functions to report failures.
internal var XCTCurrentTestCase: XCTestCase?

/// An instance of this class represents an individual test case which can be
/// run by the framework. This class is normally subclassed and extended with
/// methods containing the tests to run.
/// - seealso: `XCTMain`
open class XCTestCase: XCTest {
    private let testClosure: XCTestCaseClosure

    private var skip: XCTSkip?

    /// The name of the test case, consisting of its class name and the method
    /// name it will run.
    open override var name: String {
        return _name
    }
    /// A private setter for the name of this test case.
    private var _name: String

    open override var testCaseCount: Int {
        return 1
    }

    internal var currentWaiter: XCTWaiter?

    /// The set of expectations made upon this test case.
    private var _allExpectations = [XCTestExpectation]()

    internal var expectations: [XCTestExpectation] {
        return XCTWaiter.subsystemQueue.sync {
            return _allExpectations
        }
    }

    internal func addExpectation(_ expectation: XCTestExpectation) {
        precondition(Thread.isMainThread, "\(#function) must be called on the main thread")
        precondition(currentWaiter == nil, "API violation - creating an expectation while already in waiting mode.")

        XCTWaiter.subsystemQueue.sync {
            _allExpectations.append(expectation)
        }
    }

    internal func cleanUpExpectations(_ expectationsToCleanUp: [XCTestExpectation]? = nil) {
        XCTWaiter.subsystemQueue.sync {
            if let expectationsToReset = expectationsToCleanUp {
                for expectation in expectationsToReset {
                    expectation.cleanUp()
                    _allExpectations.removeAll(where: { $0 == expectation })
                }
            } else {
                for expectation in _allExpectations {
                    expectation.cleanUp()
                }
                _allExpectations.removeAll()
            }
        }
    }

    /// An internal object implementing performance measurements.
    internal var _performanceMeter: PerformanceMeter?

    open override var testRunClass: AnyClass? {
        return XCTestCaseRun.self
    }

    open override func perform(_ run: XCTestRun) {
        guard let testRun = run as? XCTestCaseRun else {
            fatalError("Wrong XCTestRun class.")
        }

        XCTCurrentTestCase = self
        testRun.start()
        invokeTest()
        failIfExpectationsNotWaitedFor(_allExpectations)
        testRun.stop()
        XCTCurrentTestCase = nil
    }

    /// The designated initializer for SwiftXCTest's XCTestCase.
    /// - Note: Like the designated initializer for Apple XCTest's XCTestCase,
    ///   `-[XCTestCase initWithInvocation:]`, it's rare for anyone outside of
    ///   XCTest itself to call this initializer.
    public required init(name: String, testClosure: @escaping XCTestCaseClosure) {
        _name = "\(type(of: self)).\(name)"
        self.testClosure = testClosure
    }

    /// Invoking a test performs its setUp, invocation, and tearDown. In
    /// general this should not be called directly.
    open func invokeTest() {
        performSetUpSequence()

        do {
            if skip == nil {
                try testClosure(self)
            }
        } catch {
            if error.xct_shouldRecordAsTestFailure {
                recordFailure(for: error)
            }

            if error.xct_shouldRecordAsTestSkip {
                if let skip = error as? XCTSkip {
                    self.skip = skip
                } else {
                    self.skip = XCTSkip(error: error, message: nil, sourceLocation: nil)
                }
            }
        }

        if let skip = skip {
            testRun?.recordSkip(description: skip.summary, sourceLocation: skip.sourceLocation)
        }

        performTearDownSequence()
    }

    /// Records a failure in the execution of the test and is used by all test
    /// assertions.
    /// - Parameter description: The description of the failure being reported.
    /// - Parameter filePath: The file path to the source file where the failure
    ///   being reported was encountered.
    /// - Parameter lineNumber: The line number in the source file at filePath
    ///   where the failure being reported was encountered.
    /// - Parameter expected: `true` if the failure being reported was the
    ///   result of a failed assertion, `false` if it was the result of an
    ///   uncaught exception.
    open func recordFailure(withDescription description: String, inFile filePath: String, atLine lineNumber: Int, expected: Bool) {
        testRun?.recordFailure(
            withDescription: description,
            inFile: filePath,
            atLine: lineNumber,
            expected: expected)

        _performanceMeter?.abortMeasuring()

        // FIXME: Apple XCTest does not throw a fatal error and crash the test
        //        process, it merely prevents the remainder of a testClosure
        //        from expecting after it's been determined that it has already
        //        failed. The following behavior is incorrect.
        // FIXME: No regression tests exist for this feature. We may break it
        //        without ever realizing.
        if !continueAfterFailure {
            fatalError("Terminating execution due to test failure")
        }
    }

    // Convenience for recording failure using a SourceLocation
    func recordFailure(description: String, at sourceLocation: SourceLocation, expected: Bool) {
        recordFailure(withDescription: description, inFile: sourceLocation.file, atLine: Int(sourceLocation.line), expected: expected)
    }

    // Convenience for recording a failure for a caught Error
    private func recordFailure(for error: Error) {
        recordFailure(
            withDescription: "threw error \"\(error)\"",
            inFile: "<EXPR>",
            atLine: 0,
            expected: false)
    }

    /// Setup method called before the invocation of any test method in the
    /// class.
    open class func setUp() {}

    /// Teardown method called after the invocation of every test method in the
    /// class.
    open class func tearDown() {}

    private var teardownBlocks: [() -> Void] = []
    private var teardownBlocksDequeued: Bool = false
    private let teardownBlocksQueue: DispatchQueue = DispatchQueue(label: "org.swift.XCTest.XCTestCase.teardownBlocks")

    /// Registers a block of teardown code to be run after the current test
    /// method ends.
    open func addTeardownBlock(_ block: @escaping () -> Void) {
        teardownBlocksQueue.sync {
            precondition(!self.teardownBlocksDequeued, "API violation -- attempting to add a teardown block after teardown blocks have been dequeued")
            self.teardownBlocks.append(block)
        }
    }

    private func performSetUpSequence() {
        do {
            try setUpWithError()
        } catch {
            if error.xct_shouldRecordAsTestFailure {
                recordFailure(for: error)
            }

            if error.xct_shouldSkipTestInvocation {
                if let skip = error as? XCTSkip {
                    self.skip = skip
                } else {
                    self.skip = XCTSkip(error: error, message: nil, sourceLocation: nil)
                }
            }
        }

        setUp()
    }

    private func performTearDownSequence() {
        runTeardownBlocks()

        tearDown()

        do {
            try tearDownWithError()
        } catch {
            if error.xct_shouldRecordAsTestFailure {
                recordFailure(for: error)
            }
        }
    }

    private func runTeardownBlocks() {
        let blocks = teardownBlocksQueue.sync { () -> [() -> Void] in
            self.teardownBlocksDequeued = true
            let blocks = self.teardownBlocks
            self.teardownBlocks = []
            return blocks
        }

        for block in blocks.reversed() {
            block()
        }
    }

    open var continueAfterFailure: Bool {
        get {
            return true
        }
        set {
            // TODO: When using the Objective-C runtime, XCTest is able to throw an exception from an assert and then catch it at the frame above the test method.
            //      This enables the framework to effectively stop all execution in the current test.
            //      There is no such facility in Swift. Until we figure out how to get a compatible behavior,
            //      we have decided to hard-code the value of 'true' for continue after failure.
        }
    }
}

/// Wrapper function allowing an array of static test case methods to fit
/// the signature required by `XCTMain`
/// - seealso: `XCTMain`
public func testCase<T: XCTestCase>(_ allTests: [(String, (T) -> () throws -> Void)]) -> XCTestCaseEntry {
    let tests: [(String, XCTestCaseClosure)] = allTests.map { ($0.0, test($0.1)) }
    return (T.self, tests)
}

/// Wrapper function for the non-throwing variant of tests.
/// - seealso: `XCTMain`
public func testCase<T: XCTestCase>(_ allTests: [(String, (T) -> () -> Void)]) -> XCTestCaseEntry {
    let tests: [(String, XCTestCaseClosure)] = allTests.map { ($0.0, test($0.1)) }
    return (T.self, tests)
}

private func test<T: XCTestCase>(_ testFunc: @escaping (T) -> () throws -> Void) -> XCTestCaseClosure {
    return { testCaseType in
        guard let testCase = testCaseType as? T else {
            fatalError("Attempt to invoke test on class \(T.self) with incompatible instance type \(type(of: testCaseType))")
        }

        try testFunc(testCase)()
    }
}
